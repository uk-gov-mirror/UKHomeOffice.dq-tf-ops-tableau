resource "aws_instance" "tableau" {
  key_name                    = var.key_name
  ami                         = data.aws_ami.tableau.id
  instance_type               = "t3.large"
  vpc_security_group_ids      = [aws_security_group.tableau.id]
  subnet_id                   = aws_subnet.tableau_subnet.id
  private_ip                  = var.tableau_dev_ip
  iam_instance_profile        = aws_iam_instance_profile.tableau.id
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
	<powershell>
	Rename-Computer -NewName "DEVELOPMENT" -Restart
  [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
	</powershell>
EOF


  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      user_data,
      ami,
      instance_type,
    ]
  }

  tags = {
    Name = "ec2-dev-${local.naming_suffix}"
  }
}

resource "aws_instance" "tableau2" {
  key_name                    = var.key_name
  ami                         = data.aws_ami.tableau.id
  instance_type               = "t3.large"
  vpc_security_group_ids      = [aws_security_group.tableau.id]
  subnet_id                   = aws_subnet.tableau_subnet.id
  private_ip                  = var.tableau_deployment_ip
  iam_instance_profile        = aws_iam_instance_profile.tableau.id
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
	<powershell>
  Rename-Computer -NewName "DEPLOYMENT" -Restart
  [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
	</powershell>
EOF


  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      user_data,
      ami,
      instance_type,
    ]
  }

  tags = {
    Name = "ec2-deployment-${local.naming_suffix}"
  }
}

resource "aws_security_group" "tableau" {
  vpc_id = var.opsvpc_id

  tags = {
    Name = "sg-${local.naming_suffix}"
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "TCP"

    cidr_blocks = [
      var.tableau_subnet_cidr_block,
      var.vpc_subnet_cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
