From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 12/14] net/mlx5: Add support to s-tag in mlx5 firmware interface
Date: Tue, 25 Oct 2016 18:00:15 +0300
Message-ID: <1477407617-20745-13-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add svlan_tag and rename vlan_tag to cvlan_tag in flow table entry
match param.

Signed-off-by: Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c                       |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c         | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c         |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c       | 12 ++++++------
 include/linux/mlx5/mlx5_ifc.h                           | 12 +++++++-----
 6 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d02341e..78307e7 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1557,9 +1557,9 @@ static int parse_flow_attr(u32 *match_c, u32 *match_v,
 
 		if (ib_spec->eth.mask.vlan_tag) {
 			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
-				 vlan_tag, 1);
+				 cvlan_tag, 1);
 			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
-				 vlan_tag, 1);
+				 cvlan_tag, 1);
 
 			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
 				 first_vid, ntohs(ib_spec->eth.mask.vlan_tag));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 36fbc6b..f40503d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -167,7 +167,7 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 	dest.ft = priv->fs.l2.ft.t;
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
 
 	switch (rule_type) {
 	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
@@ -175,11 +175,11 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
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
@@ -983,7 +983,7 @@ static int __mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft, u32 *in
 
 	memset(in, 0, inlen);
 	MLX5_SET_CFG(in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.first_vid);
 	MLX5_SET_CFG(in, start_flow_index, ix);
 	ix += MLX5E_VLAN_GROUP0_SIZE;
@@ -995,7 +995,7 @@ static int __mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft, u32 *in
 
 	memset(in, 0, inlen);
 	MLX5_SET_CFG(in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.cvlan_tag);
 	MLX5_SET_CFG(in, start_flow_index, ix);
 	ix += MLX5E_VLAN_GROUP1_SIZE;
 	MLX5_SET_CFG(in, end_flow_index, ix - 1);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d17c242..ec02158 100644
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
index ce8c54d..4bdc59f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -238,8 +238,8 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 						  FLOW_DISSECTOR_KEY_VLAN,
 						  f->mask);
 		if (mask->vlan_id) {
-			MLX5_SET(fte_match_set_lyr_2_4, headers_c, vlan_tag, 1);
-			MLX5_SET(fte_match_set_lyr_2_4, headers_v, vlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, cvlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, cvlan_tag, 1);
 
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index abbf2c3..b4db329 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -976,7 +976,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.first_vid);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
@@ -1092,7 +1092,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
 
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_47_16);
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.smac_15_0);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
@@ -1109,7 +1109,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 
 	memset(flow_group_in, 0, inlen);
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
-	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, outer_headers.cvlan_tag);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
 
@@ -1240,7 +1240,7 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	}
 
 	if (vport->info.vlan || vport->info.qos)
-		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
+		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
 
 	if (vport->info.spoofchk) {
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.smac_47_16);
@@ -1314,8 +1314,8 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	}
 
 	/* Allowed vlan rule */
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.vlan_tag);
-	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.cvlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, spec->match_value, outer_headers.cvlan_tag);
 	MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.first_vid);
 	MLX5_SET(fte_match_param, spec->match_value, outer_headers.first_vid, vport->info.vlan);
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 8302992..0ac751f 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -359,8 +359,8 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
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
@@ -392,9 +392,11 @@ struct mlx5_ifc_fte_match_set_misc_bits {
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
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
