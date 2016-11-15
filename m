From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx5: Set driver version infrastructure
Date: Tue, 15 Nov 2016 23:30:04 +0200
Message-ID: <1479245407-6884-6-git-send-email-saeedm@mellanox.com>
References: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Huy Nguyen <huyn@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54827 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752445AbcKOVae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:30:34 -0500
In-Reply-To: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add driver_version capability bit is enabled, and set driver
version command in mlx5_ifc firmware header.  The only purpose
of this command is to store a driver version/OS string in FW
to be reported and displayed in various management systems,
such as IPMI/BMC.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index cd1d530..f08a0624 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -83,6 +83,7 @@ enum {
 	MLX5_CMD_OP_SET_HCA_CAP                   = 0x109,
 	MLX5_CMD_OP_QUERY_ISSI                    = 0x10a,
 	MLX5_CMD_OP_SET_ISSI                      = 0x10b,
+	MLX5_CMD_OP_SET_DRIVER_VERSION            = 0x10d,
 	MLX5_CMD_OP_CREATE_MKEY                   = 0x200,
 	MLX5_CMD_OP_QUERY_MKEY                    = 0x201,
 	MLX5_CMD_OP_DESTROY_MKEY                  = 0x202,
@@ -909,7 +910,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         log_pg_sz[0x8];
 
 	u8         bf[0x1];
-	u8         reserved_at_261[0x1];
+	u8         driver_version[0x1];
 	u8         pad_tx_eth_packet[0x1];
 	u8         reserved_at_263[0x8];
 	u8         log_bf_reg_size[0x5];
@@ -4005,6 +4006,25 @@ struct mlx5_ifc_query_issi_in_bits {
 	u8         reserved_at_40[0x40];
 };
 
+struct mlx5_ifc_set_driver_version_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_set_driver_version_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+	u8         driver_version[64][0x8];
+};
+
 struct mlx5_ifc_query_hca_vport_pkey_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
-- 
2.7.4
