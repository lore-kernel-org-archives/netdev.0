From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5: Port module event hardware structures
Date: Tue, 15 Nov 2016 23:30:01 +0200
Message-ID: <1479245407-6884-3-git-send-email-saeedm@mellanox.com>
References: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54809 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753053AbcKOVae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:30:34 -0500
In-Reply-To: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Add hardware structures and constants definitions needed for module
events support.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 include/linux/mlx5/device.h   | 11 +++++++++++
 include/linux/mlx5/mlx5_ifc.h |  3 ++-
 include/linux/mlx5/port.h     |  3 +++
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 5827614..52b4374 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -277,6 +277,7 @@ enum mlx5_event {
 	MLX5_EVENT_TYPE_INTERNAL_ERROR	   = 0x08,
 	MLX5_EVENT_TYPE_PORT_CHANGE	   = 0x09,
 	MLX5_EVENT_TYPE_GPIO_EVENT	   = 0x15,
+	MLX5_EVENT_TYPE_PORT_MODULE_EVENT  = 0x16,
 	MLX5_EVENT_TYPE_REMOTE_CONFIG	   = 0x19,
 
 	MLX5_EVENT_TYPE_DB_BF_CONGESTION   = 0x1a,
@@ -552,6 +553,15 @@ struct mlx5_eqe_vport_change {
 	__be32		rsvd1[6];
 } __packed;
 
+struct mlx5_eqe_port_module {
+	u8        reserved_at_0[1];
+	u8        module;
+	u8        reserved_at_2[1];
+	u8        module_status;
+	u8        reserved_at_4[2];
+	u8        error_type;
+} __packed;
+
 union ev_data {
 	__be32				raw[7];
 	struct mlx5_eqe_cmd		cmd;
@@ -565,6 +575,7 @@ union ev_data {
 	struct mlx5_eqe_page_req	req_pages;
 	struct mlx5_eqe_page_fault	page_fault;
 	struct mlx5_eqe_vport_change	vport_change;
+	struct mlx5_eqe_port_module	port_module;
 } __packed;
 
 struct mlx5_eqe {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 2632cb2..cd1d530 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -824,7 +824,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8	   early_vf_enable[0x1];
 	u8         reserved_at_1a9[0x2];
 	u8         local_ca_ack_delay[0x5];
-	u8         reserved_at_1af[0x2];
+	u8         port_module_event[0x1];
+	u8         reserved_at_1b0[0x1];
 	u8         ports_check[0x1];
 	u8         reserved_at_1b2[0x1];
 	u8         disable_link_up[0x1];
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index b3065ac..dde8c7e 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -94,6 +94,9 @@ enum mlx5e_link_mode {
 
 #define MLX5E_PROT_MASK(link_mode) (1 << link_mode)
 
+#define PORT_MODULE_EVENT_MODULE_STATUS_MASK 0xF
+#define PORT_MODULE_EVENT_ERROR_TYPE_MASK         0xF
+
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 			 int ptys_size, int proto_mask, u8 local_port);
-- 
2.7.4
