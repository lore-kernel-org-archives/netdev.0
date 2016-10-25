From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 07/14] net/mlx5: Add PPCNT physical layer statistical group infrastructure
Date: Tue, 25 Oct 2016 18:00:10 +0300
Message-ID: <1477407617-20745-8-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37468 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756387AbcJYPFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:43 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
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
index 5827614..3a6d054 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1057,6 +1057,7 @@ enum {
 	MLX5_PER_PRIORITY_COUNTERS_GROUP      = 0x10,
 	MLX5_PER_TRAFFIC_CLASS_COUNTERS_GROUP = 0x11,
 	MLX5_PHYSICAL_LAYER_COUNTERS_GROUP    = 0x12,
+	MLX5_PHYSICAL_LAYER_STATISTICAL_GROUP = 0x16,
 	MLX5_INFINIBAND_PORT_COUNTERS_GROUP   = 0x20,
 };
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index e610517..88e27d8 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1354,6 +1354,42 @@ struct mlx5_ifc_phys_layer_cntrs_bits {
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
 
@@ -2874,6 +2910,7 @@ union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits {
 	struct mlx5_ifc_eth_per_traffic_grp_data_layout_bits eth_per_traffic_grp_data_layout;
 	struct mlx5_ifc_ib_port_cntrs_grp_data_layout_bits ib_port_cntrs_grp_data_layout;
 	struct mlx5_ifc_phys_layer_cntrs_bits phys_layer_cntrs;
+	struct mlx5_ifc_phys_layer_statistical_cntrs_bits phys_layer_statistical_cntrs;
 	u8         reserved_at_0[0x7c0];
 };
 
-- 
2.7.4
