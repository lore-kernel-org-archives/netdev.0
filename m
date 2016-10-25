From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 08/14] net/mlx5: Add MPCNT register infrastructure
Date: Tue, 25 Oct 2016 18:00:11 +0300
Message-ID: <1477407617-20745-9-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37464 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755797AbcJYPFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:43 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add the needed infrastructure for future use of MPCNT register.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/device.h   |  5 +++
 include/linux/mlx5/driver.h   |  1 +
 include/linux/mlx5/mlx5_ifc.h | 93 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 99 insertions(+)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 3a6d054..a915a15 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1061,6 +1061,11 @@ enum {
 	MLX5_INFINIBAND_PORT_COUNTERS_GROUP   = 0x20,
 };
 
+enum {
+	MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP       = 0x0,
+	MLX5_PCIE_TIMERS_AND_STATES_COUNTERS_GROUP = 0x2,
+};
+
 static inline u16 mlx5_to_sw_pkey_sz(int pkey_sz)
 {
 	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 85c4786..982c1ce 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -121,6 +121,7 @@ enum {
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
 	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
+	MLX5_REG_MPCNT		 = 0x9051,
 };
 
 enum {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 88e27d8..9cfb688 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1772,6 +1772,80 @@ struct mlx5_ifc_eth_802_3_cntrs_grp_data_layout_bits {
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
+struct mlx5_ifc_pcie_tas_cntrs_grp_data_layout_bits {
+	u8         life_time_counter_high[0x20];
+
+	u8         life_time_counter_low[0x20];
+
+	u8         time_to_boot_image_start[0x20];
+
+	u8         time_to_link_image[0x20];
+
+	u8         calibration_time[0x20];
+
+	u8         time_to_first_perst[0x20];
+
+	u8         time_to_detect_state[0x20];
+
+	u8         time_to_l0[0x20];
+
+	u8         time_to_crs_en[0x20];
+
+	u8         time_to_plastic_image_start[0x20];
+
+	u8         time_to_iron_image_start[0x20];
+
+	u8         perst_handler[0x20];
+
+	u8         times_in_l1[0x20];
+
+	u8         times_in_l23[0x20];
+
+	u8         dl_down[0x20];
+
+	u8         config_cycle1usec[0x20];
+
+	u8         config_cycle2to7usec[0x20];
+
+	u8         config_cycle_8to15usec[0x20];
+
+	u8         config_cycle_16_to_63usec[0x20];
+
+	u8         config_cycle_64usec[0x20];
+
+	u8         correctable_err_msg_sent[0x20];
+
+	u8         non_fatal_err_msg_sent[0x20];
+
+	u8         fatal_err_msg_sent[0x20];
+
+	u8         reserved_at_2e0[0x4e0];
+};
+
 struct mlx5_ifc_cmd_inter_comp_event_bits {
 	u8         command_completion_vector[0x20];
 
@@ -2914,6 +2988,12 @@ union mlx5_ifc_eth_cntrs_grp_data_layout_auto_bits {
 	u8         reserved_at_0[0x7c0];
 };
 
+union mlx5_ifc_pcie_cntrs_grp_data_layout_auto_bits {
+	struct mlx5_ifc_pcie_perf_cntrs_grp_data_layout_bits pcie_perf_cntrs_grp_data_layout;
+	struct mlx5_ifc_pcie_tas_cntrs_grp_data_layout_bits pcie_tas_cntrs_grp_data_layout;
+	u8         reserved_at_0[0x7c0];
+};
+
 union mlx5_ifc_event_auto_bits {
 	struct mlx5_ifc_comp_event_bits comp_event;
 	struct mlx5_ifc_dct_events_bits dct_events;
@@ -7071,6 +7151,18 @@ struct mlx5_ifc_ppcnt_reg_bits {
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
@@ -7676,6 +7768,7 @@ union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_pmtu_reg_bits pmtu_reg;
 	struct mlx5_ifc_ppad_reg_bits ppad_reg;
 	struct mlx5_ifc_ppcnt_reg_bits ppcnt_reg;
+	struct mlx5_ifc_mpcnt_reg_bits mpcnt_reg;
 	struct mlx5_ifc_pplm_reg_bits pplm_reg;
 	struct mlx5_ifc_pplr_reg_bits pplr_reg;
 	struct mlx5_ifc_ppsc_reg_bits ppsc_reg;
-- 
2.7.4
