From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/15] net/mlx5: Add PPCNT physical layer statistical group infrastructure
Date: Fri, 20 Jan 2017 00:39:03 +0200
Message-ID: <20170119223908.15924-11-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59335 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751871AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add the needed infrastructure for future use of PPCNT physical layer
statistical group.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/device.h   |  1 +
 include/linux/mlx5/mlx5_ifc.h | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index f21528abfb74..5ad1d3ca47dc 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1115,6 +1115,7 @@ enum {
 	MLX5_PER_PRIORITY_COUNTERS_GROUP      = 0x10,
 	MLX5_PER_TRAFFIC_CLASS_COUNTERS_GROUP = 0x11,
 	MLX5_PHYSICAL_LAYER_COUNTERS_GROUP    = 0x12,
+	MLX5_PHYSICAL_LAYER_STATISTICAL_GROUP = 0x16,
 	MLX5_INFINIBAND_PORT_COUNTERS_GROUP   = 0x20,
 };
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index e8061a95326a..f4860fa719d9 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1384,6 +1384,42 @@ struct mlx5_ifc_phys_layer_cntrs_bits {
 	u8         reserved_at_640[0x180];
 };
 
+struct mlx5_ifc_phys_layer_statistical_cntrs_bits {
+	u8         time_since_last_clear_high[0x20];
+
+	u8         time_since_last_clear_low[0x20];
+
+	u8         phy_received_bits_high[0x20];
+
+	u8         phy_received_bits_low[0x20];
+
+	u8         phy_symbol_errors_high[0x20];
+
+	u8         phy_symbol_errors_low[0x20];
+
+	u8         phy_corrected_bits_high[0x20];
+
+	u8         phy_corrected_bits_low[0x20];
+
+	u8         phy_corrected_bits_lane0_high[0x20];
+
+	u8         phy_corrected_bits_lane0_low[0x20];
+
+	u8         phy_corrected_bits_lane1_high[0x20];
+
+	u8         phy_corrected_bits_lane1_low[0x20];
+
+	u8         phy_corrected_bits_lane2_high[0x20];
+
+	u8         phy_corrected_bits_lane2_low[0x20];
+
+	u8         phy_corrected_bits_lane3_high[0x20];
+
+	u8         phy_corrected_bits_lane3_low[0x20];
+
+	u8         reserved_at_200[0x5c0];
+};
+
 struct mlx5_ifc_ib_port_cntrs_grp_data_layout_bits {
 	u8	   symbol_error_counter[0x10];
 
@@ -2928,6 +2964,7 @@ union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits {
 	struct mlx5_ifc_eth_per_traffic_grp_data_layout_bits eth_per_traffic_grp_data_layout;
 	struct mlx5_ifc_ib_port_cntrs_grp_data_layout_bits ib_port_cntrs_grp_data_layout;
 	struct mlx5_ifc_phys_layer_cntrs_bits phys_layer_cntrs;
+	struct mlx5_ifc_phys_layer_statistical_cntrs_bits phys_layer_statistical_cntrs;
 	u8         reserved_at_0[0x7c0];
 };
 
-- 
2.11.0
