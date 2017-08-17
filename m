From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/15] net/mlx5: Add RX buffer fullness counters infrastructure
Date: Thu, 17 Aug 2017 16:29:54 +0300
Message-ID: <20170817133003.16900-7-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47143 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752638AbdHQNaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:18 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add capability bit in PCAM register and counters to PPCNT register.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index ba533b39c885..cf7ff52c594e 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1538,7 +1538,17 @@ struct mlx5_ifc_eth_extended_cntrs_grp_data_layout_bits {
 
 	u8         port_transmit_wait_low[0x20];
 
-	u8         reserved_at_40[0x780];
+	u8         reserved_at_40[0x100];
+
+	u8         rx_buffer_almost_full_high[0x20];
+
+	u8         rx_buffer_almost_full_low[0x20];
+
+	u8         rx_buffer_full_high[0x20];
+
+	u8         rx_buffer_full_low[0x20];
+
+	u8         reserved_at_1c0[0x600];
 };
 
 struct mlx5_ifc_eth_3635_cntrs_grp_data_layout_bits {
@@ -7723,8 +7733,9 @@ struct mlx5_ifc_peir_reg_bits {
 };
 
 struct mlx5_ifc_pcam_enhanced_features_bits {
-	u8         reserved_at_0[0x7c];
+	u8         reserved_at_0[0x7b];
 
+	u8         rx_buffer_fullness_counters[0x1];
 	u8         ptys_connector_type[0x1];
 	u8         reserved_at_7d[0x1];
 	u8         ppcnt_discard_group[0x1];
-- 
2.13.0
