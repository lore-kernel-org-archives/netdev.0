From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/15] net/mlx5: Add support to s-tag in mlx5 firmware interface
Date: Fri, 20 Jan 2017 00:38:58 +0200
Message-ID: <20170119223908.15924-6-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59334 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751449AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add svlan_tag and rename vlan_tag to cvlan_tag in flow table entry
match param.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                       |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c         | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c         |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c       | 12 ++++++------
 include/linux/mlx5/mlx5_ifc.h                           | 12 +++++++-----
 6 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index a191b9327b0c..8727116a4cab 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1704,9 +1704,9 @@ static int parse_flow_attr(u32 *match_c, u32 *match_v,
 
 		if (ib_spec->eth.mask.vlan_tag) {
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
-				 vlan_tag, 1);
+				 cvlan_tag, 1);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v,
-				 vlan_tag, 1);
+				 cvlan_tag, 1);
 
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
 				 first_vid, ntohs(ib_spec->eth.mask.vlan_tag));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 1fe80de5d68f..7ae0744ea50f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -172,7 +172,7 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 	dest.ft = priv->fs.l2.ft.t;
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
 
 	switch (rule_type) {
 	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
@@ -180,11 +180,11 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 		break;
 	case MLX5E_VLAN_RULE_TYPE_ANY_VID:
 		rule_p = &priv->fs.vlan.any_vlan_rule;
-		MLX5_SET(fte_match_param, spec->match_value, outer_headers.vlan_tag, 1);
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.cvlan_tag, 1);
 		break;
 	default: /* MLX5E_VLAN_RULE_TYPE_MATCH_VID */
 		rule_p = &priv->fs.vlan.active_vlans_rule[vid];
-		MLX5_SET(fte_match_param, spec->match_value, outer_headers.vlan_tag, 1);
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.cvlan_tag, 1);
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria,
 				 outer_headers.first_vid);
 		MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid,
@@ -991,7 +991,7 @@ static int __mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft, u32 *in
 
 	memset(in, 0, inlen);
 	MLX5_SET_CFG(in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.first_vid);
 	MLX5_SET_CFG(in, start_flow_index, ix);
 	ix += MLX5E_VLAN_GROUP0_SIZE;
@@ -1003,7 +1003,7 @@ static int __mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft, u32 *in
 
 	memset(in, 0, inlen);
 	MLX5_SET_CFG(in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.cvlan_tag);
 	MLX5_SET_CFG(in, start_flow_index, ix);
 	ix += MLX5E_VLAN_GROUP1_SIZE;
 	MLX5_SET_CFG(in, end_flow_index, ix - 1);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d088effd7160..4b4323f3c158 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -237,9 +237,9 @@ static int set_flow_attrs(u32 *match_c, u32 *match_v,
 	if ((fs->flow_type & FLOW_EXT) &&
 	    (fs->m_ext.vlan_tci & cpu_to_be16(VLAN_VID_MASK))) {
 		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
-			 vlan_tag, 1);
+			 cvlan_tag, 1);
 		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
-			 vlan_tag, 1);
+			 cvlan_tag, 1);
 		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
 			 first_vid, 0xfff);
 		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 46bef6a26a8c..d4af5507679f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -460,8 +460,8 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 						  FLOW_DISSECTOR_KEY_VLAN,
 						  f->mask);
 		if (mask->vlan_id || mask->vlan_priority) {
-			MLX5_SET(fte_match_set_lyr_2_4, headers_c, vlan_tag, 1);
-			MLX5_SET(fte_match_set_lyr_2_4, headers_v, vlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, cvlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, cvlan_tag, 1);
 
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index f14d9c9ba773..4b3b60be319d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -979,7 +979,7 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.first_vid);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
@@ -1098,7 +1098,7 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
@@ -1115,7 +1115,7 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 
 	memset(flow_group_in, 0, inlen);
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
 
@@ -1254,7 +1254,7 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	}
 
 	if (vport->info.vlan || vport->info.qos)
-		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
+		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
 
 	if (vport->info.spoofchk) {
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.smac_47_16);
@@ -1335,8 +1335,8 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	}
 
 	/* Allowed vlan rule */
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.first_vid);
 	MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid, vport->info.vlan);
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index f5292f3b0301..6f19e4b8574f 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -365,8 +365,8 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
 	u8         ip_protocol[0x8];
 	u8         ip_dscp[0x6];
 	u8         ip_ecn[0x2];
-	u8         vlan_tag[0x1];
-	u8         reserved_at_91[0x1];
+	u8         cvlan_tag[0x1];
+	u8         svlan_tag[0x1];
 	u8         frag[0x1];
 	u8         reserved_at_93[0x4];
 	u8         tcp_flags[0x9];
@@ -398,9 +398,11 @@ struct mlx5_ifc_fte_match_set_misc_bits {
 	u8         inner_second_cfi[0x1];
 	u8         inner_second_vid[0xc];
 
-	u8         outer_second_vlan_tag[0x1];
-	u8         inner_second_vlan_tag[0x1];
-	u8         reserved_at_62[0xe];
+	u8         outer_second_cvlan_tag[0x1];
+	u8         inner_second_cvlan_tag[0x1];
+	u8         outer_second_svlan_tag[0x1];
+	u8         inner_second_svlan_tag[0x1];
+	u8         reserved_at_64[0xc];
 	u8         gre_protocol[0x10];
 
 	u8         gre_key_h[0x18];
-- 
2.11.0
