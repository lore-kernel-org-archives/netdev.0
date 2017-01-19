From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/15] net/mlx5: Move cached hca caps to designated caps struct
Date: Fri, 20 Jan 2017 00:39:07 +0200
Message-ID: <20170119223908.15924-15-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59332 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751502AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

The caps structure consists of hca caps and port/management caps,
all under one roof.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  6 ++--
 include/linux/mlx5/device.h                       | 34 +++++++++++------------
 include/linux/mlx5/driver.h                       |  4 +--
 4 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 0ac7a2fc916c..85ff4b843b4b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1665,7 +1665,7 @@ static int create_leaf_prios(struct mlx5_flow_namespace *ns, int prio,
 
 #define FLOW_TABLE_BIT_SZ 1
 #define GET_FLOW_TABLE_CAP(dev, offset) \
-	((be32_to_cpu(*((__be32 *)(dev->hca_caps_cur[MLX5_CAP_FLOW_TABLE]) +	\
+	((be32_to_cpu(*((__be32 *)(dev->caps.hca_cur[MLX5_CAP_FLOW_TABLE]) +	\
 			offset / 32)) >>					\
 	  (32 - FLOW_TABLE_BIT_SZ - (offset & 0x1f))) & FLOW_TABLE_BIT_SZ)
 static bool has_required_caps(struct mlx5_core_dev *dev, struct node_caps *caps)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 5d160f33bc17..84f7970c5080 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -418,11 +418,11 @@ static int mlx5_core_get_caps_mode(struct mlx5_core_dev *dev,
 
 	switch (cap_mode) {
 	case HCA_CAP_OPMOD_GET_MAX:
-		memcpy(dev->hca_caps_max[cap_type], hca_caps,
+		memcpy(dev->caps.hca_max[cap_type], hca_caps,
 		       MLX5_UN_SZ_BYTES(hca_cap_union));
 		break;
 	case HCA_CAP_OPMOD_GET_CUR:
-		memcpy(dev->hca_caps_cur[cap_type], hca_caps,
+		memcpy(dev->caps.hca_cur[cap_type], hca_caps,
 		       MLX5_UN_SZ_BYTES(hca_cap_union));
 		break;
 	default:
@@ -513,7 +513,7 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 
 	set_hca_cap = MLX5_ADDR_OF(set_hca_cap_in, set_ctx,
 				   capability);
-	memcpy(set_hca_cap, dev->hca_caps_cur[MLX5_CAP_GENERAL],
+	memcpy(set_hca_cap, dev->caps.hca_cur[MLX5_CAP_GENERAL],
 	       MLX5_ST_SZ_BYTES(cmd_hca_cap));
 
 	mlx5_core_dbg(dev, "Current Pkey table size %d Setting new size %d\n",
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 1cf97dce8215..7b6cd67a263f 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -988,36 +988,36 @@ enum mlx5_mcam_feature_groups {
 
 /* GET Dev Caps macros */
 #define MLX5_CAP_GEN(mdev, cap) \
-	MLX5_GET(cmd_hca_cap, mdev->hca_caps_cur[MLX5_CAP_GENERAL], cap)
+	MLX5_GET(cmd_hca_cap, mdev->caps.hca_cur[MLX5_CAP_GENERAL], cap)
 
 #define MLX5_CAP_GEN_MAX(mdev, cap) \
-	MLX5_GET(cmd_hca_cap, mdev->hca_caps_max[MLX5_CAP_GENERAL], cap)
+	MLX5_GET(cmd_hca_cap, mdev->caps.hca_max[MLX5_CAP_GENERAL], cap)
 
 #define MLX5_CAP_ETH(mdev, cap) \
 	MLX5_GET(per_protocol_networking_offload_caps,\
-		 mdev->hca_caps_cur[MLX5_CAP_ETHERNET_OFFLOADS], cap)
+		 mdev->caps.hca_cur[MLX5_CAP_ETHERNET_OFFLOADS], cap)
 
 #define MLX5_CAP_ETH_MAX(mdev, cap) \
 	MLX5_GET(per_protocol_networking_offload_caps,\
-		 mdev->hca_caps_max[MLX5_CAP_ETHERNET_OFFLOADS], cap)
+		 mdev->caps.hca_max[MLX5_CAP_ETHERNET_OFFLOADS], cap)
 
 #define MLX5_CAP_ROCE(mdev, cap) \
-	MLX5_GET(roce_cap, mdev->hca_caps_cur[MLX5_CAP_ROCE], cap)
+	MLX5_GET(roce_cap, mdev->caps.hca_cur[MLX5_CAP_ROCE], cap)
 
 #define MLX5_CAP_ROCE_MAX(mdev, cap) \
-	MLX5_GET(roce_cap, mdev->hca_caps_max[MLX5_CAP_ROCE], cap)
+	MLX5_GET(roce_cap, mdev->caps.hca_max[MLX5_CAP_ROCE], cap)
 
 #define MLX5_CAP_ATOMIC(mdev, cap) \
-	MLX5_GET(atomic_caps, mdev->hca_caps_cur[MLX5_CAP_ATOMIC], cap)
+	MLX5_GET(atomic_caps, mdev->caps.hca_cur[MLX5_CAP_ATOMIC], cap)
 
 #define MLX5_CAP_ATOMIC_MAX(mdev, cap) \
-	MLX5_GET(atomic_caps, mdev->hca_caps_max[MLX5_CAP_ATOMIC], cap)
+	MLX5_GET(atomic_caps, mdev->caps.hca_max[MLX5_CAP_ATOMIC], cap)
 
 #define MLX5_CAP_FLOWTABLE(mdev, cap) \
-	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_cur[MLX5_CAP_FLOW_TABLE], cap)
+	MLX5_GET(flow_table_nic_cap, mdev->caps.hca_cur[MLX5_CAP_FLOW_TABLE], cap)
 
 #define MLX5_CAP_FLOWTABLE_MAX(mdev, cap) \
-	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_max[MLX5_CAP_FLOW_TABLE], cap)
+	MLX5_GET(flow_table_nic_cap, mdev->caps.hca_max[MLX5_CAP_FLOW_TABLE], cap)
 
 #define MLX5_CAP_FLOWTABLE_NIC_RX(mdev, cap) \
 	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.cap)
@@ -1039,11 +1039,11 @@ enum mlx5_mcam_feature_groups {
 
 #define MLX5_CAP_ESW_FLOWTABLE(mdev, cap) \
 	MLX5_GET(flow_table_eswitch_cap, \
-		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
+		 mdev->caps.hca_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
 
 #define MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, cap) \
 	MLX5_GET(flow_table_eswitch_cap, \
-		 mdev->hca_caps_max[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
+		 mdev->caps.hca_max[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
 
 #define MLX5_CAP_ESW_FLOWTABLE_FDB(mdev, cap) \
 	MLX5_CAP_ESW_FLOWTABLE(mdev, flow_table_properties_nic_esw_fdb.cap)
@@ -1065,21 +1065,21 @@ enum mlx5_mcam_feature_groups {
 
 #define MLX5_CAP_ESW(mdev, cap) \
 	MLX5_GET(e_switch_cap, \
-		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH], cap)
+		 mdev->caps.hca_cur[MLX5_CAP_ESWITCH], cap)
 
 #define MLX5_CAP_ESW_MAX(mdev, cap) \
 	MLX5_GET(e_switch_cap, \
-		 mdev->hca_caps_max[MLX5_CAP_ESWITCH], cap)
+		 mdev->caps.hca_max[MLX5_CAP_ESWITCH], cap)
 
 #define MLX5_CAP_ODP(mdev, cap)\
-	MLX5_GET(odp_cap, mdev->hca_caps_cur[MLX5_CAP_ODP], cap)
+	MLX5_GET(odp_cap, mdev->caps.hca_cur[MLX5_CAP_ODP], cap)
 
 #define MLX5_CAP_VECTOR_CALC(mdev, cap) \
 	MLX5_GET(vector_calc_cap, \
-		 mdev->hca_caps_cur[MLX5_CAP_VECTOR_CALC], cap)
+		 mdev->caps.hca_cur[MLX5_CAP_VECTOR_CALC], cap)
 
 #define MLX5_CAP_QOS(mdev, cap)\
-	MLX5_GET(qos_cap, mdev->hca_caps_cur[MLX5_CAP_QOS], cap)
+	MLX5_GET(qos_cap, mdev->caps.hca_cur[MLX5_CAP_QOS], cap)
 
 #define MLX5_CAP_PCAM_FEATURE(mdev, fld) \
 	MLX5_GET(pcam_reg, (mdev)->caps.pcam, feature_cap_mask.enhanced_features.fld)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index f4d6d390a9cf..1bc4641734da 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -738,9 +738,9 @@ struct mlx5_core_dev {
 	char			board_id[MLX5_BOARD_ID_LEN];
 	struct mlx5_cmd		cmd;
 	struct mlx5_port_caps	port_caps[MLX5_MAX_PORTS];
-	u32 hca_caps_cur[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
-	u32 hca_caps_max[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
 	struct {
+		u32 hca_cur[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
+		u32 hca_max[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
 		u32 pcam[MLX5_ST_SZ_DW(pcam_reg)];
 		u32 mcam[MLX5_ST_SZ_DW(mcam_reg)];
 	} caps;
-- 
2.11.0
