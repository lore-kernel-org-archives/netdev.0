From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 10/14] net/mlx5: Set driver version infrastructure
Date: Tue, 25 Oct 2016 18:00:13 +0300
Message-ID: <1477407617-20745-11-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Huy Nguyen <huyn@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37520 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932474AbcJYPFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:45 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add driver_version capability bit is enabled, and set driver
version command in mlx5_ifc firmware header.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/mlx5_ifc.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 5289b27..f46fe4a 100644
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
@@ -891,7 +892,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         log_pg_sz[0x8];
 
 	u8         bf[0x1];
-	u8         reserved_at_261[0x1];
+	u8         driver_version[0x1];
 	u8         pad_tx_eth_packet[0x1];
 	u8         reserved_at_263[0x8];
 	u8         log_bf_reg_size[0x5];
@@ -4029,6 +4030,25 @@ struct mlx5_ifc_query_issi_in_bits {
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
