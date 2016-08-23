From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V3 14/15] net/mlx5: Update mlx5_ifc.h for vxlan encap/decap
Date: Tue, 23 Aug 2016 11:49:16 +0300
Message-ID: <1471942157-9131-15-git-send-email-saeedm@mellanox.com>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471942157-9131-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add the required definitions related to vxlan encap/decap.

Signed-off-by: Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/mlx5/mlx5_ifc.h | 105 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 101 insertions(+), 4 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 7a8ef0a..3766110 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -212,6 +212,8 @@ enum {
 	MLX5_CMD_OP_DEALLOC_FLOW_COUNTER          = 0x93a,
 	MLX5_CMD_OP_QUERY_FLOW_COUNTER            = 0x93b,
 	MLX5_CMD_OP_MODIFY_FLOW_TABLE             = 0x93c,
+	MLX5_CMD_OP_ALLOC_ENCAP_HEADER            = 0x93d,
+	MLX5_CMD_OP_DEALLOC_ENCAP_HEADER          = 0x93e,
 	MLX5_CMD_OP_MAX
 };
 
@@ -281,7 +283,9 @@ struct mlx5_ifc_flow_table_prop_layout_bits {
 	u8         modify_root[0x1];
 	u8         identified_miss_table_mode[0x1];
 	u8         flow_table_modify[0x1];
-	u8         reserved_at_7[0x19];
+	u8         encap[0x1];
+	u8         decap[0x1];
+	u8         reserved_at_9[0x17];
 
 	u8         reserved_at_20[0x2];
 	u8         log_max_ft_size[0x6];
@@ -512,7 +516,15 @@ struct mlx5_ifc_e_switch_cap_bits {
 	u8         nic_vport_node_guid_modify[0x1];
 	u8         nic_vport_port_guid_modify[0x1];
 
-	u8         reserved_at_20[0x7e0];
+	u8         vxlan_encap_decap[0x1];
+	u8         nvgre_encap_decap[0x1];
+	u8         reserved_at_22[0x9];
+	u8         log_max_encap_headers[0x5];
+	u8         reserved_2b[0x6];
+	u8         max_encap_header_size[0xa];
+
+	u8         reserved_40[0x7c0];
+
 };
 
 struct mlx5_ifc_qos_cap_bits {
@@ -2067,6 +2079,8 @@ enum {
 	MLX5_FLOW_CONTEXT_ACTION_DROP      = 0x2,
 	MLX5_FLOW_CONTEXT_ACTION_FWD_DEST  = 0x4,
 	MLX5_FLOW_CONTEXT_ACTION_COUNT     = 0x8,
+	MLX5_FLOW_CONTEXT_ACTION_ENCAP     = 0x10,
+	MLX5_FLOW_CONTEXT_ACTION_DECAP     = 0x20,
 };
 
 struct mlx5_ifc_flow_context_bits {
@@ -2086,7 +2100,9 @@ struct mlx5_ifc_flow_context_bits {
 	u8         reserved_at_a0[0x8];
 	u8         flow_counter_list_size[0x18];
 
-	u8         reserved_at_c0[0x140];
+	u8         encap_id[0x20];
+
+	u8         reserved_at_e0[0x120];
 
 	struct mlx5_ifc_fte_match_param_bits match_value;
 
@@ -4216,6 +4232,85 @@ struct mlx5_ifc_query_eq_in_bits {
 	u8         reserved_at_60[0x20];
 };
 
+struct mlx5_ifc_encap_header_in_bits {
+	u8         reserved_at_0[0x5];
+	u8         header_type[0x3];
+	u8         reserved_at_8[0xe];
+	u8         encap_header_size[0xa];
+
+	u8         reserved_at_20[0x10];
+	u8         encap_header[2][0x8];
+
+	u8         more_encap_header[0][0x8];
+};
+
+struct mlx5_ifc_query_encap_header_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0xa0];
+
+	struct mlx5_ifc_encap_header_in_bits encap_header[0];
+};
+
+struct mlx5_ifc_query_encap_header_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         encap_id[0x20];
+
+	u8         reserved_at_60[0xa0];
+};
+
+struct mlx5_ifc_alloc_encap_header_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         encap_id[0x20];
+
+	u8         reserved_at_60[0x20];
+};
+
+struct mlx5_ifc_alloc_encap_header_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0xa0];
+
+	struct mlx5_ifc_encap_header_in_bits encap_header;
+};
+
+struct mlx5_ifc_dealloc_encap_header_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_dealloc_encap_header_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         encap_id[0x20];
+
+	u8         reserved_60[0x20];
+};
+
 struct mlx5_ifc_query_dct_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6102,7 +6197,9 @@ struct mlx5_ifc_create_flow_table_in_bits {
 
 	u8         reserved_at_a0[0x20];
 
-	u8         reserved_at_c0[0x4];
+	u8         encap_en[0x1];
+	u8         decap_en[0x1];
+	u8         reserved_at_c2[0x2];
 	u8         table_miss_mode[0x4];
 	u8         level[0x8];
 	u8         reserved_at_d0[0x8];
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
