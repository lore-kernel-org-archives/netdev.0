From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx5e: Cosmetics: use BIT() instead of "1 <<", and others
Date: Thu, 23 Jul 2015 23:36:00 +0300
Message-ID: <1437683761-28052-6-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39710 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754140AbbGWUhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:37:02 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

No logical change in this commit.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  16 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 166 +++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  20 +--
 3 files changed, 104 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b66edd2..39294f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -330,14 +330,14 @@ struct mlx5e_channel {
 };
 
 enum mlx5e_traffic_types {
-	MLX5E_TT_IPV4_TCP = 0,
-	MLX5E_TT_IPV6_TCP = 1,
-	MLX5E_TT_IPV4_UDP = 2,
-	MLX5E_TT_IPV6_UDP = 3,
-	MLX5E_TT_IPV4     = 4,
-	MLX5E_TT_IPV6     = 5,
-	MLX5E_TT_ANY      = 6,
-	MLX5E_NUM_TT      = 7,
+	MLX5E_TT_IPV4_TCP,
+	MLX5E_TT_IPV6_TCP,
+	MLX5E_TT_IPV4_UDP,
+	MLX5E_TT_IPV6_UDP,
+	MLX5E_TT_IPV4,
+	MLX5E_TT_IPV6,
+	MLX5E_TT_ANY,
+	MLX5E_NUM_TT,
 };
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 120db80..cca34f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -105,25 +105,25 @@ static void mlx5e_del_eth_addr_from_flow_table(struct mlx5e_priv *priv,
 {
 	void *ft = priv->ft.main;
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV6_TCP))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV6_TCP))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6_TCP]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV4_TCP))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV4_TCP))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4_TCP]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV6_UDP))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV6_UDP))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6_UDP]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV4_UDP))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV4_UDP))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4_UDP]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV6))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV6))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_IPV4))
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV4))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4]);
 
-	if (ai->tt_vec & (1 << MLX5E_TT_ANY))
+	if (ai->tt_vec & BIT(MLX5E_TT_ANY))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_ANY]);
 }
 
@@ -156,33 +156,33 @@ static u32 mlx5e_get_tt_vec(struct mlx5e_eth_addr_info *ai, int type)
 		switch (eth_addr_type) {
 		case MLX5E_UC:
 			ret =
-				(1 << MLX5E_TT_IPV4_TCP) |
-				(1 << MLX5E_TT_IPV6_TCP) |
-				(1 << MLX5E_TT_IPV4_UDP) |
-				(1 << MLX5E_TT_IPV6_UDP) |
-				(1 << MLX5E_TT_IPV4)     |
-				(1 << MLX5E_TT_IPV6)     |
-				(1 << MLX5E_TT_ANY)      |
+				BIT(MLX5E_TT_IPV4_TCP)       |
+				BIT(MLX5E_TT_IPV6_TCP)       |
+				BIT(MLX5E_TT_IPV4_UDP)       |
+				BIT(MLX5E_TT_IPV6_UDP)       |
+				BIT(MLX5E_TT_IPV4)           |
+				BIT(MLX5E_TT_IPV6)           |
+				BIT(MLX5E_TT_ANY)            |
 				0;
 			break;
 
 		case MLX5E_MC_IPV4:
 			ret =
-				(1 << MLX5E_TT_IPV4_UDP) |
-				(1 << MLX5E_TT_IPV4)     |
+				BIT(MLX5E_TT_IPV4_UDP)       |
+				BIT(MLX5E_TT_IPV4)           |
 				0;
 			break;
 
 		case MLX5E_MC_IPV6:
 			ret =
-				(1 << MLX5E_TT_IPV6_UDP) |
-				(1 << MLX5E_TT_IPV6)     |
+				BIT(MLX5E_TT_IPV6_UDP)       |
+				BIT(MLX5E_TT_IPV6)           |
 				0;
 			break;
 
 		case MLX5E_MC_OTHER:
 			ret =
-				(1 << MLX5E_TT_ANY)      |
+				BIT(MLX5E_TT_ANY)            |
 				0;
 			break;
 		}
@@ -191,23 +191,23 @@ static u32 mlx5e_get_tt_vec(struct mlx5e_eth_addr_info *ai, int type)
 
 	case MLX5E_ALLMULTI:
 		ret =
-			(1 << MLX5E_TT_IPV4_UDP) |
-			(1 << MLX5E_TT_IPV6_UDP) |
-			(1 << MLX5E_TT_IPV4)     |
-			(1 << MLX5E_TT_IPV6)     |
-			(1 << MLX5E_TT_ANY)      |
+			BIT(MLX5E_TT_IPV4_UDP) |
+			BIT(MLX5E_TT_IPV6_UDP) |
+			BIT(MLX5E_TT_IPV4)     |
+			BIT(MLX5E_TT_IPV6)     |
+			BIT(MLX5E_TT_ANY)      |
 			0;
 		break;
 
 	default: /* MLX5E_PROMISC */
 		ret =
-			(1 << MLX5E_TT_IPV4_TCP) |
-			(1 << MLX5E_TT_IPV6_TCP) |
-			(1 << MLX5E_TT_IPV4_UDP) |
-			(1 << MLX5E_TT_IPV6_UDP) |
-			(1 << MLX5E_TT_IPV4)     |
-			(1 << MLX5E_TT_IPV6)     |
-			(1 << MLX5E_TT_ANY)      |
+			BIT(MLX5E_TT_IPV4_TCP)       |
+			BIT(MLX5E_TT_IPV6_TCP)       |
+			BIT(MLX5E_TT_IPV4_UDP)       |
+			BIT(MLX5E_TT_IPV6_UDP)       |
+			BIT(MLX5E_TT_IPV4)           |
+			BIT(MLX5E_TT_IPV6)           |
+			BIT(MLX5E_TT_ANY)            |
 			0;
 		break;
 	}
@@ -226,6 +226,7 @@ static int __mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
 	u8   *match_criteria_dmac;
 	void *ft   = priv->ft.main;
 	u32  *tirn = priv->tirn;
+	u32  *ft_ix;
 	u32  tt_vec;
 	int  err;
 
@@ -261,51 +262,51 @@ static int __mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
 
 	tt_vec = mlx5e_get_tt_vec(ai, type);
 
-	if (tt_vec & (1 << MLX5E_TT_ANY)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_ANY];
+	if (tt_vec & BIT(MLX5E_TT_ANY)) {
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_ANY]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_ANY]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_ANY);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_ANY);
 	}
 
 	match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
 			 outer_headers.ethertype);
 
-	if (tt_vec & (1 << MLX5E_TT_IPV4)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV4];
+	if (tt_vec & BIT(MLX5E_TT_IPV4)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IP);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV4]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV4]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV4);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV4);
 	}
 
-	if (tt_vec & (1 << MLX5E_TT_IPV6)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV6];
+	if (tt_vec & BIT(MLX5E_TT_IPV6)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IPV6);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV6]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV6]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV6);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV6);
 	}
 
 	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
@@ -313,70 +314,75 @@ static int __mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
 	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
 		 IPPROTO_UDP);
 
-	if (tt_vec & (1 << MLX5E_TT_IPV4_UDP)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV4_UDP];
+	if (tt_vec & BIT(MLX5E_TT_IPV4_UDP)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IP);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV4_UDP]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV4_UDP]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV4_UDP);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV4_UDP);
 	}
 
-	if (tt_vec & (1 << MLX5E_TT_IPV6_UDP)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV6_UDP];
+	if (tt_vec & BIT(MLX5E_TT_IPV6_UDP)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IPV6);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV6_UDP]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV6_UDP]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV6_UDP);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV6_UDP);
 	}
 
 	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
 		 IPPROTO_TCP);
 
-	if (tt_vec & (1 << MLX5E_TT_IPV4_TCP)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV4_TCP];
+	if (tt_vec & BIT(MLX5E_TT_IPV4_TCP)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IP);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV4_TCP]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV4_TCP]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV4_TCP);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV4_TCP);
 	}
 
-	if (tt_vec & (1 << MLX5E_TT_IPV6_TCP)) {
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV6_TCP];
+	if (tt_vec & BIT(MLX5E_TT_IPV6_TCP)) {
 		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
 			 ETH_P_IPV6);
 		MLX5_SET(dest_format_struct, dest, destination_id,
 			 tirn[MLX5E_TT_IPV6_TCP]);
 		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
 						match_criteria, flow_context,
-						&ai->ft_ix[MLX5E_TT_IPV6_TCP]);
-		if (err) {
-			mlx5e_del_eth_addr_from_flow_table(priv, ai);
-			return err;
-		}
-		ai->tt_vec |= (1 << MLX5E_TT_IPV6_TCP);
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV6_TCP);
 	}
 
 	return 0;
+
+err_del_ai:
+	mlx5e_del_eth_addr_from_flow_table(priv, ai);
+
+	return err;
 }
 
 static int mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4a87e9d..8194c32 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1252,13 +1252,13 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 
 #define ROUGH_MAX_L2_L3_HDR_SZ 256
 
-#define MLX5_HASH_IP     (MLX5_HASH_FIELD_SEL_SRC_IP   |\
-			  MLX5_HASH_FIELD_SEL_DST_IP)
+#define MLX5_HASH_IP            (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP)
 
-#define MLX5_HASH_ALL    (MLX5_HASH_FIELD_SEL_SRC_IP   |\
-			  MLX5_HASH_FIELD_SEL_DST_IP   |\
-			  MLX5_HASH_FIELD_SEL_L4_SPORT |\
-			  MLX5_HASH_FIELD_SEL_L4_DPORT)
+#define MLX5_HASH_IP_L4PORTS    (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP   |\
+				 MLX5_HASH_FIELD_SEL_L4_SPORT |\
+				 MLX5_HASH_FIELD_SEL_L4_DPORT)
 
 	if (priv->params.lro_en) {
 		MLX5_SET(tirc, tirc, lro_enable_mask,
@@ -1305,7 +1305,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
 			 MLX5_L4_PROT_TYPE_TCP);
 		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_ALL);
+			 MLX5_HASH_IP_L4PORTS);
 		break;
 
 	case MLX5E_TT_IPV6_TCP:
@@ -1314,7 +1314,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
 			 MLX5_L4_PROT_TYPE_TCP);
 		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_ALL);
+			 MLX5_HASH_IP_L4PORTS);
 		break;
 
 	case MLX5E_TT_IPV4_UDP:
@@ -1323,7 +1323,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
 			 MLX5_L4_PROT_TYPE_UDP);
 		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_ALL);
+			 MLX5_HASH_IP_L4PORTS);
 		break;
 
 	case MLX5E_TT_IPV6_UDP:
@@ -1332,7 +1332,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
 			 MLX5_L4_PROT_TYPE_UDP);
 		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_ALL);
+			 MLX5_HASH_IP_L4PORTS);
 		break;
 
 	case MLX5E_TT_IPV4:
-- 
2.4.3.413.ga5fe668
