From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/12] net/mlx5: Add helper to initialize a flow steering actions struct instance
Date: Wed, 29 Mar 2017 02:27:06 +0300
Message-ID: <20170328232713.29894-6-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42844 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932578AbdC1X2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:02 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

There are bunch of places in the code where the intermediate struct
that keeps the elements related to flow actions is initialized with
the same default values. Put that into a small DECLARE type helper.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c | 14 +++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   | 18 +++---------------
 include/linux/mlx5/fs.h                           |  5 ++++-
 3 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 68419a01db36..c4e9cc79f5c7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -174,13 +174,9 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 				 enum arfs_type type)
 {
 	struct arfs_table *arfs_t = &priv->fs.arfs.arfs_tables[type];
-	struct mlx5_flow_act flow_act = {
-		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
-		.encap_id = 0,
-	};
-	struct mlx5_flow_destination dest;
 	struct mlx5e_tir *tir = priv->indir_tir;
+	struct mlx5_flow_destination dest;
+	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
@@ -469,15 +465,11 @@ static struct arfs_table *arfs_get_table(struct mlx5e_arfs_tables *arfs,
 static struct mlx5_flow_handle *arfs_add_rule(struct mlx5e_priv *priv,
 					      struct arfs_rule *arfs_rule)
 {
-	struct mlx5_flow_act flow_act = {
-		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
-		.encap_id = 0,
-	};
 	struct mlx5e_arfs_tables *arfs = &priv->fs.arfs;
 	struct arfs_tuple *tuple = &arfs_rule->tuple;
 	struct mlx5_flow_handle *rule = NULL;
 	struct mlx5_flow_destination dest;
+	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct arfs_table *arfs_table;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_table *ft;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index f2762e45c8ae..5376d69a6b1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -159,14 +159,10 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 				 enum mlx5e_vlan_rule_type rule_type,
 				 u16 vid, struct mlx5_flow_spec *spec)
 {
-	struct mlx5_flow_act flow_act = {
-		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
-		.encap_id = 0,
-	};
 	struct mlx5_flow_table *ft = priv->fs.vlan.ft.t;
 	struct mlx5_flow_destination dest;
 	struct mlx5_flow_handle **rule_p;
+	MLX5_DECLARE_FLOW_ACT(flow_act);
 	int err = 0;
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
@@ -659,11 +655,7 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 			u16 etype,
 			u8 proto)
 {
-	struct mlx5_flow_act flow_act = {
-		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
-		.encap_id = 0,
-	};
+	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct mlx5_flow_handle *rule;
 	struct mlx5_flow_spec *spec;
 	int err = 0;
@@ -848,13 +840,9 @@ static void mlx5e_del_l2_flow_rule(struct mlx5e_priv *priv,
 static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 				  struct mlx5e_l2_rule *ai, int type)
 {
-	struct mlx5_flow_act flow_act = {
-		.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
-		.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG,
-		.encap_id = 0,
-	};
 	struct mlx5_flow_table *ft = priv->fs.l2.ft.t;
 	struct mlx5_flow_destination dest;
+	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 	u8 *mc_dmac;
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 949b24b6c479..5eea1ba2e593 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -136,6 +136,10 @@ struct mlx5_flow_act {
 	u32 encap_id;
 };
 
+#define MLX5_DECLARE_FLOW_ACT(name) \
+	struct mlx5_flow_act name = {MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,\
+				     MLX5_FS_DEFAULT_FLOW_TAG, 0}
+
 /* Single destination per rule.
  * Group ID is implied by the match criteria.
  */
@@ -156,5 +160,4 @@ struct mlx5_fc *mlx5_fc_create(struct mlx5_core_dev *dev, bool aging);
 void mlx5_fc_destroy(struct mlx5_core_dev *dev, struct mlx5_fc *counter);
 void mlx5_fc_query_cached(struct mlx5_fc *counter,
 			  u64 *bytes, u64 *packets, u64 *lastuse);
-
 #endif
-- 
2.11.0
