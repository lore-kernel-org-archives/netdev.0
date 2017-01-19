From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/15] net/mlx5: Add MPCNT register infrastructure
Date: Fri, 20 Jan 2017 00:39:05 +0200
Message-ID: <20170119223908.15924-13-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59336 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751807AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add the needed infrastructure for future use of MPCNT register.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/device.h   |  4 ++++
 include/linux/mlx5/driver.h   |  1 +
 include/linux/mlx5/mlx5_ifc.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 5ad1d3ca47dc..1cf97dce8215 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1119,6 +1119,10 @@ enum {
 	MLX5_INFINIBAND_PORT_COUNTERS_GROUP   = 0x20,
 };
 
+enum {
+	MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP       = 0x0,
+};
+
 static inline u16 mlx5_to_sw_pkey_sz(int pkey_sz)
 {
 	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 69c4661d391e..f4d6d390a9cf 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -126,6 +126,7 @@ enum {
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
 	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
+	MLX5_REG_MPCNT		 = 0x9051,
 	MLX5_REG_MTPPS		 = 0x9053,
 	MLX5_REG_MTPPSE		 = 0x9054,
 	MLX5_REG_MCAM		 = 0x907f,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index f4860fa719d9..d96ebc319d63 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1802,6 +1802,30 @@ struct mlx5_ifc_eth_802_3_cntrs_grp_data_layout_bits {
 	u8         reserved_at_4c0[0x300];
 };
 
+struct mlx5_ifc_pcie_perf_cntrs_grp_data_layout_bits {
+	u8         life_time_counter_high[0x20];
+
+	u8         life_time_counter_low[0x20];
+
+	u8         rx_errors[0x20];
+
+	u8         tx_errors[0x20];
+
+	u8         l0_to_recovery_eieos[0x20];
+
+	u8         l0_to_recovery_ts[0x20];
+
+	u8         l0_to_recovery_framing[0x20];
+
+	u8         l0_to_recovery_retrain[0x20];
+
+	u8         crc_error_dllp[0x20];
+
+	u8         crc_error_tlp[0x20];
+
+	u8         reserved_at_140[0x680];
+};
+
 struct mlx5_ifc_cmd_inter_comp_event_bits {
 	u8         command_completion_vector[0x20];
 
@@ -2968,6 +2992,11 @@ union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits {
 	u8         reserved_at_0[0x7c0];
 };
 
+union mlx5_ifc_pcie_cntrs_grp_data_layout_auto_bits {
+	struct mlx5_ifc_pcie_perf_cntrs_grp_data_layout_bits pcie_perf_cntrs_grp_data_layout;
+	u8         reserved_at_0[0x7c0];
+};
+
 union mlx5_ifc_event_auto_bits {
 	struct mlx5_ifc_comp_event_bits comp_event;
 	struct mlx5_ifc_dct_events_bits dct_events;
@@ -7290,6 +7319,18 @@ struct mlx5_ifc_ppcnt_reg_bits {
 	union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits counter_set;
 };
 
+struct mlx5_ifc_mpcnt_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         pcie_index[0x8];
+	u8         reserved_at_10[0xa];
+	u8         grp[0x6];
+
+	u8         clr[0x1];
+	u8         reserved_at_21[0x1f];
+
+	union mlx5_ifc_pcie_cntrs_grp_data_layout_auto_bits counter_set;
+};
+
 struct mlx5_ifc_ppad_reg_bits {
 	u8         reserved_at_0[0x3];
 	u8         single_mac[0x1];
@@ -8006,6 +8047,7 @@ union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_pmtu_reg_bits pmtu_reg;
 	struct mlx5_ifc_ppad_reg_bits ppad_reg;
 	struct mlx5_ifc_ppcnt_reg_bits ppcnt_reg;
+	struct mlx5_ifc_mpcnt_reg_bits mpcnt_reg;
 	struct mlx5_ifc_pplm_reg_bits pplm_reg;
 	struct mlx5_ifc_pplr_reg_bits pplr_reg;
 	struct mlx5_ifc_ppsc_reg_bits ppsc_reg;
-- 
2.11.0
