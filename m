From: David VomLehn <vomlehn@texas.net>
Subject: [PATCH 04/12] Low-level hardware interfaces
Date: Tue, 27 Dec 2016 05:17:40 -0800
Message-ID: <206766987286d2c30b7f674dec4aafe1ed70a21b.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David VomLehn <vomlehn@texas.net>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:39223 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754785AbcL0Nun (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 08:50:43 -0500
In-Reply-To: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
In-Reply-To: <8aac6eaf6d90651f279392f301de85e6ab72a3cb.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net> <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net> <8aac6eaf6d90651f279392f301de85e6ab72a3cb.1482844668.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definitions of functions that interface directly with the hardware.

Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c | 1033 ++++++++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h |  587 +++++
 .../aquantia/atlantic/hw_atl/hw_atl_llh_internal.h | 2487 ++++++++++++++++++++
 3 files changed, 4107 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh_internal.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
new file mode 100644
index 0000000..4f1b322
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.c
@@ -0,0 +1,1033 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File hw_atl_llh.c: Definitions of bitfield and register access functions for
+ * Atlantic registers.
+ */
+
+#include "hw_atl_llh.h"
+#include "hw_atl_llh_internal.h"
+
+#include "../aq_hw_utils.h"
+
+/* global */
+void reg_glb_cpu_sem_set(struct aq_hw_s *aq_hw, u32 glb_cpu_sem, u32 semaphore)
+{
+	aq_hw_write_reg(aq_hw, glb_cpu_sem_adr(semaphore), glb_cpu_sem);
+}
+
+u32 reg_glb_cpu_sem_get(struct aq_hw_s *aq_hw, u32 semaphore)
+{
+	return aq_hw_read_reg(aq_hw, glb_cpu_sem_adr(semaphore));
+}
+
+void glb_glb_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 glb_reg_res_dis)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, glb_reg_res_dis_adr,
+				  glb_reg_res_dis_msk, glb_reg_res_dis_shift,
+				  glb_reg_res_dis);
+}
+
+void glb_soft_res_set(struct aq_hw_s *aq_hw, u32 soft_res)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, glb_soft_res_adr, glb_soft_res_msk,
+				  glb_soft_res_shift, soft_res);
+}
+
+u32 glb_soft_res_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, glb_soft_res_adr,
+					glb_soft_res_msk,
+					glb_soft_res_shift);
+}
+
+u32 reg_rx_dma_stat_counter7get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, rx_dma_stat_counter7_adr);
+}
+
+u32 reg_glb_mif_id_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, glb_mif_id_adr);
+}
+
+/* stats */
+
+u32 rpb_rx_dma_drop_pkt_cnt_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, rpb_rx_dma_drop_pkt_cnt_adr);
+}
+
+u32 stats_rx_dma_good_octet_counterlsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_rx_dma_good_octet_counterlsw__adr);
+}
+
+u32 stats_rx_dma_good_pkt_counterlsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_rx_dma_good_pkt_counterlsw__adr);
+}
+
+u32 stats_tx_dma_good_octet_counterlsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_tx_dma_good_octet_counterlsw__adr);
+}
+
+u32 stats_tx_dma_good_pkt_counterlsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_tx_dma_good_pkt_counterlsw__adr);
+}
+
+u32 stats_rx_dma_good_octet_countermsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_rx_dma_good_octet_countermsw__adr);
+}
+
+u32 stats_rx_dma_good_pkt_countermsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_rx_dma_good_pkt_countermsw__adr);
+}
+
+u32 stats_tx_dma_good_octet_countermsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_tx_dma_good_octet_countermsw__adr);
+}
+
+u32 stats_tx_dma_good_pkt_countermsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, stats_tx_dma_good_pkt_countermsw__adr);
+}
+
+/* interrupt */
+void itr_irq_auto_masklsw_set(struct aq_hw_s *aq_hw, u32 irq_auto_masklsw)
+{
+	aq_hw_write_reg(aq_hw, itr_iamrlsw_adr, irq_auto_masklsw);
+}
+
+void itr_irq_map_en_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_rx, u32 rx)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_imr_rxren_adr(rx),
+				  itr_imr_rxren_msk(rx),
+				  itr_imr_rxren_shift(rx),
+				  irq_map_en_rx);
+}
+
+void itr_irq_map_en_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_tx, u32 tx)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_imr_txten_adr(tx),
+				  itr_imr_txten_msk(tx),
+				  itr_imr_txten_shift(tx),
+				  irq_map_en_tx);
+}
+
+void itr_irq_map_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_rx, u32 rx)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_imr_rxr_adr(rx),
+				  itr_imr_rxr_msk(rx),
+				  itr_imr_rxr_shift(rx), irq_map_rx);
+}
+
+void itr_irq_map_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_tx, u32 tx)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_imr_txt_adr(tx),
+				  itr_imr_txt_msk(tx),
+				  itr_imr_txt_shift(tx), irq_map_tx);
+}
+
+void itr_irq_msk_clearlsw_set(struct aq_hw_s *aq_hw, u32 irq_msk_clearlsw)
+{
+	aq_hw_write_reg(aq_hw, itr_imcrlsw_adr, irq_msk_clearlsw);
+}
+
+void itr_irq_msk_setlsw_set(struct aq_hw_s *aq_hw, u32 irq_msk_setlsw)
+{
+	aq_hw_write_reg(aq_hw, itr_imsrlsw_adr, irq_msk_setlsw);
+}
+
+void itr_irq_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 irq_reg_res_dis)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_reg_res_dsbl_adr,
+				  itr_reg_res_dsbl_msk,
+				  itr_reg_res_dsbl_shift, irq_reg_res_dis);
+}
+
+void itr_irq_status_clearlsw_set(struct aq_hw_s *aq_hw,	u32 irq_status_clearlsw)
+{
+	aq_hw_write_reg(aq_hw, itr_iscrlsw_adr, irq_status_clearlsw);
+}
+
+u32 itr_irq_statuslsw_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, itr_isrlsw_adr);
+}
+
+u32 itr_res_irq_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, itr_res_adr, itr_res_msk,
+					itr_res_shift);
+}
+
+void itr_res_irq_set(struct aq_hw_s *aq_hw, u32 res_irq)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, itr_res_adr, itr_res_msk,
+				  itr_res_shift,
+				  res_irq);
+}
+
+/* rdm */
+
+void rdm_cpu_id_set(struct aq_hw_s *aq_hw, u32 cpuid, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dcadcpuid_adr(dca),
+				  rdm_dcadcpuid_msk,
+				  rdm_dcadcpuid_shift, cpuid);
+}
+
+void rdm_rx_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_dca_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dca_en_adr, rdm_dca_en_msk,
+				  rdm_dca_en_shift, rx_dca_en);
+}
+
+void rdm_rx_dca_mode_set(struct aq_hw_s *aq_hw, u32 rx_dca_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dca_mode_adr, rdm_dca_mode_msk,
+				  rdm_dca_mode_shift, rx_dca_mode);
+}
+
+void rdm_rx_desc_data_buff_size_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_data_buff_size, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descddata_size_adr(descriptor),
+				  rdm_descddata_size_msk,
+				  rdm_descddata_size_shift,
+				  rx_desc_data_buff_size);
+}
+
+void rdm_rx_desc_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_desc_dca_en, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dcaddesc_en_adr(dca),
+				  rdm_dcaddesc_en_msk,
+				  rdm_dcaddesc_en_shift,
+				  rx_desc_dca_en);
+}
+
+void rdm_rx_desc_en_set(struct aq_hw_s *aq_hw, u32 rx_desc_en, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descden_adr(descriptor),
+				  rdm_descden_msk,
+				  rdm_descden_shift,
+				  rx_desc_en);
+}
+
+void rdm_rx_desc_head_buff_size_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_head_buff_size, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descdhdr_size_adr(descriptor),
+				  rdm_descdhdr_size_msk,
+				  rdm_descdhdr_size_shift,
+				  rx_desc_head_buff_size);
+}
+
+void rdm_rx_desc_head_splitting_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_head_splitting, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descdhdr_split_adr(descriptor),
+				  rdm_descdhdr_split_msk,
+				  rdm_descdhdr_split_shift,
+				  rx_desc_head_splitting);
+}
+
+u32 rdm_rx_desc_head_ptr_get(struct aq_hw_s *aq_hw, u32 descriptor)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, rdm_descdhd_adr(descriptor),
+					rdm_descdhd_msk, rdm_descdhd_shift);
+}
+
+void rdm_rx_desc_len_set(struct aq_hw_s *aq_hw, u32 rx_desc_len, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descdlen_adr(descriptor),
+				  rdm_descdlen_msk, rdm_descdlen_shift,
+				  rx_desc_len);
+}
+
+void rdm_rx_desc_res_set(struct aq_hw_s *aq_hw, u32 rx_desc_res, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_descdreset_adr(descriptor),
+				  rdm_descdreset_msk, rdm_descdreset_shift,
+				  rx_desc_res);
+}
+
+void rdm_rx_desc_wr_wb_irq_en_set(struct aq_hw_s *aq_hw,
+				  u32 rx_desc_wr_wb_irq_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_int_desc_wrb_en_adr,
+				  rdm_int_desc_wrb_en_msk,
+				  rdm_int_desc_wrb_en_shift,
+				  rx_desc_wr_wb_irq_en);
+}
+
+void rdm_rx_head_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_head_dca_en, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dcadhdr_en_adr(dca),
+				  rdm_dcadhdr_en_msk, rdm_dcadhdr_en_shift,
+				  rx_head_dca_en);
+}
+
+void rdm_rx_pld_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_pld_dca_en, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rdm_dcadpay_en_adr(dca),
+				  rdm_dcadpay_en_msk, rdm_dcadpay_en_shift,
+				  rx_pld_dca_en);
+}
+
+/* reg */
+
+void reg_gen_irq_map_set(struct aq_hw_s *aq_hw, u32 gen_intr_map, u32 regidx)
+{
+	aq_hw_write_reg(aq_hw, gen_intr_map_adr(regidx), gen_intr_map);
+}
+
+u32 reg_gen_irq_status_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, gen_intr_stat_adr);
+}
+
+void reg_irq_glb_ctl_set(struct aq_hw_s *aq_hw, u32 intr_glb_ctl)
+{
+	aq_hw_write_reg(aq_hw, intr_glb_ctl_adr, intr_glb_ctl);
+}
+
+void reg_irq_thr_set(struct aq_hw_s *aq_hw, u32 intr_thr, u32 throttle)
+{
+	aq_hw_write_reg(aq_hw, intr_thr_adr(throttle), intr_thr);
+}
+
+void reg_rx_dma_desc_base_addresslswset(struct aq_hw_s *aq_hw,
+					u32 rx_dma_desc_base_addrlsw,
+					u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, rx_dma_desc_base_addrlsw_adr(descriptor),
+			rx_dma_desc_base_addrlsw);
+}
+
+void reg_rx_dma_desc_base_addressmswset(struct aq_hw_s *aq_hw,
+					u32 rx_dma_desc_base_addrmsw,
+					u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, rx_dma_desc_base_addrmsw_adr(descriptor),
+			rx_dma_desc_base_addrmsw);
+}
+
+u32 reg_rx_dma_desc_status_get(struct aq_hw_s *aq_hw, u32 descriptor)
+{
+	return aq_hw_read_reg(aq_hw, rx_dma_desc_stat_adr(descriptor));
+}
+
+void reg_rx_dma_desc_tail_ptr_set(struct aq_hw_s *aq_hw,
+				  u32 rx_dma_desc_tail_ptr, u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, rx_dma_desc_tail_ptr_adr(descriptor),
+			rx_dma_desc_tail_ptr);
+}
+
+void reg_rx_flr_mcst_flr_msk_set(struct aq_hw_s *aq_hw,	u32 rx_flr_mcst_flr_msk)
+{
+	aq_hw_write_reg(aq_hw, rx_flr_mcst_flr_msk_adr, rx_flr_mcst_flr_msk);
+}
+
+void reg_rx_flr_mcst_flr_set(struct aq_hw_s *aq_hw, u32 rx_flr_mcst_flr,
+			     u32 filter)
+{
+	aq_hw_write_reg(aq_hw, rx_flr_mcst_flr_adr(filter), rx_flr_mcst_flr);
+}
+
+void reg_rx_flr_rss_control1set(struct aq_hw_s *aq_hw, u32 rx_flr_rss_control1)
+{
+	aq_hw_write_reg(aq_hw, rx_flr_rss_control1_adr, rx_flr_rss_control1);
+}
+
+void reg_tx_dma_debug_ctl_set(struct aq_hw_s *aq_hw, u32 tx_dma_debug_ctl)
+{
+	aq_hw_write_reg(aq_hw, tx_dma_debug_ctl_adr, tx_dma_debug_ctl);
+}
+
+void reg_tx_dma_desc_base_addresslswset(struct aq_hw_s *aq_hw,
+					u32 tx_dma_desc_base_addrlsw,
+					u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, tx_dma_desc_base_addrlsw_adr(descriptor),
+			tx_dma_desc_base_addrlsw);
+}
+
+void reg_tx_dma_desc_base_addressmswset(struct aq_hw_s *aq_hw,
+					u32 tx_dma_desc_base_addrmsw,
+					u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, tx_dma_desc_base_addrmsw_adr(descriptor),
+			tx_dma_desc_base_addrmsw);
+}
+
+void reg_tx_dma_desc_tail_ptr_set(struct aq_hw_s *aq_hw,
+				  u32 tx_dma_desc_tail_ptr, u32 descriptor)
+{
+	aq_hw_write_reg(aq_hw, tx_dma_desc_tail_ptr_adr(descriptor),
+			tx_dma_desc_tail_ptr);
+}
+
+/* rpb */
+
+void rpb_dma_sys_lbk_set(struct aq_hw_s *aq_hw, u32 dma_sys_lbk)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_dma_sys_lbk_adr,
+				  rpb_dma_sys_lbk_msk,
+				  rpb_dma_sys_lbk_shift, dma_sys_lbk);
+}
+
+void rpb_rpf_rx_traf_class_mode_set(struct aq_hw_s *aq_hw,
+				    u32 rx_traf_class_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rpf_rx_tc_mode_adr,
+				  rpb_rpf_rx_tc_mode_msk,
+				  rpb_rpf_rx_tc_mode_shift,
+				  rx_traf_class_mode);
+}
+
+void rpb_rx_buff_en_set(struct aq_hw_s *aq_hw, u32 rx_buff_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rx_buf_en_adr, rpb_rx_buf_en_msk,
+				  rpb_rx_buf_en_shift, rx_buff_en);
+}
+
+void rpb_rx_buff_hi_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 rx_buff_hi_threshold_per_tc,
+					 u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rxbhi_thresh_adr(buffer),
+				  rpb_rxbhi_thresh_msk, rpb_rxbhi_thresh_shift,
+				  rx_buff_hi_threshold_per_tc);
+}
+
+void rpb_rx_buff_lo_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 rx_buff_lo_threshold_per_tc,
+					 u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rxblo_thresh_adr(buffer),
+				  rpb_rxblo_thresh_msk, rpb_rxblo_thresh_shift,
+				  rx_buff_lo_threshold_per_tc);
+}
+
+void rpb_rx_flow_ctl_mode_set(struct aq_hw_s *aq_hw, u32 rx_flow_ctl_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rx_fc_mode_adr, rpb_rx_fc_mode_msk,
+				  rpb_rx_fc_mode_shift, rx_flow_ctl_mode);
+}
+
+void rpb_rx_pkt_buff_size_per_tc_set(struct aq_hw_s *aq_hw,
+				     u32 rx_pkt_buff_size_per_tc, u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rxbbuf_size_adr(buffer),
+				  rpb_rxbbuf_size_msk, rpb_rxbbuf_size_shift,
+				  rx_pkt_buff_size_per_tc);
+}
+
+void rpb_rx_xoff_en_per_tc_set(struct aq_hw_s *aq_hw, u32 rx_xoff_en_per_tc,
+			       u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpb_rxbxoff_en_adr(buffer),
+				  rpb_rxbxoff_en_msk, rpb_rxbxoff_en_shift,
+				  rx_xoff_en_per_tc);
+}
+
+/* rpf */
+
+void rpfl2broadcast_count_threshold_set(struct aq_hw_s *aq_hw,
+					u32 l2broadcast_count_threshold)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2bc_thresh_adr, rpfl2bc_thresh_msk,
+				  rpfl2bc_thresh_shift,
+				  l2broadcast_count_threshold);
+}
+
+void rpfl2broadcast_en_set(struct aq_hw_s *aq_hw, u32 l2broadcast_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2bc_en_adr, rpfl2bc_en_msk,
+				  rpfl2bc_en_shift, l2broadcast_en);
+}
+
+void rpfl2broadcast_flr_act_set(struct aq_hw_s *aq_hw, u32 l2broadcast_flr_act)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2bc_act_adr, rpfl2bc_act_msk,
+				  rpfl2bc_act_shift, l2broadcast_flr_act);
+}
+
+void rpfl2multicast_flr_en_set(struct aq_hw_s *aq_hw, u32 l2multicast_flr_en,
+			       u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2mc_enf_adr(filter),
+				  rpfl2mc_enf_msk,
+				  rpfl2mc_enf_shift, l2multicast_flr_en);
+}
+
+void rpfl2promiscuous_mode_en_set(struct aq_hw_s *aq_hw,
+				  u32 l2promiscuous_mode_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2promis_mode_adr,
+				  rpfl2promis_mode_msk, rpfl2promis_mode_shift,
+				  l2promiscuous_mode_en);
+}
+
+void rpfl2unicast_flr_act_set(struct aq_hw_s *aq_hw, u32 l2unicast_flr_act,
+			      u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2uc_actf_adr(filter),
+				  rpfl2uc_actf_msk, rpfl2uc_actf_shift,
+				  l2unicast_flr_act);
+}
+
+void rpfl2unicast_flr_en_set(struct aq_hw_s *aq_hw, u32 l2unicast_flr_en,
+			     u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2uc_enf_adr(filter),
+				  rpfl2uc_enf_msk, rpfl2uc_enf_shift,
+				  l2unicast_flr_en);
+}
+
+void rpfl2unicast_dest_addresslsw_set(struct aq_hw_s *aq_hw,
+				      u32 l2unicast_dest_addresslsw,
+				      u32 filter)
+{
+	aq_hw_write_reg(aq_hw, rpfl2uc_daflsw_adr(filter),
+			l2unicast_dest_addresslsw);
+}
+
+void rpfl2unicast_dest_addressmsw_set(struct aq_hw_s *aq_hw,
+				      u32 l2unicast_dest_addressmsw,
+				      u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpfl2uc_dafmsw_adr(filter),
+				  rpfl2uc_dafmsw_msk, rpfl2uc_dafmsw_shift,
+				  l2unicast_dest_addressmsw);
+}
+
+void rpf_rpb_user_priority_tc_map_set(struct aq_hw_s *aq_hw,
+				      u32 user_priority_tc_map, u32 tc)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rpb_rx_tc_upt_adr(tc),
+				  rpf_rpb_rx_tc_upt_msk(tc),
+				  rpf_rpb_rx_tc_upt_shift(tc),
+				  user_priority_tc_map);
+}
+
+void rpf_rss_key_addr_set(struct aq_hw_s *aq_hw, u32 rss_key_addr)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rss_key_addr_adr,
+				  rpf_rss_key_addr_msk, rpf_rss_key_addr_shift,
+				  rss_key_addr);
+}
+
+void rpf_rss_key_wr_data_set(struct aq_hw_s *aq_hw, u32 rss_key_wr_data)
+{
+	aq_hw_write_reg(aq_hw, rpf_rss_key_wr_data_adr, rss_key_wr_data);
+}
+
+u32 rpf_rss_key_wr_en_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, rpf_rss_key_wr_eni_adr,
+					rpf_rss_key_wr_eni_msk,
+					rpf_rss_key_wr_eni_shift);
+}
+
+void rpf_rss_key_wr_en_set(struct aq_hw_s *aq_hw, u32 rss_key_wr_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rss_key_wr_eni_adr,
+				  rpf_rss_key_wr_eni_msk,
+				  rpf_rss_key_wr_eni_shift, rss_key_wr_en);
+}
+
+void rpf_rss_redir_tbl_addr_set(struct aq_hw_s *aq_hw, u32 rss_redir_tbl_addr)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rss_redir_addr_adr,
+				  rpf_rss_redir_addr_msk,
+				  rpf_rss_redir_addr_shift, rss_redir_tbl_addr);
+}
+
+void rpf_rss_redir_tbl_wr_data_set(struct aq_hw_s *aq_hw,
+				   u32 rss_redir_tbl_wr_data)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rss_redir_wr_data_adr,
+				  rpf_rss_redir_wr_data_msk,
+				  rpf_rss_redir_wr_data_shift,
+				  rss_redir_tbl_wr_data);
+}
+
+u32 rpf_rss_redir_wr_en_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, rpf_rss_redir_wr_eni_adr,
+					rpf_rss_redir_wr_eni_msk,
+					rpf_rss_redir_wr_eni_shift);
+}
+
+void rpf_rss_redir_wr_en_set(struct aq_hw_s *aq_hw, u32 rss_redir_wr_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_rss_redir_wr_eni_adr,
+				  rpf_rss_redir_wr_eni_msk,
+				  rpf_rss_redir_wr_eni_shift, rss_redir_wr_en);
+}
+
+void rpf_tpo_to_rpf_sys_lbk_set(struct aq_hw_s *aq_hw, u32 tpo_to_rpf_sys_lbk)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_tpo_rpf_sys_lbk_adr,
+				  rpf_tpo_rpf_sys_lbk_msk,
+				  rpf_tpo_rpf_sys_lbk_shift,
+				  tpo_to_rpf_sys_lbk);
+}
+
+void rpf_vlan_inner_etht_set(struct aq_hw_s *aq_hw, u32 vlan_inner_etht)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_vl_inner_tpid_adr,
+				  rpf_vl_inner_tpid_msk,
+				  rpf_vl_inner_tpid_shift,
+				  vlan_inner_etht);
+}
+
+void rpf_vlan_outer_etht_set(struct aq_hw_s *aq_hw, u32 vlan_outer_etht)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_vl_outer_tpid_adr,
+				  rpf_vl_outer_tpid_msk,
+				  rpf_vl_outer_tpid_shift, vlan_outer_etht);
+}
+
+void rpf_vlan_prom_mode_en_set(struct aq_hw_s *aq_hw, u32 vlan_prom_mode_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_vl_promis_mode_adr,
+				  rpf_vl_promis_mode_msk,
+				  rpf_vl_promis_mode_shift, vlan_prom_mode_en);
+}
+
+void rpf_etht_flr_en_set(struct aq_hw_s *aq_hw, u32 etht_flr_en, u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_enf_adr(filter), rpf_et_enf_msk,
+				  rpf_et_enf_shift, etht_flr_en);
+}
+
+void rpf_etht_user_priority_en_set(struct aq_hw_s *aq_hw,
+				   u32 etht_user_priority_en, u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_upfen_adr(filter),
+				  rpf_et_upfen_msk, rpf_et_upfen_shift,
+				  etht_user_priority_en);
+}
+
+void rpf_etht_rx_queue_en_set(struct aq_hw_s *aq_hw, u32 etht_rx_queue_en,
+			      u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_rxqfen_adr(filter),
+				  rpf_et_rxqfen_msk, rpf_et_rxqfen_shift,
+				  etht_rx_queue_en);
+}
+
+void rpf_etht_user_priority_set(struct aq_hw_s *aq_hw, u32 etht_user_priority,
+				u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_upf_adr(filter), rpf_et_upf_msk,
+				  rpf_et_upf_shift, etht_user_priority);
+}
+
+void rpf_etht_rx_queue_set(struct aq_hw_s *aq_hw, u32 etht_rx_queue, u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_rxqf_adr(filter),
+				  rpf_et_rxqf_msk, rpf_et_rxqf_shift,
+				  etht_rx_queue);
+}
+
+void rpf_etht_mgt_queue_set(struct aq_hw_s *aq_hw, u32 etht_mgt_queue,
+			    u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_mng_rxqf_adr(filter),
+				  rpf_et_mng_rxqf_msk, rpf_et_mng_rxqf_shift,
+				  etht_mgt_queue);
+}
+
+void rpf_etht_flr_act_set(struct aq_hw_s *aq_hw, u32 etht_flr_act, u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_actf_adr(filter),
+				  rpf_et_actf_msk, rpf_et_actf_shift,
+				  etht_flr_act);
+}
+
+void rpf_etht_flr_set(struct aq_hw_s *aq_hw, u32 etht_flr, u32 filter)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpf_et_valf_adr(filter),
+				  rpf_et_valf_msk, rpf_et_valf_shift, etht_flr);
+}
+
+/* rpo */
+
+void rpo_ipv4header_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				       u32 ipv4header_crc_offload_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpo_ipv4chk_en_adr, rpo_ipv4chk_en_msk,
+				  rpo_ipv4chk_en_shift,
+				  ipv4header_crc_offload_en);
+}
+
+void rpo_rx_desc_vlan_stripping_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_vlan_stripping, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpo_descdvl_strip_adr(descriptor),
+				  rpo_descdvl_strip_msk,
+				  rpo_descdvl_strip_shift,
+				  rx_desc_vlan_stripping);
+}
+
+void rpo_tcp_udp_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				    u32 tcp_udp_crc_offload_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rpol4chk_en_adr, rpol4chk_en_msk,
+				  rpol4chk_en_shift, tcp_udp_crc_offload_en);
+}
+
+/* rx */
+
+void rx_rx_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 rx_reg_res_dis)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, rx_reg_res_dsbl_adr,
+				  rx_reg_res_dsbl_msk, rx_reg_res_dsbl_shift,
+				  rx_reg_res_dis);
+}
+
+/* tdm */
+
+void tdm_cpu_id_set(struct aq_hw_s *aq_hw, u32 cpuid, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_dcadcpuid_adr(dca),
+				  tdm_dcadcpuid_msk,
+				  tdm_dcadcpuid_shift, cpuid);
+}
+
+void tdm_large_send_offload_en_set(struct aq_hw_s *aq_hw,
+				   u32 large_send_offload_en)
+{
+	aq_hw_write_reg(aq_hw, tdm_lso_en_adr, large_send_offload_en);
+}
+
+void tdm_tx_dca_en_set(struct aq_hw_s *aq_hw, u32 tx_dca_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_dca_en_adr, tdm_dca_en_msk,
+				  tdm_dca_en_shift, tx_dca_en);
+}
+
+void tdm_tx_dca_mode_set(struct aq_hw_s *aq_hw, u32 tx_dca_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_dca_mode_adr, tdm_dca_mode_msk,
+				  tdm_dca_mode_shift, tx_dca_mode);
+}
+
+void tdm_tx_desc_dca_en_set(struct aq_hw_s *aq_hw, u32 tx_desc_dca_en, u32 dca)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_dcaddesc_en_adr(dca),
+				  tdm_dcaddesc_en_msk, tdm_dcaddesc_en_shift,
+				  tx_desc_dca_en);
+}
+
+void tdm_tx_desc_en_set(struct aq_hw_s *aq_hw, u32 tx_desc_en, u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_descden_adr(descriptor),
+				  tdm_descden_msk,
+				  tdm_descden_shift, tx_desc_en);
+}
+
+u32 tdm_tx_desc_head_ptr_get(struct aq_hw_s *aq_hw, u32 descriptor)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, tdm_descdhd_adr(descriptor),
+					tdm_descdhd_msk, tdm_descdhd_shift);
+}
+
+void tdm_tx_desc_len_set(struct aq_hw_s *aq_hw, u32 tx_desc_len,
+			 u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_descdlen_adr(descriptor),
+				  tdm_descdlen_msk, tdm_descdlen_shift,
+				  tx_desc_len);
+}
+
+void tdm_tx_desc_wr_wb_irq_en_set(struct aq_hw_s *aq_hw,
+				  u32 tx_desc_wr_wb_irq_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_int_desc_wrb_en_adr,
+				  tdm_int_desc_wrb_en_msk,
+				  tdm_int_desc_wrb_en_shift,
+				  tx_desc_wr_wb_irq_en);
+}
+
+void tdm_tx_desc_wr_wb_threshold_set(struct aq_hw_s *aq_hw,
+				     u32 tx_desc_wr_wb_threshold,
+				     u32 descriptor)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tdm_descdwrb_thresh_adr(descriptor),
+				  tdm_descdwrb_thresh_msk,
+				  tdm_descdwrb_thresh_shift,
+				  tx_desc_wr_wb_threshold);
+}
+
+/* thm */
+
+void thm_lso_tcp_flag_of_first_pkt_set(struct aq_hw_s *aq_hw,
+				       u32 lso_tcp_flag_of_first_pkt)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, thm_lso_tcp_flag_first_adr,
+				  thm_lso_tcp_flag_first_msk,
+				  thm_lso_tcp_flag_first_shift,
+				  lso_tcp_flag_of_first_pkt);
+}
+
+void thm_lso_tcp_flag_of_last_pkt_set(struct aq_hw_s *aq_hw,
+				      u32 lso_tcp_flag_of_last_pkt)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, thm_lso_tcp_flag_last_adr,
+				  thm_lso_tcp_flag_last_msk,
+				  thm_lso_tcp_flag_last_shift,
+				  lso_tcp_flag_of_last_pkt);
+}
+
+void thm_lso_tcp_flag_of_middle_pkt_set(struct aq_hw_s *aq_hw,
+					u32 lso_tcp_flag_of_middle_pkt)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, thm_lso_tcp_flag_mid_adr,
+				  thm_lso_tcp_flag_mid_msk,
+				  thm_lso_tcp_flag_mid_shift,
+				  lso_tcp_flag_of_middle_pkt);
+}
+
+/* tpb */
+
+void tpb_tx_buff_en_set(struct aq_hw_s *aq_hw, u32 tx_buff_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_tx_buf_en_adr, tpb_tx_buf_en_msk,
+				  tpb_tx_buf_en_shift, tx_buff_en);
+}
+
+void tpb_tx_buff_hi_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 tx_buff_hi_threshold_per_tc,
+					 u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_txbhi_thresh_adr(buffer),
+				  tpb_txbhi_thresh_msk, tpb_txbhi_thresh_shift,
+				  tx_buff_hi_threshold_per_tc);
+}
+
+void tpb_tx_buff_lo_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 tx_buff_lo_threshold_per_tc,
+					 u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_txblo_thresh_adr(buffer),
+				  tpb_txblo_thresh_msk, tpb_txblo_thresh_shift,
+				  tx_buff_lo_threshold_per_tc);
+}
+
+void tpb_tx_dma_sys_lbk_en_set(struct aq_hw_s *aq_hw, u32 tx_dma_sys_lbk_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_dma_sys_lbk_adr,
+				  tpb_dma_sys_lbk_msk, tpb_dma_sys_lbk_shift,
+				  tx_dma_sys_lbk_en);
+}
+
+void tpb_tx_pkt_buff_size_per_tc_set(struct aq_hw_s *aq_hw,
+				     u32 tx_pkt_buff_size_per_tc, u32 buffer)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_txbbuf_size_adr(buffer),
+				  tpb_txbbuf_size_msk, tpb_txbbuf_size_shift,
+				  tx_pkt_buff_size_per_tc);
+}
+
+void tpb_tx_path_scp_ins_en_set(struct aq_hw_s *aq_hw, u32 tx_path_scp_ins_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpb_tx_scp_ins_en_adr,
+				  tpb_tx_scp_ins_en_msk,
+				  tpb_tx_scp_ins_en_shift, tx_path_scp_ins_en);
+}
+
+/* tpo */
+
+void tpo_ipv4header_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				       u32 ipv4header_crc_offload_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpo_ipv4chk_en_adr, tpo_ipv4chk_en_msk,
+				  tpo_ipv4chk_en_shift,
+				  ipv4header_crc_offload_en);
+}
+
+void tpo_tcp_udp_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				    u32 tcp_udp_crc_offload_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpol4chk_en_adr, tpol4chk_en_msk,
+				  tpol4chk_en_shift, tcp_udp_crc_offload_en);
+}
+
+void tpo_tx_pkt_sys_lbk_en_set(struct aq_hw_s *aq_hw, u32 tx_pkt_sys_lbk_en)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tpo_pkt_sys_lbk_adr,
+				  tpo_pkt_sys_lbk_msk,
+				  tpo_pkt_sys_lbk_shift, tx_pkt_sys_lbk_en);
+}
+
+/* tps */
+
+void tps_tx_pkt_shed_data_arb_mode_set(struct aq_hw_s *aq_hw,
+				       u32 tx_pkt_shed_data_arb_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_data_tc_arb_mode_adr,
+				  tps_data_tc_arb_mode_msk,
+				  tps_data_tc_arb_mode_shift,
+				  tx_pkt_shed_data_arb_mode);
+}
+
+void tps_tx_pkt_shed_desc_rate_curr_time_res_set(struct aq_hw_s *aq_hw,
+						 u32 curr_time_res)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_rate_ta_rst_adr,
+				  tps_desc_rate_ta_rst_msk,
+				  tps_desc_rate_ta_rst_shift,
+				  curr_time_res);
+}
+
+void tps_tx_pkt_shed_desc_rate_lim_set(struct aq_hw_s *aq_hw,
+				       u32 tx_pkt_shed_desc_rate_lim)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_rate_lim_adr,
+				  tps_desc_rate_lim_msk,
+				  tps_desc_rate_lim_shift,
+				  tx_pkt_shed_desc_rate_lim);
+}
+
+void tps_tx_pkt_shed_desc_tc_arb_mode_set(struct aq_hw_s *aq_hw,
+					  u32 tx_pkt_shed_desc_tc_arb_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_tc_arb_mode_adr,
+				  tps_desc_tc_arb_mode_msk,
+				  tps_desc_tc_arb_mode_shift,
+				  tx_pkt_shed_desc_tc_arb_mode);
+}
+
+void tps_tx_pkt_shed_desc_tc_max_credit_set(struct aq_hw_s *aq_hw,
+					    u32 tx_pkt_shed_desc_tc_max_credit,
+					    u32 tc)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_tctcredit_max_adr(tc),
+				  tps_desc_tctcredit_max_msk,
+				  tps_desc_tctcredit_max_shift,
+				  tx_pkt_shed_desc_tc_max_credit);
+}
+
+void tps_tx_pkt_shed_desc_tc_weight_set(struct aq_hw_s *aq_hw,
+					u32 tx_pkt_shed_desc_tc_weight, u32 tc)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_tctweight_adr(tc),
+				  tps_desc_tctweight_msk,
+				  tps_desc_tctweight_shift,
+				  tx_pkt_shed_desc_tc_weight);
+}
+
+void tps_tx_pkt_shed_desc_vm_arb_mode_set(struct aq_hw_s *aq_hw,
+					  u32 tx_pkt_shed_desc_vm_arb_mode)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_desc_vm_arb_mode_adr,
+				  tps_desc_vm_arb_mode_msk,
+				  tps_desc_vm_arb_mode_shift,
+				  tx_pkt_shed_desc_vm_arb_mode);
+}
+
+void tps_tx_pkt_shed_tc_data_max_credit_set(struct aq_hw_s *aq_hw,
+					    u32 tx_pkt_shed_tc_data_max_credit,
+					    u32 tc)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_data_tctcredit_max_adr(tc),
+				  tps_data_tctcredit_max_msk,
+				  tps_data_tctcredit_max_shift,
+				  tx_pkt_shed_tc_data_max_credit);
+}
+
+void tps_tx_pkt_shed_tc_data_weight_set(struct aq_hw_s *aq_hw,
+					u32 tx_pkt_shed_tc_data_weight, u32 tc)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tps_data_tctweight_adr(tc),
+				  tps_data_tctweight_msk,
+				  tps_data_tctweight_shift,
+				  tx_pkt_shed_tc_data_weight);
+}
+
+/* tx */
+
+void tx_tx_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 tx_reg_res_dis)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, tx_reg_res_dsbl_adr,
+				  tx_reg_res_dsbl_msk,
+				  tx_reg_res_dsbl_shift, tx_reg_res_dis);
+}
+
+/* msm */
+
+u32 msm_reg_access_status_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_utils_read_reg_bit(aq_hw, msm_reg_access_busy_adr,
+					msm_reg_access_busy_msk,
+					msm_reg_access_busy_shift);
+}
+
+void msm_reg_addr_for_indirect_addr_set(struct aq_hw_s *aq_hw,
+					u32 reg_addr_for_indirect_addr)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, msm_reg_addr_adr, msm_reg_addr_msk,
+				  msm_reg_addr_shift,
+				  reg_addr_for_indirect_addr);
+}
+
+void msm_reg_rd_strobe_set(struct aq_hw_s *aq_hw, u32 reg_rd_strobe)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, msm_reg_rd_strobe_adr,
+				  msm_reg_rd_strobe_msk,
+				  msm_reg_rd_strobe_shift,
+				  reg_rd_strobe);
+}
+
+u32 msm_reg_rd_data_get(struct aq_hw_s *aq_hw)
+{
+	return aq_hw_read_reg(aq_hw, msm_reg_rd_data_adr);
+}
+
+void msm_reg_wr_data_set(struct aq_hw_s *aq_hw, u32 reg_wr_data)
+{
+	aq_hw_write_reg(aq_hw, msm_reg_wr_data_adr, reg_wr_data);
+}
+
+void msm_reg_wr_strobe_set(struct aq_hw_s *aq_hw, u32 reg_wr_strobe)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, msm_reg_wr_strobe_adr,
+				  msm_reg_wr_strobe_msk,
+				  msm_reg_wr_strobe_shift,
+				  reg_wr_strobe);
+}
+
+/* pci */
+
+void pci_pci_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 pci_reg_res_dis)
+{
+	aq_hw_utils_write_reg_bit(aq_hw, pci_reg_res_dsbl_adr,
+				  pci_reg_res_dsbl_msk, pci_reg_res_dsbl_shift,
+				  pci_reg_res_dis);
+}
+
+void reg_glb_cpu_scratch_scp_set(struct aq_hw_s *aq_hw, u32 glb_cpu_scratch_scp,
+				 u32 scratch_scp)
+{
+	aq_hw_write_reg(aq_hw, glb_cpu_scratch_scp_adr(scratch_scp),
+			glb_cpu_scratch_scp);
+}
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h
new file mode 100644
index 0000000..bf1f866
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh.h
@@ -0,0 +1,587 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File hw_atl_llh.h: Declarations of bitfield and register access functions for
+ * Atlantic registers.
+ */
+
+#ifndef HW_ATL_LLH_H
+#define HW_ATL_LLH_H
+
+#include <linux/types.h>
+
+struct aq_hw_s;
+
+/* global */
+
+/* set global microprocessor semaphore */
+void reg_glb_cpu_sem_set(struct aq_hw_s *aq_hw,	u32 glb_cpu_sem, u32 semaphore);
+
+/* get global microprocessor semaphore */
+u32 reg_glb_cpu_sem_get(struct aq_hw_s *aq_hw, u32 semaphore);
+
+/* set global register reset disable */
+void glb_glb_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 glb_reg_res_dis);
+
+/* set soft reset */
+void glb_soft_res_set(struct aq_hw_s *aq_hw, u32 soft_res);
+
+/* get soft reset */
+u32 glb_soft_res_get(struct aq_hw_s *aq_hw);
+
+/* stats */
+
+u32 rpb_rx_dma_drop_pkt_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get rx dma good octet counter lsw */
+u32 stats_rx_dma_good_octet_counterlsw_get(struct aq_hw_s *aq_hw);
+
+/* get rx dma good packet counter lsw */
+u32 stats_rx_dma_good_pkt_counterlsw_get(struct aq_hw_s *aq_hw);
+
+/* get tx dma good octet counter lsw */
+u32 stats_tx_dma_good_octet_counterlsw_get(struct aq_hw_s *aq_hw);
+
+/* get tx dma good packet counter lsw */
+u32 stats_tx_dma_good_pkt_counterlsw_get(struct aq_hw_s *aq_hw);
+
+/* get rx dma good octet counter msw */
+u32 stats_rx_dma_good_octet_countermsw_get(struct aq_hw_s *aq_hw);
+
+/* get rx dma good packet counter msw */
+u32 stats_rx_dma_good_pkt_countermsw_get(struct aq_hw_s *aq_hw);
+
+/* get tx dma good octet counter msw */
+u32 stats_tx_dma_good_octet_countermsw_get(struct aq_hw_s *aq_hw);
+
+/* get tx dma good packet counter msw */
+u32 stats_tx_dma_good_pkt_countermsw_get(struct aq_hw_s *aq_hw);
+
+/* get msm rx errors counter register */
+u32 reg_mac_msm_rx_errs_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm rx unicast frames counter register */
+u32 reg_mac_msm_rx_ucst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm rx multicast frames counter register */
+u32 reg_mac_msm_rx_mcst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm rx broadcast frames counter register */
+u32 reg_mac_msm_rx_bcst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm rx broadcast octets counter register 1 */
+u32 reg_mac_msm_rx_bcst_octets_counter1get(struct aq_hw_s *aq_hw);
+
+/* get msm rx unicast octets counter register 0 */
+u32 reg_mac_msm_rx_ucst_octets_counter0get(struct aq_hw_s *aq_hw);
+
+/* get rx dma statistics counter 7 */
+u32 reg_rx_dma_stat_counter7get(struct aq_hw_s *aq_hw);
+
+/* get msm tx errors counter register */
+u32 reg_mac_msm_tx_errs_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm tx unicast frames counter register */
+u32 reg_mac_msm_tx_ucst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm tx multicast frames counter register */
+u32 reg_mac_msm_tx_mcst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm tx broadcast frames counter register */
+u32 reg_mac_msm_tx_bcst_frm_cnt_get(struct aq_hw_s *aq_hw);
+
+/* get msm tx multicast octets counter register 1 */
+u32 reg_mac_msm_tx_mcst_octets_counter1get(struct aq_hw_s *aq_hw);
+
+/* get msm tx broadcast octets counter register 1 */
+u32 reg_mac_msm_tx_bcst_octets_counter1get(struct aq_hw_s *aq_hw);
+
+/* get msm tx unicast octets counter register 0 */
+u32 reg_mac_msm_tx_ucst_octets_counter0get(struct aq_hw_s *aq_hw);
+
+/* get global mif identification */
+u32 reg_glb_mif_id_get(struct aq_hw_s *aq_hw);
+
+/* interrupt */
+
+/* set interrupt auto mask lsw */
+void itr_irq_auto_masklsw_set(struct aq_hw_s *aq_hw, u32 irq_auto_masklsw);
+
+/* set interrupt mapping enable rx */
+void itr_irq_map_en_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_rx, u32 rx);
+
+/* set interrupt mapping enable tx */
+void itr_irq_map_en_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_en_tx, u32 tx);
+
+/* set interrupt mapping rx */
+void itr_irq_map_rx_set(struct aq_hw_s *aq_hw, u32 irq_map_rx, u32 rx);
+
+/* set interrupt mapping tx */
+void itr_irq_map_tx_set(struct aq_hw_s *aq_hw, u32 irq_map_tx, u32 tx);
+
+/* set interrupt mask clear lsw */
+void itr_irq_msk_clearlsw_set(struct aq_hw_s *aq_hw, u32 irq_msk_clearlsw);
+
+/* set interrupt mask set lsw */
+void itr_irq_msk_setlsw_set(struct aq_hw_s *aq_hw, u32 irq_msk_setlsw);
+
+/* set interrupt register reset disable */
+void itr_irq_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 irq_reg_res_dis);
+
+/* set interrupt status clear lsw */
+void itr_irq_status_clearlsw_set(struct aq_hw_s *aq_hw,
+				 u32 irq_status_clearlsw);
+
+/* get interrupt status lsw */
+u32 itr_irq_statuslsw_get(struct aq_hw_s *aq_hw);
+
+/* get reset interrupt */
+u32 itr_res_irq_get(struct aq_hw_s *aq_hw);
+
+/* set reset interrupt */
+void itr_res_irq_set(struct aq_hw_s *aq_hw, u32 res_irq);
+
+/* rdm */
+
+/* set cpu id */
+void rdm_cpu_id_set(struct aq_hw_s *aq_hw, u32 cpuid, u32 dca);
+
+/* set rx dca enable */
+void rdm_rx_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_dca_en);
+
+/* set rx dca mode */
+void rdm_rx_dca_mode_set(struct aq_hw_s *aq_hw, u32 rx_dca_mode);
+
+/* set rx descriptor data buffer size */
+void rdm_rx_desc_data_buff_size_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_data_buff_size, u32 descriptor);
+
+/* set rx descriptor dca enable */
+void rdm_rx_desc_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_desc_dca_en, u32 dca);
+
+/* set rx descriptor enable */
+void rdm_rx_desc_en_set(struct aq_hw_s *aq_hw, u32 rx_desc_en, u32 descriptor);
+
+/* set rx descriptor header splitting */
+void rdm_rx_desc_head_splitting_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_head_splitting, u32 descriptor);
+
+/* get rx descriptor head pointer */
+u32 rdm_rx_desc_head_ptr_get(struct aq_hw_s *aq_hw, u32 descriptor);
+
+/* set rx descriptor length */
+void rdm_rx_desc_len_set(struct aq_hw_s *aq_hw, u32 rx_desc_len,
+			 u32 descriptor);
+
+/* set rx descriptor write-back interrupt enable */
+void rdm_rx_desc_wr_wb_irq_en_set(struct aq_hw_s *aq_hw,
+				  u32 rx_desc_wr_wb_irq_en);
+
+/* set rx header dca enable */
+void rdm_rx_head_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_head_dca_en, u32 dca);
+
+/* set rx payload dca enable */
+void rdm_rx_pld_dca_en_set(struct aq_hw_s *aq_hw, u32 rx_pld_dca_en, u32 dca);
+
+/* set rx descriptor header buffer size */
+void rdm_rx_desc_head_buff_size_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_head_buff_size,	u32 descriptor);
+
+/* set rx descriptor reset */
+void rdm_rx_desc_res_set(struct aq_hw_s *aq_hw, u32 rx_desc_res,
+			 u32 descriptor);
+
+/* reg */
+
+/* set general interrupt mapping register */
+void reg_gen_irq_map_set(struct aq_hw_s *aq_hw, u32 gen_intr_map, u32 regidx);
+
+/* get general interrupt status register */
+u32 reg_gen_irq_status_get(struct aq_hw_s *aq_hw);
+
+/* set interrupt global control register */
+void reg_irq_glb_ctl_set(struct aq_hw_s *aq_hw, u32 intr_glb_ctl);
+
+/* set interrupt throttle register */
+void reg_irq_thr_set(struct aq_hw_s *aq_hw, u32 intr_thr, u32 throttle);
+
+/* set rx dma descriptor base address lsw */
+void reg_rx_dma_desc_base_addresslswset(struct aq_hw_s *aq_hw,
+					u32 rx_dma_desc_base_addrlsw,
+					u32 descriptor);
+
+/* set rx dma descriptor base address msw */
+void reg_rx_dma_desc_base_addressmswset(struct aq_hw_s *aq_hw,
+					u32 rx_dma_desc_base_addrmsw,
+					u32 descriptor);
+
+/* get rx dma descriptor status register */
+u32 reg_rx_dma_desc_status_get(struct aq_hw_s *aq_hw, u32 descriptor);
+
+/* set rx dma descriptor tail pointer register */
+void reg_rx_dma_desc_tail_ptr_set(struct aq_hw_s *aq_hw,
+				  u32 rx_dma_desc_tail_ptr,
+				  u32 descriptor);
+
+/* set rx filter multicast filter mask register */
+void reg_rx_flr_mcst_flr_msk_set(struct aq_hw_s *aq_hw,
+				 u32 rx_flr_mcst_flr_msk);
+
+/* set rx filter multicast filter register */
+void reg_rx_flr_mcst_flr_set(struct aq_hw_s *aq_hw, u32 rx_flr_mcst_flr,
+			     u32 filter);
+
+/* set rx filter rss control register 1 */
+void reg_rx_flr_rss_control1set(struct aq_hw_s *aq_hw, u32 rx_flr_rss_control1);
+
+/* set tx dma debug control */
+void reg_tx_dma_debug_ctl_set(struct aq_hw_s *aq_hw, u32 tx_dma_debug_ctl);
+
+/* set tx dma descriptor base address lsw */
+void reg_tx_dma_desc_base_addresslswset(struct aq_hw_s *aq_hw,
+					u32 tx_dma_desc_base_addrlsw,
+					u32 descriptor);
+
+/* set tx dma descriptor base address msw */
+void reg_tx_dma_desc_base_addressmswset(struct aq_hw_s *aq_hw,
+					u32 tx_dma_desc_base_addrmsw,
+					u32 descriptor);
+
+/* set tx dma descriptor tail pointer register */
+void reg_tx_dma_desc_tail_ptr_set(struct aq_hw_s *aq_hw,
+				  u32 tx_dma_desc_tail_ptr,
+				  u32 descriptor);
+
+/* set global microprocessor scratch pad */
+void reg_glb_cpu_scratch_scp_set(struct aq_hw_s *aq_hw,
+				 u32 glb_cpu_scratch_scp, u32 scratch_scp);
+
+/* rpb */
+
+/* set dma system loopback */
+void rpb_dma_sys_lbk_set(struct aq_hw_s *aq_hw, u32 dma_sys_lbk);
+
+/* set rx traffic class mode */
+void rpb_rpf_rx_traf_class_mode_set(struct aq_hw_s *aq_hw,
+				    u32 rx_traf_class_mode);
+
+/* set rx buffer enable */
+void rpb_rx_buff_en_set(struct aq_hw_s *aq_hw, u32 rx_buff_en);
+
+/* set rx buffer high threshold (per tc) */
+void rpb_rx_buff_hi_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 rx_buff_hi_threshold_per_tc,
+					 u32 buffer);
+
+/* set rx buffer low threshold (per tc) */
+void rpb_rx_buff_lo_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 rx_buff_lo_threshold_per_tc,
+					 u32 buffer);
+
+/* set rx flow control mode */
+void rpb_rx_flow_ctl_mode_set(struct aq_hw_s *aq_hw, u32 rx_flow_ctl_mode);
+
+/* set rx packet buffer size (per tc) */
+void rpb_rx_pkt_buff_size_per_tc_set(struct aq_hw_s *aq_hw,
+				     u32 rx_pkt_buff_size_per_tc,
+				     u32 buffer);
+
+/* set rx xoff enable (per tc) */
+void rpb_rx_xoff_en_per_tc_set(struct aq_hw_s *aq_hw, u32 rx_xoff_en_per_tc,
+			       u32 buffer);
+
+/* rpf */
+
+/* set l2 broadcast count threshold */
+void rpfl2broadcast_count_threshold_set(struct aq_hw_s *aq_hw,
+					u32 l2broadcast_count_threshold);
+
+/* set l2 broadcast enable */
+void rpfl2broadcast_en_set(struct aq_hw_s *aq_hw, u32 l2broadcast_en);
+
+/* set l2 broadcast filter action */
+void rpfl2broadcast_flr_act_set(struct aq_hw_s *aq_hw, u32 l2broadcast_flr_act);
+
+/* set l2 multicast filter enable */
+void rpfl2multicast_flr_en_set(struct aq_hw_s *aq_hw, u32 l2multicast_flr_en,
+			       u32 filter);
+
+/* set l2 promiscuous mode enable */
+void rpfl2promiscuous_mode_en_set(struct aq_hw_s *aq_hw,
+				  u32 l2promiscuous_mode_en);
+
+/* set l2 unicast filter action */
+void rpfl2unicast_flr_act_set(struct aq_hw_s *aq_hw, u32 l2unicast_flr_act,
+			      u32 filter);
+
+/* set l2 unicast filter enable */
+void rpfl2unicast_flr_en_set(struct aq_hw_s *aq_hw, u32 l2unicast_flr_en,
+			     u32 filter);
+
+/* set l2 unicast destination address lsw */
+void rpfl2unicast_dest_addresslsw_set(struct aq_hw_s *aq_hw,
+				      u32 l2unicast_dest_addresslsw,
+				      u32 filter);
+
+/* set l2 unicast destination address msw */
+void rpfl2unicast_dest_addressmsw_set(struct aq_hw_s *aq_hw,
+				      u32 l2unicast_dest_addressmsw,
+				      u32 filter);
+
+/* set user-priority tc mapping */
+void rpf_rpb_user_priority_tc_map_set(struct aq_hw_s *aq_hw,
+				      u32 user_priority_tc_map, u32 tc);
+
+/* set rss key address */
+void rpf_rss_key_addr_set(struct aq_hw_s *aq_hw, u32 rss_key_addr);
+
+/* set rss key write data */
+void rpf_rss_key_wr_data_set(struct aq_hw_s *aq_hw, u32 rss_key_wr_data);
+
+/* get rss key write enable */
+u32 rpf_rss_key_wr_en_get(struct aq_hw_s *aq_hw);
+
+/* set rss key write enable */
+void rpf_rss_key_wr_en_set(struct aq_hw_s *aq_hw, u32 rss_key_wr_en);
+
+/* set rss redirection table address */
+void rpf_rss_redir_tbl_addr_set(struct aq_hw_s *aq_hw, u32 rss_redir_tbl_addr);
+
+/* set rss redirection table write data */
+void rpf_rss_redir_tbl_wr_data_set(struct aq_hw_s *aq_hw,
+				   u32 rss_redir_tbl_wr_data);
+
+/* get rss redirection write enable */
+u32 rpf_rss_redir_wr_en_get(struct aq_hw_s *aq_hw);
+
+/* set rss redirection write enable */
+void rpf_rss_redir_wr_en_set(struct aq_hw_s *aq_hw, u32 rss_redir_wr_en);
+
+/* set tpo to rpf system loopback */
+void rpf_tpo_to_rpf_sys_lbk_set(struct aq_hw_s *aq_hw, u32 tpo_to_rpf_sys_lbk);
+
+/* set vlan inner ethertype */
+void rpf_vlan_inner_etht_set(struct aq_hw_s *aq_hw, u32 vlan_inner_etht);
+
+/* set vlan outer ethertype */
+void rpf_vlan_outer_etht_set(struct aq_hw_s *aq_hw, u32 vlan_outer_etht);
+
+/* set vlan promiscuous mode enable */
+void rpf_vlan_prom_mode_en_set(struct aq_hw_s *aq_hw, u32 vlan_prom_mode_en);
+
+/* set ethertype filter enable */
+void rpf_etht_flr_en_set(struct aq_hw_s *aq_hw, u32 etht_flr_en, u32 filter);
+
+/* set  ethertype user-priority enable */
+void rpf_etht_user_priority_en_set(struct aq_hw_s *aq_hw,
+				   u32 etht_user_priority_en, u32 filter);
+
+/* set  ethertype rx queue enable */
+void rpf_etht_rx_queue_en_set(struct aq_hw_s *aq_hw, u32 etht_rx_queue_en,
+			      u32 filter);
+
+/* set ethertype rx queue */
+void rpf_etht_rx_queue_set(struct aq_hw_s *aq_hw, u32 etht_rx_queue,
+			   u32 filter);
+
+/* set ethertype user-priority */
+void rpf_etht_user_priority_set(struct aq_hw_s *aq_hw, u32 etht_user_priority,
+				u32 filter);
+
+/* set ethertype management queue */
+void rpf_etht_mgt_queue_set(struct aq_hw_s *aq_hw, u32 etht_mgt_queue,
+			    u32 filter);
+
+/* set ethertype filter action */
+void rpf_etht_flr_act_set(struct aq_hw_s *aq_hw, u32 etht_flr_act, u32 filter);
+
+/* set ethertype filter */
+void rpf_etht_flr_set(struct aq_hw_s *aq_hw, u32 etht_flr, u32 filter);
+
+/* rpo */
+
+/* set ipv4 header checksum offload enable */
+void rpo_ipv4header_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				       u32 ipv4header_crc_offload_en);
+
+/* set rx descriptor vlan stripping */
+void rpo_rx_desc_vlan_stripping_set(struct aq_hw_s *aq_hw,
+				    u32 rx_desc_vlan_stripping, u32 descriptor);
+
+/* set tcp/udp checksum offload enable */
+void rpo_tcp_udp_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				    u32 tcp_udp_crc_offload_en);
+
+/* rx */
+
+/* set rx register reset disable */
+void rx_rx_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 rx_reg_res_dis);
+
+/* tdm */
+
+/* set cpu id */
+void tdm_cpu_id_set(struct aq_hw_s *aq_hw, u32 cpuid, u32 dca);
+
+/* set large send offload enable */
+void tdm_large_send_offload_en_set(struct aq_hw_s *aq_hw,
+				   u32 large_send_offload_en);
+
+/* set tx descriptor enable */
+void tdm_tx_desc_en_set(struct aq_hw_s *aq_hw, u32 tx_desc_en, u32 descriptor);
+
+/* set tx dca enable */
+void tdm_tx_dca_en_set(struct aq_hw_s *aq_hw, u32 tx_dca_en);
+
+/* set tx dca mode */
+void tdm_tx_dca_mode_set(struct aq_hw_s *aq_hw, u32 tx_dca_mode);
+
+/* set tx descriptor dca enable */
+void tdm_tx_desc_dca_en_set(struct aq_hw_s *aq_hw, u32 tx_desc_dca_en, u32 dca);
+
+/* get tx descriptor head pointer */
+u32 tdm_tx_desc_head_ptr_get(struct aq_hw_s *aq_hw, u32 descriptor);
+
+/* set tx descriptor length */
+void tdm_tx_desc_len_set(struct aq_hw_s *aq_hw, u32 tx_desc_len,
+			 u32 descriptor);
+
+/* set tx descriptor write-back interrupt enable */
+void tdm_tx_desc_wr_wb_irq_en_set(struct aq_hw_s *aq_hw,
+				  u32 tx_desc_wr_wb_irq_en);
+
+/* set tx descriptor write-back threshold */
+void tdm_tx_desc_wr_wb_threshold_set(struct aq_hw_s *aq_hw,
+				     u32 tx_desc_wr_wb_threshold,
+				     u32 descriptor);
+
+/* thm */
+
+/* set lso tcp flag of first packet */
+void thm_lso_tcp_flag_of_first_pkt_set(struct aq_hw_s *aq_hw,
+				       u32 lso_tcp_flag_of_first_pkt);
+
+/* set lso tcp flag of last packet */
+void thm_lso_tcp_flag_of_last_pkt_set(struct aq_hw_s *aq_hw,
+				      u32 lso_tcp_flag_of_last_pkt);
+
+/* set lso tcp flag of middle packet */
+void thm_lso_tcp_flag_of_middle_pkt_set(struct aq_hw_s *aq_hw,
+					u32 lso_tcp_flag_of_middle_pkt);
+
+/* tpb */
+
+/* set tx buffer enable */
+void tpb_tx_buff_en_set(struct aq_hw_s *aq_hw, u32 tx_buff_en);
+
+/* set tx buffer high threshold (per tc) */
+void tpb_tx_buff_hi_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 tx_buff_hi_threshold_per_tc,
+					 u32 buffer);
+
+/* set tx buffer low threshold (per tc) */
+void tpb_tx_buff_lo_threshold_per_tc_set(struct aq_hw_s *aq_hw,
+					 u32 tx_buff_lo_threshold_per_tc,
+					 u32 buffer);
+
+/* set tx dma system loopback enable */
+void tpb_tx_dma_sys_lbk_en_set(struct aq_hw_s *aq_hw, u32 tx_dma_sys_lbk_en);
+
+/* set tx packet buffer size (per tc) */
+void tpb_tx_pkt_buff_size_per_tc_set(struct aq_hw_s *aq_hw,
+				     u32 tx_pkt_buff_size_per_tc, u32 buffer);
+
+/* set tx path pad insert enable */
+void tpb_tx_path_scp_ins_en_set(struct aq_hw_s *aq_hw, u32 tx_path_scp_ins_en);
+
+/* tpo */
+
+/* set ipv4 header checksum offload enable */
+void tpo_ipv4header_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				       u32 ipv4header_crc_offload_en);
+
+/* set tcp/udp checksum offload enable */
+void tpo_tcp_udp_crc_offload_en_set(struct aq_hw_s *aq_hw,
+				    u32 tcp_udp_crc_offload_en);
+
+/* set tx pkt system loopback enable */
+void tpo_tx_pkt_sys_lbk_en_set(struct aq_hw_s *aq_hw, u32 tx_pkt_sys_lbk_en);
+
+/* tps */
+
+/* set tx packet scheduler data arbitration mode */
+void tps_tx_pkt_shed_data_arb_mode_set(struct aq_hw_s *aq_hw,
+				       u32 tx_pkt_shed_data_arb_mode);
+
+/* set tx packet scheduler descriptor rate current time reset */
+void tps_tx_pkt_shed_desc_rate_curr_time_res_set(struct aq_hw_s *aq_hw,
+						 u32 curr_time_res);
+
+/* set tx packet scheduler descriptor rate limit */
+void tps_tx_pkt_shed_desc_rate_lim_set(struct aq_hw_s *aq_hw,
+				       u32 tx_pkt_shed_desc_rate_lim);
+
+/* set tx packet scheduler descriptor tc arbitration mode */
+void tps_tx_pkt_shed_desc_tc_arb_mode_set(struct aq_hw_s *aq_hw,
+					  u32 tx_pkt_shed_desc_tc_arb_mode);
+
+/* set tx packet scheduler descriptor tc max credit */
+void tps_tx_pkt_shed_desc_tc_max_credit_set(struct aq_hw_s *aq_hw,
+					    u32 tx_pkt_shed_desc_tc_max_credit,
+					    u32 tc);
+
+/* set tx packet scheduler descriptor tc weight */
+void tps_tx_pkt_shed_desc_tc_weight_set(struct aq_hw_s *aq_hw,
+					u32 tx_pkt_shed_desc_tc_weight, u32 tc);
+
+/* set tx packet scheduler descriptor vm arbitration mode */
+void tps_tx_pkt_shed_desc_vm_arb_mode_set(struct aq_hw_s *aq_hw,
+					  u32 tx_pkt_shed_desc_vm_arb_mode);
+
+/* set tx packet scheduler tc data max credit */
+void tps_tx_pkt_shed_tc_data_max_credit_set(struct aq_hw_s *aq_hw,
+					    u32 tx_pkt_shed_tc_data_max_credit,
+					    u32 tc);
+
+/* set tx packet scheduler tc data weight */
+void tps_tx_pkt_shed_tc_data_weight_set(struct aq_hw_s *aq_hw,
+					u32 tx_pkt_shed_tc_data_weight, u32 tc);
+
+/* tx */
+
+/* set tx register reset disable */
+void tx_tx_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 tx_reg_res_dis);
+
+/* msm */
+
+/* get register access status */
+u32 msm_reg_access_status_get(struct aq_hw_s *aq_hw);
+
+/* set  register address for indirect address */
+void msm_reg_addr_for_indirect_addr_set(struct aq_hw_s *aq_hw,
+					u32 reg_addr_for_indirect_addr);
+
+/* set register read strobe */
+void msm_reg_rd_strobe_set(struct aq_hw_s *aq_hw, u32 reg_rd_strobe);
+
+/* get  register read data */
+u32 msm_reg_rd_data_get(struct aq_hw_s *aq_hw);
+
+/* set  register write data */
+void msm_reg_wr_data_set(struct aq_hw_s *aq_hw, u32 reg_wr_data);
+
+/* set register write strobe */
+void msm_reg_wr_strobe_set(struct aq_hw_s *aq_hw, u32 reg_wr_strobe);
+
+/* pci */
+
+/* set pci register reset disable */
+void pci_pci_reg_res_dis_set(struct aq_hw_s *aq_hw, u32 pci_reg_res_dis);
+
+#endif /* #ifndef HW_ATL_LLH_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh_internal.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh_internal.h
new file mode 100644
index 0000000..52f3ac2
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_llh_internal.h
@@ -0,0 +1,2487 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File hw_atl_llh_internal.h: Preprocessor definitions for Atlantic registers.
+ */
+
+#ifndef HW_ATL_LLH_INTERNAL_H
+#define HW_ATL_LLH_INTERNAL_H
+
+/* global microprocessor semaphore  definitions
+ * base address: 0x000003a0
+ * parameter: semaphore {s} | stride size 0x4 | range [0, 15]
+ */
+#define glb_cpu_sem_adr(semaphore)  (0x000003a0u + (semaphore) * 0x4)
+/* register address for bitfield rx dma good octet counter lsw [1f:0] */
+#define stats_rx_dma_good_octet_counterlsw__adr 0x00006808
+/* register address for bitfield rx dma good packet counter lsw [1f:0] */
+#define stats_rx_dma_good_pkt_counterlsw__adr 0x00006800
+/* register address for bitfield tx dma good octet counter lsw [1f:0] */
+#define stats_tx_dma_good_octet_counterlsw__adr 0x00008808
+/* register address for bitfield tx dma good packet counter lsw [1f:0] */
+#define stats_tx_dma_good_pkt_counterlsw__adr 0x00008800
+
+/* register address for bitfield rx dma good octet counter msw [3f:20] */
+#define stats_rx_dma_good_octet_countermsw__adr 0x0000680c
+/* register address for bitfield rx dma good packet counter msw [3f:20] */
+#define stats_rx_dma_good_pkt_countermsw__adr 0x00006804
+/* register address for bitfield tx dma good octet counter msw [3f:20] */
+#define stats_tx_dma_good_octet_countermsw__adr 0x0000880c
+/* register address for bitfield tx dma good packet counter msw [3f:20] */
+#define stats_tx_dma_good_pkt_countermsw__adr 0x00008804
+
+/* preprocessor definitions for msm rx errors counter register */
+#define mac_msm_rx_errs_cnt_adr 0x00000120u
+
+/* preprocessor definitions for msm rx unicast frames counter register */
+#define mac_msm_rx_ucst_frm_cnt_adr 0x000000e0u
+
+/* preprocessor definitions for msm rx multicast frames counter register */
+#define mac_msm_rx_mcst_frm_cnt_adr 0x000000e8u
+
+/* preprocessor definitions for msm rx broadcast frames counter register */
+#define mac_msm_rx_bcst_frm_cnt_adr 0x000000f0u
+
+/* preprocessor definitions for msm rx broadcast octets counter register 1 */
+#define mac_msm_rx_bcst_octets_counter1_adr 0x000001b0u
+
+/* preprocessor definitions for msm rx broadcast octets counter register 2 */
+#define mac_msm_rx_bcst_octets_counter2_adr 0x000001b4u
+
+/* preprocessor definitions for msm rx unicast octets counter register 0 */
+#define mac_msm_rx_ucst_octets_counter0_adr 0x000001b8u
+
+/* preprocessor definitions for rx dma statistics counter 7 */
+#define rx_dma_stat_counter7_adr 0x00006818u
+
+/* preprocessor definitions for msm tx unicast frames counter register */
+#define mac_msm_tx_ucst_frm_cnt_adr 0x00000108u
+
+/* preprocessor definitions for msm tx multicast frames counter register */
+#define mac_msm_tx_mcst_frm_cnt_adr 0x00000110u
+
+/* preprocessor definitions for global mif identification */
+#define glb_mif_id_adr 0x0000001cu
+
+/* register address for bitfield iamr_lsw[1f:0] */
+#define itr_iamrlsw_adr 0x00002090
+/* register address for bitfield rx dma drop packet counter [1f:0] */
+#define rpb_rx_dma_drop_pkt_cnt_adr 0x00006818
+
+/* intr imr_rx{r}_en bitfield definitions
+ * preprocessor definitions for the bitfield "imr_rx{r}_en"
+ * parameter: rx {r} | bit-level stride | range [0, 31]
+ * port="pif_itr_map_rx_en_i[0]"
+ */
+#define itr_imr_rxren_adr(rx) \
+	(((rx) == 0) ? 0x00002100 : \
+	(((rx) == 1) ? 0x00002100 : \
+	(((rx) == 2) ? 0x00002104 : \
+	(((rx) == 3) ? 0x00002104 : \
+	(((rx) == 4) ? 0x00002108 : \
+	(((rx) == 5) ? 0x00002108 : \
+	(((rx) == 6) ? 0x0000210c : \
+	(((rx) == 7) ? 0x0000210c : \
+	(((rx) == 8) ? 0x00002110 : \
+	(((rx) == 9) ? 0x00002110 : \
+	(((rx) == 10) ? 0x00002114 : \
+	(((rx) == 11) ? 0x00002114 : \
+	(((rx) == 12) ? 0x00002118 : \
+	(((rx) == 13) ? 0x00002118 : \
+	(((rx) == 14) ? 0x0000211c : \
+	(((rx) == 15) ? 0x0000211c : \
+	(((rx) == 16) ? 0x00002120 : \
+	(((rx) == 17) ? 0x00002120 : \
+	(((rx) == 18) ? 0x00002124 : \
+	(((rx) == 19) ? 0x00002124 : \
+	(((rx) == 20) ? 0x00002128 : \
+	(((rx) == 21) ? 0x00002128 : \
+	(((rx) == 22) ? 0x0000212c : \
+	(((rx) == 23) ? 0x0000212c : \
+	(((rx) == 24) ? 0x00002130 : \
+	(((rx) == 25) ? 0x00002130 : \
+	(((rx) == 26) ? 0x00002134 : \
+	(((rx) == 27) ? 0x00002134 : \
+	(((rx) == 28) ? 0x00002138 : \
+	(((rx) == 29) ? 0x00002138 : \
+	(((rx) == 30) ? 0x0000213c : \
+	(((rx) == 31) ? 0x0000213c : \
+	0))))))))))))))))))))))))))))))))
+
+/* bitmask for bitfield imr_rx{r}_en */
+#define itr_imr_rxren_msk(rx) \
+	(((rx) == 0) ? 0x00008000 : \
+	(((rx) == 1) ? 0x00000080 : \
+	(((rx) == 2) ? 0x00008000 : \
+	(((rx) == 3) ? 0x00000080 : \
+	(((rx) == 4) ? 0x00008000 : \
+	(((rx) == 5) ? 0x00000080 : \
+	(((rx) == 6) ? 0x00008000 : \
+	(((rx) == 7) ? 0x00000080 : \
+	(((rx) == 8) ? 0x00008000 : \
+	(((rx) == 9) ? 0x00000080 : \
+	(((rx) == 10) ? 0x00008000 : \
+	(((rx) == 11) ? 0x00000080 : \
+	(((rx) == 12) ? 0x00008000 : \
+	(((rx) == 13) ? 0x00000080 : \
+	(((rx) == 14) ? 0x00008000 : \
+	(((rx) == 15) ? 0x00000080 : \
+	(((rx) == 16) ? 0x00008000 : \
+	(((rx) == 17) ? 0x00000080 : \
+	(((rx) == 18) ? 0x00008000 : \
+	(((rx) == 19) ? 0x00000080 : \
+	(((rx) == 20) ? 0x00008000 : \
+	(((rx) == 21) ? 0x00000080 : \
+	(((rx) == 22) ? 0x00008000 : \
+	(((rx) == 23) ? 0x00000080 : \
+	(((rx) == 24) ? 0x00008000 : \
+	(((rx) == 25) ? 0x00000080 : \
+	(((rx) == 26) ? 0x00008000 : \
+	(((rx) == 27) ? 0x00000080 : \
+	(((rx) == 28) ? 0x00008000 : \
+	(((rx) == 29) ? 0x00000080 : \
+	(((rx) == 30) ? 0x00008000 : \
+	(((rx) == 31) ? 0x00000080 : \
+	0))))))))))))))))))))))))))))))))
+
+/* lower bit position of bitfield imr_rx{r}_en */
+#define itr_imr_rxren_shift(rx) \
+	(((rx) == 0) ? 15 : \
+	(((rx) == 1) ? 7 : \
+	(((rx) == 2) ? 15 : \
+	(((rx) == 3) ? 7 : \
+	(((rx) == 4) ? 15 : \
+	(((rx) == 5) ? 7 : \
+	(((rx) == 6) ? 15 : \
+	(((rx) == 7) ? 7 : \
+	(((rx) == 8) ? 15 : \
+	(((rx) == 9) ? 7 : \
+	(((rx) == 10) ? 15 : \
+	(((rx) == 11) ? 7 : \
+	(((rx) == 12) ? 15 : \
+	(((rx) == 13) ? 7 : \
+	(((rx) == 14) ? 15 : \
+	(((rx) == 15) ? 7 : \
+	(((rx) == 16) ? 15 : \
+	(((rx) == 17) ? 7 : \
+	(((rx) == 18) ? 15 : \
+	(((rx) == 19) ? 7 : \
+	(((rx) == 20) ? 15 : \
+	(((rx) == 21) ? 7 : \
+	(((rx) == 22) ? 15 : \
+	(((rx) == 23) ? 7 : \
+	(((rx) == 24) ? 15 : \
+	(((rx) == 25) ? 7 : \
+	(((rx) == 26) ? 15 : \
+	(((rx) == 27) ? 7 : \
+	(((rx) == 28) ? 15 : \
+	(((rx) == 29) ? 7 : \
+	(((rx) == 30) ? 15 : \
+	(((rx) == 31) ? 7 : \
+	0))))))))))))))))))))))))))))))))
+
+/* intr imr_tx{t}_en bitfield definitions
+ * preprocessor definitions for the bitfield "imr_tx{t}_en".
+ * parameter: tx {t} | bit-level stride | range [0, 31]
+ * port="pif_itr_map_tx_en_i[0]"
+ */
+
+/* register address for bitfield imr_tx{t}_en */
+#define itr_imr_txten_adr(tx) \
+	(((tx) == 0) ? 0x00002100 : \
+	(((tx) == 1) ? 0x00002100 : \
+	(((tx) == 2) ? 0x00002104 : \
+	(((tx) == 3) ? 0x00002104 : \
+	(((tx) == 4) ? 0x00002108 : \
+	(((tx) == 5) ? 0x00002108 : \
+	(((tx) == 6) ? 0x0000210c : \
+	(((tx) == 7) ? 0x0000210c : \
+	(((tx) == 8) ? 0x00002110 : \
+	(((tx) == 9) ? 0x00002110 : \
+	(((tx) == 10) ? 0x00002114 : \
+	(((tx) == 11) ? 0x00002114 : \
+	(((tx) == 12) ? 0x00002118 : \
+	(((tx) == 13) ? 0x00002118 : \
+	(((tx) == 14) ? 0x0000211c : \
+	(((tx) == 15) ? 0x0000211c : \
+	(((tx) == 16) ? 0x00002120 : \
+	(((tx) == 17) ? 0x00002120 : \
+	(((tx) == 18) ? 0x00002124 : \
+	(((tx) == 19) ? 0x00002124 : \
+	(((tx) == 20) ? 0x00002128 : \
+	(((tx) == 21) ? 0x00002128 : \
+	(((tx) == 22) ? 0x0000212c : \
+	(((tx) == 23) ? 0x0000212c : \
+	(((tx) == 24) ? 0x00002130 : \
+	(((tx) == 25) ? 0x00002130 : \
+	(((tx) == 26) ? 0x00002134 : \
+	(((tx) == 27) ? 0x00002134 : \
+	(((tx) == 28) ? 0x00002138 : \
+	(((tx) == 29) ? 0x00002138 : \
+	(((tx) == 30) ? 0x0000213c : \
+	(((tx) == 31) ? 0x0000213c : \
+	0))))))))))))))))))))))))))))))))
+
+/* bitmask for bitfield imr_tx{t}_en */
+#define itr_imr_txten_msk(tx) \
+	(((tx) == 0) ? 0x80000000 : \
+	(((tx) == 1) ? 0x00800000 : \
+	(((tx) == 2) ? 0x80000000 : \
+	(((tx) == 3) ? 0x00800000 : \
+	(((tx) == 4) ? 0x80000000 : \
+	(((tx) == 5) ? 0x00800000 : \
+	(((tx) == 6) ? 0x80000000 : \
+	(((tx) == 7) ? 0x00800000 : \
+	(((tx) == 8) ? 0x80000000 : \
+	(((tx) == 9) ? 0x00800000 : \
+	(((tx) == 10) ? 0x80000000 : \
+	(((tx) == 11) ? 0x00800000 : \
+	(((tx) == 12) ? 0x80000000 : \
+	(((tx) == 13) ? 0x00800000 : \
+	(((tx) == 14) ? 0x80000000 : \
+	(((tx) == 15) ? 0x00800000 : \
+	(((tx) == 16) ? 0x80000000 : \
+	(((tx) == 17) ? 0x00800000 : \
+	(((tx) == 18) ? 0x80000000 : \
+	(((tx) == 19) ? 0x00800000 : \
+	(((tx) == 20) ? 0x80000000 : \
+	(((tx) == 21) ? 0x00800000 : \
+	(((tx) == 22) ? 0x80000000 : \
+	(((tx) == 23) ? 0x00800000 : \
+	(((tx) == 24) ? 0x80000000 : \
+	(((tx) == 25) ? 0x00800000 : \
+	(((tx) == 26) ? 0x80000000 : \
+	(((tx) == 27) ? 0x00800000 : \
+	(((tx) == 28) ? 0x80000000 : \
+	(((tx) == 29) ? 0x00800000 : \
+	(((tx) == 30) ? 0x80000000 : \
+	(((tx) == 31) ? 0x00800000 : \
+	0))))))))))))))))))))))))))))))))
+
+/* lower bit position of bitfield imr_tx{t}_en */
+#define itr_imr_txten_shift(tx) \
+	(((tx) == 0) ? 31 : \
+	(((tx) == 1) ? 23 : \
+	(((tx) == 2) ? 31 : \
+	(((tx) == 3) ? 23 : \
+	(((tx) == 4) ? 31 : \
+	(((tx) == 5) ? 23 : \
+	(((tx) == 6) ? 31 : \
+	(((tx) == 7) ? 23 : \
+	(((tx) == 8) ? 31 : \
+	(((tx) == 9) ? 23 : \
+	(((tx) == 10) ? 31 : \
+	(((tx) == 11) ? 23 : \
+	(((tx) == 12) ? 31 : \
+	(((tx) == 13) ? 23 : \
+	(((tx) == 14) ? 31 : \
+	(((tx) == 15) ? 23 : \
+	(((tx) == 16) ? 31 : \
+	(((tx) == 17) ? 23 : \
+	(((tx) == 18) ? 31 : \
+	(((tx) == 19) ? 23 : \
+	(((tx) == 20) ? 31 : \
+	(((tx) == 21) ? 23 : \
+	(((tx) == 22) ? 31 : \
+	(((tx) == 23) ? 23 : \
+	(((tx) == 24) ? 31 : \
+	(((tx) == 25) ? 23 : \
+	(((tx) == 26) ? 31 : \
+	(((tx) == 27) ? 23 : \
+	(((tx) == 28) ? 31 : \
+	(((tx) == 29) ? 23 : \
+	(((tx) == 30) ? 31 : \
+	(((tx) == 31) ? 23 : \
+	0))))))))))))))))))))))))))))))))
+
+/* intr imr_rx{r}[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "imr_rx{r}[4:0]"
+ * parameter: rx {r} | bit-level stride | range [0, 31]
+ * port="pif_itr_map_rx0_i[4:0]"
+ */
+
+/* register address for bitfield imr_rx{r}[4:0] */
+#define itr_imr_rxr_adr(rx) \
+	(((rx) == 0) ? 0x00002100 : \
+	(((rx) == 1) ? 0x00002100 : \
+	(((rx) == 2) ? 0x00002104 : \
+	(((rx) == 3) ? 0x00002104 : \
+	(((rx) == 4) ? 0x00002108 : \
+	(((rx) == 5) ? 0x00002108 : \
+	(((rx) == 6) ? 0x0000210c : \
+	(((rx) == 7) ? 0x0000210c : \
+	(((rx) == 8) ? 0x00002110 : \
+	(((rx) == 9) ? 0x00002110 : \
+	(((rx) == 10) ? 0x00002114 : \
+	(((rx) == 11) ? 0x00002114 : \
+	(((rx) == 12) ? 0x00002118 : \
+	(((rx) == 13) ? 0x00002118 : \
+	(((rx) == 14) ? 0x0000211c : \
+	(((rx) == 15) ? 0x0000211c : \
+	(((rx) == 16) ? 0x00002120 : \
+	(((rx) == 17) ? 0x00002120 : \
+	(((rx) == 18) ? 0x00002124 : \
+	(((rx) == 19) ? 0x00002124 : \
+	(((rx) == 20) ? 0x00002128 : \
+	(((rx) == 21) ? 0x00002128 : \
+	(((rx) == 22) ? 0x0000212c : \
+	(((rx) == 23) ? 0x0000212c : \
+	(((rx) == 24) ? 0x00002130 : \
+	(((rx) == 25) ? 0x00002130 : \
+	(((rx) == 26) ? 0x00002134 : \
+	(((rx) == 27) ? 0x00002134 : \
+	(((rx) == 28) ? 0x00002138 : \
+	(((rx) == 29) ? 0x00002138 : \
+	(((rx) == 30) ? 0x0000213c : \
+	(((rx) == 31) ? 0x0000213c : \
+	0))))))))))))))))))))))))))))))))
+
+/* bitmask for bitfield imr_rx{r}[4:0] */
+#define itr_imr_rxr_msk(rx) \
+	(((rx) == 0) ? 0x00001f00 : \
+	(((rx) == 1) ? 0x0000001f : \
+	(((rx) == 2) ? 0x00001f00 : \
+	(((rx) == 3) ? 0x0000001f : \
+	(((rx) == 4) ? 0x00001f00 : \
+	(((rx) == 5) ? 0x0000001f : \
+	(((rx) == 6) ? 0x00001f00 : \
+	(((rx) == 7) ? 0x0000001f : \
+	(((rx) == 8) ? 0x00001f00 : \
+	(((rx) == 9) ? 0x0000001f : \
+	(((rx) == 10) ? 0x00001f00 : \
+	(((rx) == 11) ? 0x0000001f : \
+	(((rx) == 12) ? 0x00001f00 : \
+	(((rx) == 13) ? 0x0000001f : \
+	(((rx) == 14) ? 0x00001f00 : \
+	(((rx) == 15) ? 0x0000001f : \
+	(((rx) == 16) ? 0x00001f00 : \
+	(((rx) == 17) ? 0x0000001f : \
+	(((rx) == 18) ? 0x00001f00 : \
+	(((rx) == 19) ? 0x0000001f : \
+	(((rx) == 20) ? 0x00001f00 : \
+	(((rx) == 21) ? 0x0000001f : \
+	(((rx) == 22) ? 0x00001f00 : \
+	(((rx) == 23) ? 0x0000001f : \
+	(((rx) == 24) ? 0x00001f00 : \
+	(((rx) == 25) ? 0x0000001f : \
+	(((rx) == 26) ? 0x00001f00 : \
+	(((rx) == 27) ? 0x0000001f : \
+	(((rx) == 28) ? 0x00001f00 : \
+	(((rx) == 29) ? 0x0000001f : \
+	(((rx) == 30) ? 0x00001f00 : \
+	(((rx) == 31) ? 0x0000001f : \
+	0))))))))))))))))))))))))))))))))
+
+/* inverted bitmask for bitfield imr_rx{r}[4:0] */
+#define itr_imr_rxr_mskn(rx) \
+	(((rx) == 0) ? 0xffffe0ff : \
+	(((rx) == 1) ? 0xffffffe0 : \
+	(((rx) == 2) ? 0xffffe0ff : \
+	(((rx) == 3) ? 0xffffffe0 : \
+	(((rx) == 4) ? 0xffffe0ff : \
+	(((rx) == 5) ? 0xffffffe0 : \
+	(((rx) == 6) ? 0xffffe0ff : \
+	(((rx) == 7) ? 0xffffffe0 : \
+	(((rx) == 8) ? 0xffffe0ff : \
+	(((rx) == 9) ? 0xffffffe0 : \
+	(((rx) == 10) ? 0xffffe0ff : \
+	(((rx) == 11) ? 0xffffffe0 : \
+	(((rx) == 12) ? 0xffffe0ff : \
+	(((rx) == 13) ? 0xffffffe0 : \
+	(((rx) == 14) ? 0xffffe0ff : \
+	(((rx) == 15) ? 0xffffffe0 : \
+	(((rx) == 16) ? 0xffffe0ff : \
+	(((rx) == 17) ? 0xffffffe0 : \
+	(((rx) == 18) ? 0xffffe0ff : \
+	(((rx) == 19) ? 0xffffffe0 : \
+	(((rx) == 20) ? 0xffffe0ff : \
+	(((rx) == 21) ? 0xffffffe0 : \
+	(((rx) == 22) ? 0xffffe0ff : \
+	(((rx) == 23) ? 0xffffffe0 : \
+	(((rx) == 24) ? 0xffffe0ff : \
+	(((rx) == 25) ? 0xffffffe0 : \
+	(((rx) == 26) ? 0xffffe0ff : \
+	(((rx) == 27) ? 0xffffffe0 : \
+	(((rx) == 28) ? 0xffffe0ff : \
+	(((rx) == 29) ? 0xffffffe0 : \
+	(((rx) == 30) ? 0xffffe0ff : \
+	(((rx) == 31) ? 0xffffffe0 : \
+	0))))))))))))))))))))))))))))))))
+
+/* lower bit position of bitfield imr_rx{r}[4:0] */
+#define itr_imr_rxr_shift(rx) \
+	(((rx) == 0) ? 8 : \
+	(((rx) == 1) ? 0 : \
+	(((rx) == 2) ? 8 : \
+	(((rx) == 3) ? 0 : \
+	(((rx) == 4) ? 8 : \
+	(((rx) == 5) ? 0 : \
+	(((rx) == 6) ? 8 : \
+	(((rx) == 7) ? 0 : \
+	(((rx) == 8) ? 8 : \
+	(((rx) == 9) ? 0 : \
+	(((rx) == 10) ? 8 : \
+	(((rx) == 11) ? 0 : \
+	(((rx) == 12) ? 8 : \
+	(((rx) == 13) ? 0 : \
+	(((rx) == 14) ? 8 : \
+	(((rx) == 15) ? 0 : \
+	(((rx) == 16) ? 8 : \
+	(((rx) == 17) ? 0 : \
+	(((rx) == 18) ? 8 : \
+	(((rx) == 19) ? 0 : \
+	(((rx) == 20) ? 8 : \
+	(((rx) == 21) ? 0 : \
+	(((rx) == 22) ? 8 : \
+	(((rx) == 23) ? 0 : \
+	(((rx) == 24) ? 8 : \
+	(((rx) == 25) ? 0 : \
+	(((rx) == 26) ? 8 : \
+	(((rx) == 27) ? 0 : \
+	(((rx) == 28) ? 8 : \
+	(((rx) == 29) ? 0 : \
+	(((rx) == 30) ? 8 : \
+	(((rx) == 31) ? 0 : \
+	0))))))))))))))))))))))))))))))))
+
+/* intr imr_tx{t}[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "imr_tx{t}[4:0]".
+ * parameter: tx {t} | bit-level stride | range [0, 31]
+ * port="pif_itr_map_tx0_i[4:0]"
+ */
+
+/* register address for bitfield imr_tx{t}[4:0] */
+#define itr_imr_txt_adr(tx) \
+	(((tx) == 0) ? 0x00002100 : \
+	 (((tx) == 1) ? 0x00002100 : \
+	  (((tx) == 2) ? 0x00002104 : \
+	  (((tx) == 3) ? 0x00002104 : \
+	  (((tx) == 4) ? 0x00002108 : \
+	  (((tx) == 5) ? 0x00002108 : \
+	  (((tx) == 6) ? 0x0000210c : \
+	  (((tx) == 7) ? 0x0000210c : \
+	  (((tx) == 8) ? 0x00002110 : \
+	  (((tx) == 9) ? 0x00002110 : \
+	  (((tx) == 10) ? 0x00002114 : \
+	  (((tx) == 11) ? 0x00002114 : \
+	  (((tx) == 12) ? 0x00002118 : \
+	  (((tx) == 13) ? 0x00002118 : \
+	  (((tx) == 14) ? 0x0000211c : \
+	  (((tx) == 15) ? 0x0000211c : \
+	  (((tx) == 16) ? 0x00002120 : \
+	  (((tx) == 17) ? 0x00002120 : \
+	  (((tx) == 18) ? 0x00002124 : \
+	  (((tx) == 19) ? 0x00002124 : \
+	  (((tx) == 20) ? 0x00002128 : \
+	  (((tx) == 21) ? 0x00002128 : \
+	  (((tx) == 22) ? 0x0000212c : \
+	  (((tx) == 23) ? 0x0000212c : \
+	  (((tx) == 24) ? 0x00002130 : \
+	  (((tx) == 25) ? 0x00002130 : \
+	  (((tx) == 26) ? 0x00002134 : \
+	  (((tx) == 27) ? 0x00002134 : \
+	  (((tx) == 28) ? 0x00002138 : \
+	  (((tx) == 29) ? 0x00002138 : \
+	  (((tx) == 30) ? 0x0000213c : \
+	  (((tx) == 31) ? 0x0000213c : \
+	  0))))))))))))))))))))))))))))))))
+
+/* bitmask for bitfield imr_tx{t}[4:0] */
+#define itr_imr_txt_msk(tx) \
+	(((tx) == 0) ? 0x1f000000 : \
+	 (((tx) == 1) ? 0x001f0000 : \
+	  (((tx) == 2) ? 0x1f000000 : \
+	  (((tx) == 3) ? 0x001f0000 : \
+	  (((tx) == 4) ? 0x1f000000 : \
+	  (((tx) == 5) ? 0x001f0000 : \
+	  (((tx) == 6) ? 0x1f000000 : \
+	  (((tx) == 7) ? 0x001f0000 : \
+	  (((tx) == 8) ? 0x1f000000 : \
+	  (((tx) == 9) ? 0x001f0000 : \
+	  (((tx) == 10) ? 0x1f000000 : \
+	  (((tx) == 11) ? 0x001f0000 : \
+	  (((tx) == 12) ? 0x1f000000 : \
+	  (((tx) == 13) ? 0x001f0000 : \
+	  (((tx) == 14) ? 0x1f000000 : \
+	  (((tx) == 15) ? 0x001f0000 : \
+	  (((tx) == 16) ? 0x1f000000 : \
+	  (((tx) == 17) ? 0x001f0000 : \
+	  (((tx) == 18) ? 0x1f000000 : \
+	  (((tx) == 19) ? 0x001f0000 : \
+	  (((tx) == 20) ? 0x1f000000 : \
+	  (((tx) == 21) ? 0x001f0000 : \
+	  (((tx) == 22) ? 0x1f000000 : \
+	  (((tx) == 23) ? 0x001f0000 : \
+	  (((tx) == 24) ? 0x1f000000 : \
+	  (((tx) == 25) ? 0x001f0000 : \
+	  (((tx) == 26) ? 0x1f000000 : \
+	  (((tx) == 27) ? 0x001f0000 : \
+	  (((tx) == 28) ? 0x1f000000 : \
+	  (((tx) == 29) ? 0x001f0000 : \
+	  (((tx) == 30) ? 0x1f000000 : \
+	  (((tx) == 31) ? 0x001f0000 : \
+	  0))))))))))))))))))))))))))))))))
+
+/* inverted bitmask for bitfield imr_tx{t}[4:0] */
+#define itr_imr_txt_mskn(tx) \
+	(((tx) == 0) ? 0xe0ffffff : \
+	 (((tx) == 1) ? 0xffe0ffff : \
+	  (((tx) == 2) ? 0xe0ffffff : \
+	  (((tx) == 3) ? 0xffe0ffff : \
+	  (((tx) == 4) ? 0xe0ffffff : \
+	  (((tx) == 5) ? 0xffe0ffff : \
+	  (((tx) == 6) ? 0xe0ffffff : \
+	  (((tx) == 7) ? 0xffe0ffff : \
+	  (((tx) == 8) ? 0xe0ffffff : \
+	  (((tx) == 9) ? 0xffe0ffff : \
+	  (((tx) == 10) ? 0xe0ffffff : \
+	  (((tx) == 11) ? 0xffe0ffff : \
+	  (((tx) == 12) ? 0xe0ffffff : \
+	  (((tx) == 13) ? 0xffe0ffff : \
+	  (((tx) == 14) ? 0xe0ffffff : \
+	  (((tx) == 15) ? 0xffe0ffff : \
+	  (((tx) == 16) ? 0xe0ffffff : \
+	  (((tx) == 17) ? 0xffe0ffff : \
+	  (((tx) == 18) ? 0xe0ffffff : \
+	  (((tx) == 19) ? 0xffe0ffff : \
+	  (((tx) == 20) ? 0xe0ffffff : \
+	  (((tx) == 21) ? 0xffe0ffff : \
+	  (((tx) == 22) ? 0xe0ffffff : \
+	  (((tx) == 23) ? 0xffe0ffff : \
+	  (((tx) == 24) ? 0xe0ffffff : \
+	  (((tx) == 25) ? 0xffe0ffff : \
+	  (((tx) == 26) ? 0xe0ffffff : \
+	  (((tx) == 27) ? 0xffe0ffff : \
+	  (((tx) == 28) ? 0xe0ffffff : \
+	  (((tx) == 29) ? 0xffe0ffff : \
+	  (((tx) == 30) ? 0xe0ffffff : \
+	  (((tx) == 31) ? 0xffe0ffff : \
+	  0))))))))))))))))))))))))))))))))
+
+/* lower bit position of bitfield imr_tx{t}[4:0] */
+#define itr_imr_txt_shift(tx) \
+	(((tx) == 0) ? 24 : \
+	 (((tx) == 1) ? 16 : \
+	  (((tx) == 2) ? 24 : \
+	  (((tx) == 3) ? 16 : \
+	  (((tx) == 4) ? 24 : \
+	  (((tx) == 5) ? 16 : \
+	  (((tx) == 6) ? 24 : \
+	  (((tx) == 7) ? 16 : \
+	  (((tx) == 8) ? 24 : \
+	  (((tx) == 9) ? 16 : \
+	  (((tx) == 10) ? 24 : \
+	  (((tx) == 11) ? 16 : \
+	  (((tx) == 12) ? 24 : \
+	  (((tx) == 13) ? 16 : \
+	  (((tx) == 14) ? 24 : \
+	  (((tx) == 15) ? 16 : \
+	  (((tx) == 16) ? 24 : \
+	  (((tx) == 17) ? 16 : \
+	  (((tx) == 18) ? 24 : \
+	  (((tx) == 19) ? 16 : \
+	  (((tx) == 20) ? 24 : \
+	  (((tx) == 21) ? 16 : \
+	  (((tx) == 22) ? 24 : \
+	  (((tx) == 23) ? 16 : \
+	  (((tx) == 24) ? 24 : \
+	  (((tx) == 25) ? 16 : \
+	  (((tx) == 26) ? 24 : \
+	  (((tx) == 27) ? 16 : \
+	  (((tx) == 28) ? 24 : \
+	  (((tx) == 29) ? 16 : \
+	  (((tx) == 30) ? 24 : \
+	  (((tx) == 31) ? 16 : \
+	  0))))))))))))))))))))))))))))))))
+
+/* register address for bitfield imcr_lsw[1f:0] */
+#define itr_imcrlsw_adr 0x00002070
+/* register address for bitfield imsr_lsw[1f:0] */
+#define itr_imsrlsw_adr 0x00002060
+/* register address for bitfield itr_reg_res_dsbl */
+#define itr_reg_res_dsbl_adr 0x00002300
+/* bitmask for bitfield itr_reg_res_dsbl */
+#define itr_reg_res_dsbl_msk 0x20000000
+/* lower bit position of bitfield itr_reg_res_dsbl */
+#define itr_reg_res_dsbl_shift 29
+/* register address for bitfield iscr_lsw[1f:0] */
+#define itr_iscrlsw_adr 0x00002050
+/* register address for bitfield isr_lsw[1f:0] */
+#define itr_isrlsw_adr 0x00002000
+/* register address for bitfield itr_reset */
+#define itr_res_adr 0x00002300
+/* bitmask for bitfield itr_reset */
+#define itr_res_msk 0x80000000
+/* lower bit position of bitfield itr_reset */
+#define itr_res_shift 31
+/* register address for bitfield dca{d}_cpuid[7:0] */
+#define rdm_dcadcpuid_adr(dca) (0x00006100 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_cpuid[7:0] */
+#define rdm_dcadcpuid_msk 0x000000ff
+/* lower bit position of bitfield dca{d}_cpuid[7:0] */
+#define rdm_dcadcpuid_shift 0
+/* register address for bitfield dca_en */
+#define rdm_dca_en_adr 0x00006180
+
+/*
+ * rx dca_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca_en".
+ * port="pif_rdm_dca_en_i"
+ */
+
+/* register address for bitfield dca_en */
+#define rdm_dca_en_adr 0x00006180
+/* bitmask for bitfield dca_en */
+#define rdm_dca_en_msk 0x80000000
+/* inverted bitmask for bitfield dca_en */
+#define rdm_dca_en_mskn 0x7fffffff
+/* lower bit position of bitfield dca_en */
+#define rdm_dca_en_shift 31
+/* width of bitfield dca_en */
+#define rdm_dca_en_width 1
+/* default value of bitfield dca_en */
+#define rdm_dca_en_default 0x1
+
+/*
+ * rx dca_mode[3:0] bitfield definitions
+ * preprocessor definitions for the bitfield "dca_mode[3:0]".
+ * port="pif_rdm_dca_mode_i[3:0]"
+ */
+
+/* register address for bitfield dca_mode[3:0] */
+#define rdm_dca_mode_adr 0x00006180
+/* bitmask for bitfield dca_mode[3:0] */
+#define rdm_dca_mode_msk 0x0000000f
+/* inverted bitmask for bitfield dca_mode[3:0] */
+#define rdm_dca_mode_mskn 0xfffffff0
+/* lower bit position of bitfield dca_mode[3:0] */
+#define rdm_dca_mode_shift 0
+/* width of bitfield dca_mode[3:0] */
+#define rdm_dca_mode_width 4
+/* default value of bitfield dca_mode[3:0] */
+#define rdm_dca_mode_default 0x0
+
+/* rx desc{d}_data_size[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_data_size[4:0]".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_desc0_data_size_i[4:0]"
+ */
+
+/* register address for bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_adr(descriptor) (0x00005b18 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_msk 0x0000001f
+/* inverted bitmask for bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_mskn 0xffffffe0
+/* lower bit position of bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_shift 0
+/* width of bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_width 5
+/* default value of bitfield desc{d}_data_size[4:0] */
+#define rdm_descddata_size_default 0x0
+
+/* rx dca{d}_desc_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca{d}_desc_en".
+ * parameter: dca {d} | stride size 0x4 | range [0, 31]
+ * port="pif_rdm_dca_desc_en_i[0]"
+ */
+
+/* register address for bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_adr(dca) (0x00006100 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_msk 0x80000000
+/* inverted bitmask for bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_mskn 0x7fffffff
+/* lower bit position of bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_shift 31
+/* width of bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_width 1
+/* default value of bitfield dca{d}_desc_en */
+#define rdm_dcaddesc_en_default 0x0
+
+/* rx desc{d}_en bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_en".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_desc_en_i[0]"
+ */
+
+/* register address for bitfield desc{d}_en */
+#define rdm_descden_adr(descriptor) (0x00005b08 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_en */
+#define rdm_descden_msk 0x80000000
+/* inverted bitmask for bitfield desc{d}_en */
+#define rdm_descden_mskn 0x7fffffff
+/* lower bit position of bitfield desc{d}_en */
+#define rdm_descden_shift 31
+/* width of bitfield desc{d}_en */
+#define rdm_descden_width 1
+/* default value of bitfield desc{d}_en */
+#define rdm_descden_default 0x0
+
+/* rx desc{d}_hdr_size[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_hdr_size[4:0]".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_desc0_hdr_size_i[4:0]"
+ */
+
+/* register address for bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_adr(descriptor) (0x00005b18 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_msk 0x00001f00
+/* inverted bitmask for bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_mskn 0xffffe0ff
+/* lower bit position of bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_shift 8
+/* width of bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_width 5
+/* default value of bitfield desc{d}_hdr_size[4:0] */
+#define rdm_descdhdr_size_default 0x0
+
+/* rx desc{d}_hdr_split bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_hdr_split".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_desc_hdr_split_i[0]"
+ */
+
+/* register address for bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_adr(descriptor) (0x00005b08 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_msk 0x10000000
+/* inverted bitmask for bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_mskn 0xefffffff
+/* lower bit position of bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_shift 28
+/* width of bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_width 1
+/* default value of bitfield desc{d}_hdr_split */
+#define rdm_descdhdr_split_default 0x0
+
+/* rx desc{d}_hd[c:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_hd[c:0]".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="rdm_pif_desc0_hd_o[12:0]"
+ */
+
+/* register address for bitfield desc{d}_hd[c:0] */
+#define rdm_descdhd_adr(descriptor) (0x00005b0c + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_hd[c:0] */
+#define rdm_descdhd_msk 0x00001fff
+/* inverted bitmask for bitfield desc{d}_hd[c:0] */
+#define rdm_descdhd_mskn 0xffffe000
+/* lower bit position of bitfield desc{d}_hd[c:0] */
+#define rdm_descdhd_shift 0
+/* width of bitfield desc{d}_hd[c:0] */
+#define rdm_descdhd_width 13
+
+/* rx desc{d}_len[9:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_len[9:0]".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_desc0_len_i[9:0]"
+ */
+
+/* register address for bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_adr(descriptor) (0x00005b08 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_msk 0x00001ff8
+/* inverted bitmask for bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_mskn 0xffffe007
+/* lower bit position of bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_shift 3
+/* width of bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_width 10
+/* default value of bitfield desc{d}_len[9:0] */
+#define rdm_descdlen_default 0x0
+
+/* rx desc{d}_reset bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_reset".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rdm_q_pf_res_i[0]"
+ */
+
+/* register address for bitfield desc{d}_reset */
+#define rdm_descdreset_adr(descriptor) (0x00005b08 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_reset */
+#define rdm_descdreset_msk 0x02000000
+/* inverted bitmask for bitfield desc{d}_reset */
+#define rdm_descdreset_mskn 0xfdffffff
+/* lower bit position of bitfield desc{d}_reset */
+#define rdm_descdreset_shift 25
+/* width of bitfield desc{d}_reset */
+#define rdm_descdreset_width 1
+/* default value of bitfield desc{d}_reset */
+#define rdm_descdreset_default 0x0
+
+/* rx int_desc_wrb_en bitfield definitions
+ * preprocessor definitions for the bitfield "int_desc_wrb_en".
+ * port="pif_rdm_int_desc_wrb_en_i"
+ */
+
+/* register address for bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_adr 0x00005a30
+/* bitmask for bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_msk 0x00000004
+/* inverted bitmask for bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_mskn 0xfffffffb
+/* lower bit position of bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_shift 2
+/* width of bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_width 1
+/* default value of bitfield int_desc_wrb_en */
+#define rdm_int_desc_wrb_en_default 0x0
+
+/* rx dca{d}_hdr_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca{d}_hdr_en".
+ * parameter: dca {d} | stride size 0x4 | range [0, 31]
+ * port="pif_rdm_dca_hdr_en_i[0]"
+ */
+
+/* register address for bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_adr(dca) (0x00006100 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_msk 0x40000000
+/* inverted bitmask for bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_mskn 0xbfffffff
+/* lower bit position of bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_shift 30
+/* width of bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_width 1
+/* default value of bitfield dca{d}_hdr_en */
+#define rdm_dcadhdr_en_default 0x0
+
+/* rx dca{d}_pay_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca{d}_pay_en".
+ * parameter: dca {d} | stride size 0x4 | range [0, 31]
+ * port="pif_rdm_dca_pay_en_i[0]"
+ */
+
+/* register address for bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_adr(dca) (0x00006100 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_msk 0x20000000
+/* inverted bitmask for bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_mskn 0xdfffffff
+/* lower bit position of bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_shift 29
+/* width of bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_width 1
+/* default value of bitfield dca{d}_pay_en */
+#define rdm_dcadpay_en_default 0x0
+
+/* general interrupt mapping register definitions
+ * preprocessor definitions for general interrupt mapping register
+ * base address: 0x00002180
+ * parameter: regidx {f} | stride size 0x4 | range [0, 3]
+ */
+#define gen_intr_map_adr(regidx) (0x00002180u + (regidx) * 0x4)
+
+/* general interrupt status register definitions
+ * preprocessor definitions for general interrupt status register
+ * address: 0x000021A0
+ */
+
+#define gen_intr_stat_adr 0x000021A4U
+
+/* interrupt global control register  definitions
+ * preprocessor definitions for interrupt global control register
+ * address: 0x00002300
+ */
+#define intr_glb_ctl_adr 0x00002300u
+
+/* interrupt throttle register definitions
+ * preprocessor definitions for interrupt throttle register
+ * base address: 0x00002800
+ * parameter: throttle {t} | stride size 0x4 | range [0, 31]
+ */
+#define intr_thr_adr(throttle) (0x00002800u + (throttle) * 0x4)
+
+/* rx dma descriptor base address lsw definitions
+ * preprocessor definitions for rx dma descriptor base address lsw
+ * base address: 0x00005b00
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ */
+#define rx_dma_desc_base_addrlsw_adr(descriptor) \
+	(0x00005b00u + (descriptor) * 0x20)
+
+/* rx dma descriptor base address msw definitions
+ * preprocessor definitions for rx dma descriptor base address msw
+ * base address: 0x00005b04
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ */
+#define rx_dma_desc_base_addrmsw_adr(descriptor) \
+	(0x00005b04u + (descriptor) * 0x20)
+
+/* rx dma descriptor status register definitions
+ * preprocessor definitions for rx dma descriptor status register
+ * base address: 0x00005b14
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ */
+#define rx_dma_desc_stat_adr(descriptor) (0x00005b14u + (descriptor) * 0x20)
+
+/* rx dma descriptor tail pointer register definitions
+ * preprocessor definitions for rx dma descriptor tail pointer register
+ * base address: 0x00005b10
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ */
+#define rx_dma_desc_tail_ptr_adr(descriptor) (0x00005b10u + (descriptor) * 0x20)
+
+/* rx filter multicast filter mask register definitions
+ * preprocessor definitions for rx filter multicast filter mask register
+ * address: 0x00005270
+ */
+#define rx_flr_mcst_flr_msk_adr 0x00005270u
+
+/* rx filter multicast filter register definitions
+ * preprocessor definitions for rx filter multicast filter register
+ * base address: 0x00005250
+ * parameter: filter {f} | stride size 0x4 | range [0, 7]
+ */
+#define rx_flr_mcst_flr_adr(filter) (0x00005250u + (filter) * 0x4)
+
+/* rx filter rss control register 1 definitions
+ * preprocessor definitions for rx filter rss control register 1
+ * address: 0x000054c0
+ */
+#define rx_flr_rss_control1_adr 0x000054c0u
+
+/* tx tx dma debug control [1f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "tx dma debug control [1f:0]".
+ * port="pif_tdm_debug_cntl_i[31:0]"
+ */
+
+/* register address for bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_adr 0x00008920
+/* bitmask for bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_msk 0xffffffff
+/* inverted bitmask for bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_mskn 0x00000000
+/* lower bit position of bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_shift 0
+/* width of bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_width 32
+/* default value of bitfield tx dma debug control [1f:0] */
+#define tdm_tx_dma_debug_ctl_default 0x0
+
+/* tx dma descriptor base address lsw definitions
+ * preprocessor definitions for tx dma descriptor base address lsw
+ * base address: 0x00007c00
+ * parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ */
+#define tx_dma_desc_base_addrlsw_adr(descriptor) \
+	(0x00007c00u + (descriptor) * 0x40)
+
+/* tx dma descriptor tail pointer register definitions
+ * preprocessor definitions for tx dma descriptor tail pointer register
+ * base address: 0x00007c10
+ *  parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ */
+#define tx_dma_desc_tail_ptr_adr(descriptor) (0x00007c10u + (descriptor) * 0x40)
+
+/* rx dma_sys_loopback bitfield definitions
+ * preprocessor definitions for the bitfield "dma_sys_loopback".
+ * port="pif_rpb_dma_sys_lbk_i"
+ */
+
+/* register address for bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_adr 0x00005000
+/* bitmask for bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_msk 0x00000040
+/* inverted bitmask for bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_mskn 0xffffffbf
+/* lower bit position of bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_shift 6
+/* width of bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_width 1
+/* default value of bitfield dma_sys_loopback */
+#define rpb_dma_sys_lbk_default 0x0
+
+/* rx rx_tc_mode bitfield definitions
+ * preprocessor definitions for the bitfield "rx_tc_mode".
+ * port="pif_rpb_rx_tc_mode_i,pif_rpf_rx_tc_mode_i"
+ */
+
+/* register address for bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_adr 0x00005700
+/* bitmask for bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_msk 0x00000100
+/* inverted bitmask for bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_mskn 0xfffffeff
+/* lower bit position of bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_shift 8
+/* width of bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_width 1
+/* default value of bitfield rx_tc_mode */
+#define rpb_rpf_rx_tc_mode_default 0x0
+
+/* rx rx_buf_en bitfield definitions
+ * preprocessor definitions for the bitfield "rx_buf_en".
+ * port="pif_rpb_rx_buf_en_i"
+ */
+
+/* register address for bitfield rx_buf_en */
+#define rpb_rx_buf_en_adr 0x00005700
+/* bitmask for bitfield rx_buf_en */
+#define rpb_rx_buf_en_msk 0x00000001
+/* inverted bitmask for bitfield rx_buf_en */
+#define rpb_rx_buf_en_mskn 0xfffffffe
+/* lower bit position of bitfield rx_buf_en */
+#define rpb_rx_buf_en_shift 0
+/* width of bitfield rx_buf_en */
+#define rpb_rx_buf_en_width 1
+/* default value of bitfield rx_buf_en */
+#define rpb_rx_buf_en_default 0x0
+
+/* rx rx{b}_hi_thresh[d:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rx{b}_hi_thresh[d:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_rpb_rx0_hi_thresh_i[13:0]"
+ */
+
+/* register address for bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_adr(buffer) (0x00005714 + (buffer) * 0x10)
+/* bitmask for bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_msk 0x3fff0000
+/* inverted bitmask for bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_mskn 0xc000ffff
+/* lower bit position of bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_shift 16
+/* width of bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_width 14
+/* default value of bitfield rx{b}_hi_thresh[d:0] */
+#define rpb_rxbhi_thresh_default 0x0
+
+/* rx rx{b}_lo_thresh[d:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rx{b}_lo_thresh[d:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_rpb_rx0_lo_thresh_i[13:0]"
+ */
+
+/* register address for bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_adr(buffer) (0x00005714 + (buffer) * 0x10)
+/* bitmask for bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_msk 0x00003fff
+/* inverted bitmask for bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_mskn 0xffffc000
+/* lower bit position of bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_shift 0
+/* width of bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_width 14
+/* default value of bitfield rx{b}_lo_thresh[d:0] */
+#define rpb_rxblo_thresh_default 0x0
+
+/* rx rx_fc_mode[1:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rx_fc_mode[1:0]".
+ * port="pif_rpb_rx_fc_mode_i[1:0]"
+ */
+
+/* register address for bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_adr 0x00005700
+/* bitmask for bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_msk 0x00000030
+/* inverted bitmask for bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_mskn 0xffffffcf
+/* lower bit position of bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_shift 4
+/* width of bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_width 2
+/* default value of bitfield rx_fc_mode[1:0] */
+#define rpb_rx_fc_mode_default 0x0
+
+/* rx rx{b}_buf_size[8:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rx{b}_buf_size[8:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_rpb_rx0_buf_size_i[8:0]"
+ */
+
+/* register address for bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_adr(buffer) (0x00005710 + (buffer) * 0x10)
+/* bitmask for bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_msk 0x000001ff
+/* inverted bitmask for bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_mskn 0xfffffe00
+/* lower bit position of bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_shift 0
+/* width of bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_width 9
+/* default value of bitfield rx{b}_buf_size[8:0] */
+#define rpb_rxbbuf_size_default 0x0
+
+/* rx rx{b}_xoff_en bitfield definitions
+ * preprocessor definitions for the bitfield "rx{b}_xoff_en".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_rpb_rx_xoff_en_i[0]"
+ */
+
+/* register address for bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_adr(buffer) (0x00005714 + (buffer) * 0x10)
+/* bitmask for bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_msk 0x80000000
+/* inverted bitmask for bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_mskn 0x7fffffff
+/* lower bit position of bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_shift 31
+/* width of bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_width 1
+/* default value of bitfield rx{b}_xoff_en */
+#define rpb_rxbxoff_en_default 0x0
+
+/* rx l2_bc_thresh[f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "l2_bc_thresh[f:0]".
+ * port="pif_rpf_l2_bc_thresh_i[15:0]"
+ */
+
+/* register address for bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_adr 0x00005100
+/* bitmask for bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_msk 0xffff0000
+/* inverted bitmask for bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_mskn 0x0000ffff
+/* lower bit position of bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_shift 16
+/* width of bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_width 16
+/* default value of bitfield l2_bc_thresh[f:0] */
+#define rpfl2bc_thresh_default 0x0
+
+/* rx l2_bc_en bitfield definitions
+ * preprocessor definitions for the bitfield "l2_bc_en".
+ * port="pif_rpf_l2_bc_en_i"
+ */
+
+/* register address for bitfield l2_bc_en */
+#define rpfl2bc_en_adr 0x00005100
+/* bitmask for bitfield l2_bc_en */
+#define rpfl2bc_en_msk 0x00000001
+/* inverted bitmask for bitfield l2_bc_en */
+#define rpfl2bc_en_mskn 0xfffffffe
+/* lower bit position of bitfield l2_bc_en */
+#define rpfl2bc_en_shift 0
+/* width of bitfield l2_bc_en */
+#define rpfl2bc_en_width 1
+/* default value of bitfield l2_bc_en */
+#define rpfl2bc_en_default 0x0
+
+/* rx l2_bc_act[2:0] bitfield definitions
+ * preprocessor definitions for the bitfield "l2_bc_act[2:0]".
+ * port="pif_rpf_l2_bc_act_i[2:0]"
+ */
+
+/* register address for bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_adr 0x00005100
+/* bitmask for bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_msk 0x00007000
+/* inverted bitmask for bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_mskn 0xffff8fff
+/* lower bit position of bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_shift 12
+/* width of bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_width 3
+/* default value of bitfield l2_bc_act[2:0] */
+#define rpfl2bc_act_default 0x0
+
+/* rx l2_mc_en{f} bitfield definitions
+ * preprocessor definitions for the bitfield "l2_mc_en{f}".
+ * parameter: filter {f} | stride size 0x4 | range [0, 7]
+ * port="pif_rpf_l2_mc_en_i[0]"
+ */
+
+/* register address for bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_adr(filter) (0x00005250 + (filter) * 0x4)
+/* bitmask for bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_msk 0x80000000
+/* inverted bitmask for bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_mskn 0x7fffffff
+/* lower bit position of bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_shift 31
+/* width of bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_width 1
+/* default value of bitfield l2_mc_en{f} */
+#define rpfl2mc_enf_default 0x0
+
+/* rx l2_promis_mode bitfield definitions
+ * preprocessor definitions for the bitfield "l2_promis_mode".
+ * port="pif_rpf_l2_promis_mode_i"
+ */
+
+/* register address for bitfield l2_promis_mode */
+#define rpfl2promis_mode_adr 0x00005100
+/* bitmask for bitfield l2_promis_mode */
+#define rpfl2promis_mode_msk 0x00000008
+/* inverted bitmask for bitfield l2_promis_mode */
+#define rpfl2promis_mode_mskn 0xfffffff7
+/* lower bit position of bitfield l2_promis_mode */
+#define rpfl2promis_mode_shift 3
+/* width of bitfield l2_promis_mode */
+#define rpfl2promis_mode_width 1
+/* default value of bitfield l2_promis_mode */
+#define rpfl2promis_mode_default 0x0
+
+/* rx l2_uc_act{f}[2:0] bitfield definitions
+ * preprocessor definitions for the bitfield "l2_uc_act{f}[2:0]".
+ * parameter: filter {f} | stride size 0x8 | range [0, 37]
+ * port="pif_rpf_l2_uc_act0_i[2:0]"
+ */
+
+/* register address for bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_adr(filter) (0x00005114 + (filter) * 0x8)
+/* bitmask for bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_msk 0x00070000
+/* inverted bitmask for bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_mskn 0xfff8ffff
+/* lower bit position of bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_shift 16
+/* width of bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_width 3
+/* default value of bitfield l2_uc_act{f}[2:0] */
+#define rpfl2uc_actf_default 0x0
+
+/* rx l2_uc_en{f} bitfield definitions
+ * preprocessor definitions for the bitfield "l2_uc_en{f}".
+ * parameter: filter {f} | stride size 0x8 | range [0, 37]
+ * port="pif_rpf_l2_uc_en_i[0]"
+ */
+
+/* register address for bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_adr(filter) (0x00005114 + (filter) * 0x8)
+/* bitmask for bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_msk 0x80000000
+/* inverted bitmask for bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_mskn 0x7fffffff
+/* lower bit position of bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_shift 31
+/* width of bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_width 1
+/* default value of bitfield l2_uc_en{f} */
+#define rpfl2uc_enf_default 0x0
+
+/* register address for bitfield l2_uc_da{f}_lsw[1f:0] */
+#define rpfl2uc_daflsw_adr(filter) (0x00005110 + (filter) * 0x8)
+/* register address for bitfield l2_uc_da{f}_msw[f:0] */
+#define rpfl2uc_dafmsw_adr(filter) (0x00005114 + (filter) * 0x8)
+/* bitmask for bitfield l2_uc_da{f}_msw[f:0] */
+#define rpfl2uc_dafmsw_msk 0x0000ffff
+/* lower bit position of bitfield l2_uc_da{f}_msw[f:0] */
+#define rpfl2uc_dafmsw_shift 0
+
+/* rx rx_tc_up{t}[2:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rx_tc_up{t}[2:0]".
+ * parameter: tc {t} | bit-level stride | range [0, 7]
+ * port="pif_rpf_rx_tc_up0_i[2:0],pif_rpb_rx_tc_up0_i[2:0]"
+ */
+
+/* register address for bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_adr(tc) \
+	(((tc) == 0) ? 0x000054c4 : \
+	(((tc) == 1) ? 0x000054c4 : \
+	(((tc) == 2) ? 0x000054c4 : \
+	(((tc) == 3) ? 0x000054c4 : \
+	(((tc) == 4) ? 0x000054c4 : \
+	(((tc) == 5) ? 0x000054c4 : \
+	(((tc) == 6) ? 0x000054c4 : \
+	(((tc) == 7) ? 0x000054c4 : \
+	0))))))))
+/* bitmask for bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_msk(tc) \
+	(((tc) == 0) ? 0x00000007 : \
+	(((tc) == 1) ? 0x00000070 : \
+	(((tc) == 2) ? 0x00000700 : \
+	(((tc) == 3) ? 0x00007000 : \
+	(((tc) == 4) ? 0x00070000 : \
+	(((tc) == 5) ? 0x00700000 : \
+	(((tc) == 6) ? 0x07000000 : \
+	(((tc) == 7) ? 0x70000000 : \
+	0))))))))
+/* inverted bitmask for bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_mskn(tc) \
+	(((tc) == 0) ? 0xfffffff8 : \
+	(((tc) == 1) ? 0xffffff8f : \
+	(((tc) == 2) ? 0xfffff8ff : \
+	(((tc) == 3) ? 0xffff8fff : \
+	(((tc) == 4) ? 0xfff8ffff : \
+	(((tc) == 5) ? 0xff8fffff : \
+	(((tc) == 6) ? 0xf8ffffff : \
+	(((tc) == 7) ? 0x8fffffff : \
+	0))))))))
+/* lower bit position of bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_shift(tc) \
+	(((tc) == 0) ? 0 : \
+	(((tc) == 1) ? 4 : \
+	(((tc) == 2) ? 8 : \
+	(((tc) == 3) ? 12 : \
+	(((tc) == 4) ? 16 : \
+	(((tc) == 5) ? 20 : \
+	(((tc) == 6) ? 24 : \
+	(((tc) == 7) ? 28 : \
+	0))))))))
+/* width of bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_width 3
+/* default value of bitfield rx_tc_up{t}[2:0] */
+#define rpf_rpb_rx_tc_upt_default 0x0
+
+/* rx rss_key_addr[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rss_key_addr[4:0]".
+ * port="pif_rpf_rss_key_addr_i[4:0]"
+ */
+
+/* register address for bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_adr 0x000054d0
+/* bitmask for bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_msk 0x0000001f
+/* inverted bitmask for bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_mskn 0xffffffe0
+/* lower bit position of bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_shift 0
+/* width of bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_width 5
+/* default value of bitfield rss_key_addr[4:0] */
+#define rpf_rss_key_addr_default 0x0
+
+/* rx rss_key_wr_data[1f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rss_key_wr_data[1f:0]".
+ * port="pif_rpf_rss_key_wr_data_i[31:0]"
+ */
+
+/* register address for bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_adr 0x000054d4
+/* bitmask for bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_msk 0xffffffff
+/* inverted bitmask for bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_mskn 0x00000000
+/* lower bit position of bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_shift 0
+/* width of bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_width 32
+/* default value of bitfield rss_key_wr_data[1f:0] */
+#define rpf_rss_key_wr_data_default 0x0
+
+/* rx rss_key_wr_en_i bitfield definitions
+ * preprocessor definitions for the bitfield "rss_key_wr_en_i".
+ * port="pif_rpf_rss_key_wr_en_i"
+ */
+
+/* register address for bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_adr 0x000054d0
+/* bitmask for bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_msk 0x00000020
+/* inverted bitmask for bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_mskn 0xffffffdf
+/* lower bit position of bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_shift 5
+/* width of bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_width 1
+/* default value of bitfield rss_key_wr_en_i */
+#define rpf_rss_key_wr_eni_default 0x0
+
+/* rx rss_redir_addr[3:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rss_redir_addr[3:0]".
+ * port="pif_rpf_rss_redir_addr_i[3:0]"
+ */
+
+/* register address for bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_adr 0x000054e0
+/* bitmask for bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_msk 0x0000000f
+/* inverted bitmask for bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_mskn 0xfffffff0
+/* lower bit position of bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_shift 0
+/* width of bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_width 4
+/* default value of bitfield rss_redir_addr[3:0] */
+#define rpf_rss_redir_addr_default 0x0
+
+/* rx rss_redir_wr_data[f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "rss_redir_wr_data[f:0]".
+ * port="pif_rpf_rss_redir_wr_data_i[15:0]"
+ */
+
+/* register address for bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_adr 0x000054e4
+/* bitmask for bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_msk 0x0000ffff
+/* inverted bitmask for bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_mskn 0xffff0000
+/* lower bit position of bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_shift 0
+/* width of bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_width 16
+/* default value of bitfield rss_redir_wr_data[f:0] */
+#define rpf_rss_redir_wr_data_default 0x0
+
+/* rx rss_redir_wr_en_i bitfield definitions
+ * preprocessor definitions for the bitfield "rss_redir_wr_en_i".
+ * port="pif_rpf_rss_redir_wr_en_i"
+ */
+
+/* register address for bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_adr 0x000054e0
+/* bitmask for bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_msk 0x00000010
+/* inverted bitmask for bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_mskn 0xffffffef
+/* lower bit position of bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_shift 4
+/* width of bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_width 1
+/* default value of bitfield rss_redir_wr_en_i */
+#define rpf_rss_redir_wr_eni_default 0x0
+
+/* rx tpo_rpf_sys_loopback bitfield definitions
+ * preprocessor definitions for the bitfield "tpo_rpf_sys_loopback".
+ * port="pif_rpf_tpo_pkt_sys_lbk_i"
+ */
+
+/* register address for bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_adr 0x00005000
+/* bitmask for bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_msk 0x00000100
+/* inverted bitmask for bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_mskn 0xfffffeff
+/* lower bit position of bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_shift 8
+/* width of bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_width 1
+/* default value of bitfield tpo_rpf_sys_loopback */
+#define rpf_tpo_rpf_sys_lbk_default 0x0
+
+/* rx vl_inner_tpid[f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "vl_inner_tpid[f:0]".
+ * port="pif_rpf_vl_inner_tpid_i[15:0]"
+ */
+
+/* register address for bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_adr 0x00005284
+/* bitmask for bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_msk 0x0000ffff
+/* inverted bitmask for bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_mskn 0xffff0000
+/* lower bit position of bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_shift 0
+/* width of bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_width 16
+/* default value of bitfield vl_inner_tpid[f:0] */
+#define rpf_vl_inner_tpid_default 0x8100
+
+/* rx vl_outer_tpid[f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "vl_outer_tpid[f:0]".
+ * port="pif_rpf_vl_outer_tpid_i[15:0]"
+ */
+
+/* register address for bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_adr 0x00005284
+/* bitmask for bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_msk 0xffff0000
+/* inverted bitmask for bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_mskn 0x0000ffff
+/* lower bit position of bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_shift 16
+/* width of bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_width 16
+/* default value of bitfield vl_outer_tpid[f:0] */
+#define rpf_vl_outer_tpid_default 0x88a8
+
+/* rx vl_promis_mode bitfield definitions
+ * preprocessor definitions for the bitfield "vl_promis_mode".
+ * port="pif_rpf_vl_promis_mode_i"
+ */
+
+/* register address for bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_adr 0x00005280
+/* bitmask for bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_msk 0x00000002
+/* inverted bitmask for bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_mskn 0xfffffffd
+/* lower bit position of bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_shift 1
+/* width of bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_width 1
+/* default value of bitfield vl_promis_mode */
+#define rpf_vl_promis_mode_default 0x0
+
+/* rx et_en{f} bitfield definitions
+ * preprocessor definitions for the bitfield "et_en{f}".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_en_i[0]"
+ */
+
+/* register address for bitfield et_en{f} */
+#define rpf_et_enf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_en{f} */
+#define rpf_et_enf_msk 0x80000000
+/* inverted bitmask for bitfield et_en{f} */
+#define rpf_et_enf_mskn 0x7fffffff
+/* lower bit position of bitfield et_en{f} */
+#define rpf_et_enf_shift 31
+/* width of bitfield et_en{f} */
+#define rpf_et_enf_width 1
+/* default value of bitfield et_en{f} */
+#define rpf_et_enf_default 0x0
+
+/* rx et_up{f}_en bitfield definitions
+ * preprocessor definitions for the bitfield "et_up{f}_en".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_up_en_i[0]"
+ */
+
+/* register address for bitfield et_up{f}_en */
+#define rpf_et_upfen_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_up{f}_en */
+#define rpf_et_upfen_msk 0x40000000
+/* inverted bitmask for bitfield et_up{f}_en */
+#define rpf_et_upfen_mskn 0xbfffffff
+/* lower bit position of bitfield et_up{f}_en */
+#define rpf_et_upfen_shift 30
+/* width of bitfield et_up{f}_en */
+#define rpf_et_upfen_width 1
+/* default value of bitfield et_up{f}_en */
+#define rpf_et_upfen_default 0x0
+
+/* rx et_rxq{f}_en bitfield definitions
+ * preprocessor definitions for the bitfield "et_rxq{f}_en".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_rxq_en_i[0]"
+ */
+
+/* register address for bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_msk 0x20000000
+/* inverted bitmask for bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_mskn 0xdfffffff
+/* lower bit position of bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_shift 29
+/* width of bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_width 1
+/* default value of bitfield et_rxq{f}_en */
+#define rpf_et_rxqfen_default 0x0
+
+/* rx et_up{f}[2:0] bitfield definitions
+ * preprocessor definitions for the bitfield "et_up{f}[2:0]".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_up0_i[2:0]"
+ */
+
+/* register address for bitfield et_up{f}[2:0] */
+#define rpf_et_upf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_up{f}[2:0] */
+#define rpf_et_upf_msk 0x1c000000
+/* inverted bitmask for bitfield et_up{f}[2:0] */
+#define rpf_et_upf_mskn 0xe3ffffff
+/* lower bit position of bitfield et_up{f}[2:0] */
+#define rpf_et_upf_shift 26
+/* width of bitfield et_up{f}[2:0] */
+#define rpf_et_upf_width 3
+/* default value of bitfield et_up{f}[2:0] */
+#define rpf_et_upf_default 0x0
+
+/* rx et_rxq{f}[4:0] bitfield definitions
+ * preprocessor definitions for the bitfield "et_rxq{f}[4:0]".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_rxq0_i[4:0]"
+ */
+
+/* register address for bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_msk 0x01f00000
+/* inverted bitmask for bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_mskn 0xfe0fffff
+/* lower bit position of bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_shift 20
+/* width of bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_width 5
+/* default value of bitfield et_rxq{f}[4:0] */
+#define rpf_et_rxqf_default 0x0
+
+/* rx et_mng_rxq{f} bitfield definitions
+ * preprocessor definitions for the bitfield "et_mng_rxq{f}".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_mng_rxq_i[0]"
+ */
+
+/* register address for bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_msk 0x00080000
+/* inverted bitmask for bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_mskn 0xfff7ffff
+/* lower bit position of bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_shift 19
+/* width of bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_width 1
+/* default value of bitfield et_mng_rxq{f} */
+#define rpf_et_mng_rxqf_default 0x0
+
+/* rx et_act{f}[2:0] bitfield definitions
+ * preprocessor definitions for the bitfield "et_act{f}[2:0]".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_act0_i[2:0]"
+ */
+
+/* register address for bitfield et_act{f}[2:0] */
+#define rpf_et_actf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_act{f}[2:0] */
+#define rpf_et_actf_msk 0x00070000
+/* inverted bitmask for bitfield et_act{f}[2:0] */
+#define rpf_et_actf_mskn 0xfff8ffff
+/* lower bit position of bitfield et_act{f}[2:0] */
+#define rpf_et_actf_shift 16
+/* width of bitfield et_act{f}[2:0] */
+#define rpf_et_actf_width 3
+/* default value of bitfield et_act{f}[2:0] */
+#define rpf_et_actf_default 0x0
+
+/* rx et_val{f}[f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "et_val{f}[f:0]".
+ * parameter: filter {f} | stride size 0x4 | range [0, 15]
+ * port="pif_rpf_et_val0_i[15:0]"
+ */
+
+/* register address for bitfield et_val{f}[f:0] */
+#define rpf_et_valf_adr(filter) (0x00005300 + (filter) * 0x4)
+/* bitmask for bitfield et_val{f}[f:0] */
+#define rpf_et_valf_msk 0x0000ffff
+/* inverted bitmask for bitfield et_val{f}[f:0] */
+#define rpf_et_valf_mskn 0xffff0000
+/* lower bit position of bitfield et_val{f}[f:0] */
+#define rpf_et_valf_shift 0
+/* width of bitfield et_val{f}[f:0] */
+#define rpf_et_valf_width 16
+/* default value of bitfield et_val{f}[f:0] */
+#define rpf_et_valf_default 0x0
+
+/* rx ipv4_chk_en bitfield definitions
+ * preprocessor definitions for the bitfield "ipv4_chk_en".
+ * port="pif_rpo_ipv4_chk_en_i"
+ */
+
+/* register address for bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_adr 0x00005580
+/* bitmask for bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_msk 0x00000002
+/* inverted bitmask for bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_mskn 0xfffffffd
+/* lower bit position of bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_shift 1
+/* width of bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_width 1
+/* default value of bitfield ipv4_chk_en */
+#define rpo_ipv4chk_en_default 0x0
+
+/* rx desc{d}_vl_strip bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_vl_strip".
+ * parameter: descriptor {d} | stride size 0x20 | range [0, 31]
+ * port="pif_rpo_desc_vl_strip_i[0]"
+ */
+
+/* register address for bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_adr(descriptor) (0x00005b08 + (descriptor) * 0x20)
+/* bitmask for bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_msk 0x20000000
+/* inverted bitmask for bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_mskn 0xdfffffff
+/* lower bit position of bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_shift 29
+/* width of bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_width 1
+/* default value of bitfield desc{d}_vl_strip */
+#define rpo_descdvl_strip_default 0x0
+
+/* rx l4_chk_en bitfield definitions
+ * preprocessor definitions for the bitfield "l4_chk_en".
+ * port="pif_rpo_l4_chk_en_i"
+ */
+
+/* register address for bitfield l4_chk_en */
+#define rpol4chk_en_adr 0x00005580
+/* bitmask for bitfield l4_chk_en */
+#define rpol4chk_en_msk 0x00000001
+/* inverted bitmask for bitfield l4_chk_en */
+#define rpol4chk_en_mskn 0xfffffffe
+/* lower bit position of bitfield l4_chk_en */
+#define rpol4chk_en_shift 0
+/* width of bitfield l4_chk_en */
+#define rpol4chk_en_width 1
+/* default value of bitfield l4_chk_en */
+#define rpol4chk_en_default 0x0
+
+/* rx reg_res_dsbl bitfield definitions
+ * preprocessor definitions for the bitfield "reg_res_dsbl".
+ * port="pif_rx_reg_res_dsbl_i"
+ */
+
+/* register address for bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_adr 0x00005000
+/* bitmask for bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_msk 0x20000000
+/* inverted bitmask for bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_mskn 0xdfffffff
+/* lower bit position of bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_shift 29
+/* width of bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_width 1
+/* default value of bitfield reg_res_dsbl */
+#define rx_reg_res_dsbl_default 0x1
+
+/* tx dca{d}_cpuid[7:0] bitfield definitions
+ * preprocessor definitions for the bitfield "dca{d}_cpuid[7:0]".
+ * parameter: dca {d} | stride size 0x4 | range [0, 31]
+ * port="pif_tdm_dca0_cpuid_i[7:0]"
+ */
+
+/* register address for bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_adr(dca) (0x00008400 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_msk 0x000000ff
+/* inverted bitmask for bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_mskn 0xffffff00
+/* lower bit position of bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_shift 0
+/* width of bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_width 8
+/* default value of bitfield dca{d}_cpuid[7:0] */
+#define tdm_dcadcpuid_default 0x0
+
+/* tx lso_en[1f:0] bitfield definitions
+ * preprocessor definitions for the bitfield "lso_en[1f:0]".
+ * port="pif_tdm_lso_en_i[31:0]"
+ */
+
+/* register address for bitfield lso_en[1f:0] */
+#define tdm_lso_en_adr 0x00007810
+/* bitmask for bitfield lso_en[1f:0] */
+#define tdm_lso_en_msk 0xffffffff
+/* inverted bitmask for bitfield lso_en[1f:0] */
+#define tdm_lso_en_mskn 0x00000000
+/* lower bit position of bitfield lso_en[1f:0] */
+#define tdm_lso_en_shift 0
+/* width of bitfield lso_en[1f:0] */
+#define tdm_lso_en_width 32
+/* default value of bitfield lso_en[1f:0] */
+#define tdm_lso_en_default 0x0
+
+/* tx dca_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca_en".
+ * port="pif_tdm_dca_en_i"
+ */
+
+/* register address for bitfield dca_en */
+#define tdm_dca_en_adr 0x00008480
+/* bitmask for bitfield dca_en */
+#define tdm_dca_en_msk 0x80000000
+/* inverted bitmask for bitfield dca_en */
+#define tdm_dca_en_mskn 0x7fffffff
+/* lower bit position of bitfield dca_en */
+#define tdm_dca_en_shift 31
+/* width of bitfield dca_en */
+#define tdm_dca_en_width 1
+/* default value of bitfield dca_en */
+#define tdm_dca_en_default 0x1
+
+/* tx dca_mode[3:0] bitfield definitions
+ * preprocessor definitions for the bitfield "dca_mode[3:0]".
+ * port="pif_tdm_dca_mode_i[3:0]"
+ */
+
+/* register address for bitfield dca_mode[3:0] */
+#define tdm_dca_mode_adr 0x00008480
+/* bitmask for bitfield dca_mode[3:0] */
+#define tdm_dca_mode_msk 0x0000000f
+/* inverted bitmask for bitfield dca_mode[3:0] */
+#define tdm_dca_mode_mskn 0xfffffff0
+/* lower bit position of bitfield dca_mode[3:0] */
+#define tdm_dca_mode_shift 0
+/* width of bitfield dca_mode[3:0] */
+#define tdm_dca_mode_width 4
+/* default value of bitfield dca_mode[3:0] */
+#define tdm_dca_mode_default 0x0
+
+/* tx dca{d}_desc_en bitfield definitions
+ * preprocessor definitions for the bitfield "dca{d}_desc_en".
+ * parameter: dca {d} | stride size 0x4 | range [0, 31]
+ * port="pif_tdm_dca_desc_en_i[0]"
+ */
+
+/* register address for bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_adr(dca) (0x00008400 + (dca) * 0x4)
+/* bitmask for bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_msk 0x80000000
+/* inverted bitmask for bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_mskn 0x7fffffff
+/* lower bit position of bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_shift 31
+/* width of bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_width 1
+/* default value of bitfield dca{d}_desc_en */
+#define tdm_dcaddesc_en_default 0x0
+
+/* tx desc{d}_en bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_en".
+ * parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ * port="pif_tdm_desc_en_i[0]"
+ */
+
+/* register address for bitfield desc{d}_en */
+#define tdm_descden_adr(descriptor) (0x00007c08 + (descriptor) * 0x40)
+/* bitmask for bitfield desc{d}_en */
+#define tdm_descden_msk 0x80000000
+/* inverted bitmask for bitfield desc{d}_en */
+#define tdm_descden_mskn 0x7fffffff
+/* lower bit position of bitfield desc{d}_en */
+#define tdm_descden_shift 31
+/* width of bitfield desc{d}_en */
+#define tdm_descden_width 1
+/* default value of bitfield desc{d}_en */
+#define tdm_descden_default 0x0
+
+/* tx desc{d}_hd[c:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_hd[c:0]".
+ * parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ * port="tdm_pif_desc0_hd_o[12:0]"
+ */
+
+/* register address for bitfield desc{d}_hd[c:0] */
+#define tdm_descdhd_adr(descriptor) (0x00007c0c + (descriptor) * 0x40)
+/* bitmask for bitfield desc{d}_hd[c:0] */
+#define tdm_descdhd_msk 0x00001fff
+/* inverted bitmask for bitfield desc{d}_hd[c:0] */
+#define tdm_descdhd_mskn 0xffffe000
+/* lower bit position of bitfield desc{d}_hd[c:0] */
+#define tdm_descdhd_shift 0
+/* width of bitfield desc{d}_hd[c:0] */
+#define tdm_descdhd_width 13
+
+/* tx desc{d}_len[9:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_len[9:0]".
+ * parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ * port="pif_tdm_desc0_len_i[9:0]"
+ */
+
+/* register address for bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_adr(descriptor) (0x00007c08 + (descriptor) * 0x40)
+/* bitmask for bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_msk 0x00001ff8
+/* inverted bitmask for bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_mskn 0xffffe007
+/* lower bit position of bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_shift 3
+/* width of bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_width 10
+/* default value of bitfield desc{d}_len[9:0] */
+#define tdm_descdlen_default 0x0
+
+/* tx int_desc_wrb_en bitfield definitions
+ * preprocessor definitions for the bitfield "int_desc_wrb_en".
+ * port="pif_tdm_int_desc_wrb_en_i"
+ */
+
+/* register address for bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_adr 0x00007b40
+/* bitmask for bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_msk 0x00000002
+/* inverted bitmask for bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_mskn 0xfffffffd
+/* lower bit position of bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_shift 1
+/* width of bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_width 1
+/* default value of bitfield int_desc_wrb_en */
+#define tdm_int_desc_wrb_en_default 0x0
+
+/* tx desc{d}_wrb_thresh[6:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc{d}_wrb_thresh[6:0]".
+ * parameter: descriptor {d} | stride size 0x40 | range [0, 31]
+ * port="pif_tdm_desc0_wrb_thresh_i[6:0]"
+ */
+
+/* register address for bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_adr(descriptor) (0x00007c18 + (descriptor) * 0x40)
+/* bitmask for bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_msk 0x00007f00
+/* inverted bitmask for bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_mskn 0xffff80ff
+/* lower bit position of bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_shift 8
+/* width of bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_width 7
+/* default value of bitfield desc{d}_wrb_thresh[6:0] */
+#define tdm_descdwrb_thresh_default 0x0
+
+/* tx lso_tcp_flag_first[b:0] bitfield definitions
+ * preprocessor definitions for the bitfield "lso_tcp_flag_first[b:0]".
+ * port="pif_thm_lso_tcp_flag_first_i[11:0]"
+ */
+
+/* register address for bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_adr 0x00007820
+/* bitmask for bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_msk 0x00000fff
+/* inverted bitmask for bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_mskn 0xfffff000
+/* lower bit position of bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_shift 0
+/* width of bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_width 12
+/* default value of bitfield lso_tcp_flag_first[b:0] */
+#define thm_lso_tcp_flag_first_default 0x0
+
+/* tx lso_tcp_flag_last[b:0] bitfield definitions
+ * preprocessor definitions for the bitfield "lso_tcp_flag_last[b:0]".
+ * port="pif_thm_lso_tcp_flag_last_i[11:0]"
+ */
+
+/* register address for bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_adr 0x00007824
+/* bitmask for bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_msk 0x00000fff
+/* inverted bitmask for bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_mskn 0xfffff000
+/* lower bit position of bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_shift 0
+/* width of bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_width 12
+/* default value of bitfield lso_tcp_flag_last[b:0] */
+#define thm_lso_tcp_flag_last_default 0x0
+
+/* tx lso_tcp_flag_mid[b:0] bitfield definitions
+ * preprocessor definitions for the bitfield "lso_tcp_flag_mid[b:0]".
+ * port="pif_thm_lso_tcp_flag_mid_i[11:0]"
+ */
+
+/* register address for bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_adr 0x00007820
+/* bitmask for bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_msk 0x0fff0000
+/* inverted bitmask for bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_mskn 0xf000ffff
+/* lower bit position of bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_shift 16
+/* width of bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_width 12
+/* default value of bitfield lso_tcp_flag_mid[b:0] */
+#define thm_lso_tcp_flag_mid_default 0x0
+
+/* tx tx_buf_en bitfield definitions
+ * preprocessor definitions for the bitfield "tx_buf_en".
+ * port="pif_tpb_tx_buf_en_i"
+ */
+
+/* register address for bitfield tx_buf_en */
+#define tpb_tx_buf_en_adr 0x00007900
+/* bitmask for bitfield tx_buf_en */
+#define tpb_tx_buf_en_msk 0x00000001
+/* inverted bitmask for bitfield tx_buf_en */
+#define tpb_tx_buf_en_mskn 0xfffffffe
+/* lower bit position of bitfield tx_buf_en */
+#define tpb_tx_buf_en_shift 0
+/* width of bitfield tx_buf_en */
+#define tpb_tx_buf_en_width 1
+/* default value of bitfield tx_buf_en */
+#define tpb_tx_buf_en_default 0x0
+
+/* tx tx{b}_hi_thresh[c:0] bitfield definitions
+ * preprocessor definitions for the bitfield "tx{b}_hi_thresh[c:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_tpb_tx0_hi_thresh_i[12:0]"
+ */
+
+/* register address for bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_adr(buffer) (0x00007914 + (buffer) * 0x10)
+/* bitmask for bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_msk 0x1fff0000
+/* inverted bitmask for bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_mskn 0xe000ffff
+/* lower bit position of bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_shift 16
+/* width of bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_width 13
+/* default value of bitfield tx{b}_hi_thresh[c:0] */
+#define tpb_txbhi_thresh_default 0x0
+
+/* tx tx{b}_lo_thresh[c:0] bitfield definitions
+ * preprocessor definitions for the bitfield "tx{b}_lo_thresh[c:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_tpb_tx0_lo_thresh_i[12:0]"
+ */
+
+/* register address for bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_adr(buffer) (0x00007914 + (buffer) * 0x10)
+/* bitmask for bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_msk 0x00001fff
+/* inverted bitmask for bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_mskn 0xffffe000
+/* lower bit position of bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_shift 0
+/* width of bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_width 13
+/* default value of bitfield tx{b}_lo_thresh[c:0] */
+#define tpb_txblo_thresh_default 0x0
+
+/* tx dma_sys_loopback bitfield definitions
+ * preprocessor definitions for the bitfield "dma_sys_loopback".
+ * port="pif_tpb_dma_sys_lbk_i"
+ */
+
+/* register address for bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_adr 0x00007000
+/* bitmask for bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_msk 0x00000040
+/* inverted bitmask for bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_mskn 0xffffffbf
+/* lower bit position of bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_shift 6
+/* width of bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_width 1
+/* default value of bitfield dma_sys_loopback */
+#define tpb_dma_sys_lbk_default 0x0
+
+/* tx tx{b}_buf_size[7:0] bitfield definitions
+ * preprocessor definitions for the bitfield "tx{b}_buf_size[7:0]".
+ * parameter: buffer {b} | stride size 0x10 | range [0, 7]
+ * port="pif_tpb_tx0_buf_size_i[7:0]"
+ */
+
+/* register address for bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_adr(buffer) (0x00007910 + (buffer) * 0x10)
+/* bitmask for bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_msk 0x000000ff
+/* inverted bitmask for bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_mskn 0xffffff00
+/* lower bit position of bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_shift 0
+/* width of bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_width 8
+/* default value of bitfield tx{b}_buf_size[7:0] */
+#define tpb_txbbuf_size_default 0x0
+
+/* tx tx_scp_ins_en bitfield definitions
+ * preprocessor definitions for the bitfield "tx_scp_ins_en".
+ * port="pif_tpb_scp_ins_en_i"
+ */
+
+/* register address for bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_adr 0x00007900
+/* bitmask for bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_msk 0x00000004
+/* inverted bitmask for bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_mskn 0xfffffffb
+/* lower bit position of bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_shift 2
+/* width of bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_width 1
+/* default value of bitfield tx_scp_ins_en */
+#define tpb_tx_scp_ins_en_default 0x0
+
+/* tx ipv4_chk_en bitfield definitions
+ * preprocessor definitions for the bitfield "ipv4_chk_en".
+ * port="pif_tpo_ipv4_chk_en_i"
+ */
+
+/* register address for bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_adr 0x00007800
+/* bitmask for bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_msk 0x00000002
+/* inverted bitmask for bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_mskn 0xfffffffd
+/* lower bit position of bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_shift 1
+/* width of bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_width 1
+/* default value of bitfield ipv4_chk_en */
+#define tpo_ipv4chk_en_default 0x0
+
+/* tx l4_chk_en bitfield definitions
+ * preprocessor definitions for the bitfield "l4_chk_en".
+ * port="pif_tpo_l4_chk_en_i"
+ */
+
+/* register address for bitfield l4_chk_en */
+#define tpol4chk_en_adr 0x00007800
+/* bitmask for bitfield l4_chk_en */
+#define tpol4chk_en_msk 0x00000001
+/* inverted bitmask for bitfield l4_chk_en */
+#define tpol4chk_en_mskn 0xfffffffe
+/* lower bit position of bitfield l4_chk_en */
+#define tpol4chk_en_shift 0
+/* width of bitfield l4_chk_en */
+#define tpol4chk_en_width 1
+/* default value of bitfield l4_chk_en */
+#define tpol4chk_en_default 0x0
+
+/* tx pkt_sys_loopback bitfield definitions
+ * preprocessor definitions for the bitfield "pkt_sys_loopback".
+ * port="pif_tpo_pkt_sys_lbk_i"
+ */
+
+/* register address for bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_adr 0x00007000
+/* bitmask for bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_msk 0x00000080
+/* inverted bitmask for bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_mskn 0xffffff7f
+/* lower bit position of bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_shift 7
+/* width of bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_width 1
+/* default value of bitfield pkt_sys_loopback */
+#define tpo_pkt_sys_lbk_default 0x0
+
+/* tx data_tc_arb_mode bitfield definitions
+ * preprocessor definitions for the bitfield "data_tc_arb_mode".
+ * port="pif_tps_data_tc_arb_mode_i"
+ */
+
+/* register address for bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_adr 0x00007100
+/* bitmask for bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_msk 0x00000001
+/* inverted bitmask for bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_mskn 0xfffffffe
+/* lower bit position of bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_shift 0
+/* width of bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_width 1
+/* default value of bitfield data_tc_arb_mode */
+#define tps_data_tc_arb_mode_default 0x0
+
+/* tx desc_rate_ta_rst bitfield definitions
+ * preprocessor definitions for the bitfield "desc_rate_ta_rst".
+ * port="pif_tps_desc_rate_ta_rst_i"
+ */
+
+/* register address for bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_adr 0x00007310
+/* bitmask for bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_msk 0x80000000
+/* inverted bitmask for bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_mskn 0x7fffffff
+/* lower bit position of bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_shift 31
+/* width of bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_width 1
+/* default value of bitfield desc_rate_ta_rst */
+#define tps_desc_rate_ta_rst_default 0x0
+
+/* tx desc_rate_limit[a:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc_rate_limit[a:0]".
+ * port="pif_tps_desc_rate_lim_i[10:0]"
+ */
+
+/* register address for bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_adr 0x00007310
+/* bitmask for bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_msk 0x000007ff
+/* inverted bitmask for bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_mskn 0xfffff800
+/* lower bit position of bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_shift 0
+/* width of bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_width 11
+/* default value of bitfield desc_rate_limit[a:0] */
+#define tps_desc_rate_lim_default 0x0
+
+/* tx desc_tc_arb_mode[1:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc_tc_arb_mode[1:0]".
+ * port="pif_tps_desc_tc_arb_mode_i[1:0]"
+ */
+
+/* register address for bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_adr 0x00007200
+/* bitmask for bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_msk 0x00000003
+/* inverted bitmask for bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_mskn 0xfffffffc
+/* lower bit position of bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_shift 0
+/* width of bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_width 2
+/* default value of bitfield desc_tc_arb_mode[1:0] */
+#define tps_desc_tc_arb_mode_default 0x0
+
+/* tx desc_tc{t}_credit_max[b:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc_tc{t}_credit_max[b:0]".
+ * parameter: tc {t} | stride size 0x4 | range [0, 7]
+ * port="pif_tps_desc_tc0_credit_max_i[11:0]"
+ */
+
+/* register address for bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_adr(tc) (0x00007210 + (tc) * 0x4)
+/* bitmask for bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_msk 0x0fff0000
+/* inverted bitmask for bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_mskn 0xf000ffff
+/* lower bit position of bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_shift 16
+/* width of bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_width 12
+/* default value of bitfield desc_tc{t}_credit_max[b:0] */
+#define tps_desc_tctcredit_max_default 0x0
+
+/* tx desc_tc{t}_weight[8:0] bitfield definitions
+ * preprocessor definitions for the bitfield "desc_tc{t}_weight[8:0]".
+ * parameter: tc {t} | stride size 0x4 | range [0, 7]
+ * port="pif_tps_desc_tc0_weight_i[8:0]"
+ */
+
+/* register address for bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_adr(tc) (0x00007210 + (tc) * 0x4)
+/* bitmask for bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_msk 0x000001ff
+/* inverted bitmask for bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_mskn 0xfffffe00
+/* lower bit position of bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_shift 0
+/* width of bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_width 9
+/* default value of bitfield desc_tc{t}_weight[8:0] */
+#define tps_desc_tctweight_default 0x0
+
+/* tx desc_vm_arb_mode bitfield definitions
+ * preprocessor definitions for the bitfield "desc_vm_arb_mode".
+ * port="pif_tps_desc_vm_arb_mode_i"
+ */
+
+/* register address for bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_adr 0x00007300
+/* bitmask for bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_msk 0x00000001
+/* inverted bitmask for bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_mskn 0xfffffffe
+/* lower bit position of bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_shift 0
+/* width of bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_width 1
+/* default value of bitfield desc_vm_arb_mode */
+#define tps_desc_vm_arb_mode_default 0x0
+
+/* tx data_tc{t}_credit_max[b:0] bitfield definitions
+ * preprocessor definitions for the bitfield "data_tc{t}_credit_max[b:0]".
+ * parameter: tc {t} | stride size 0x4 | range [0, 7]
+ * port="pif_tps_data_tc0_credit_max_i[11:0]"
+ */
+
+/* register address for bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_adr(tc) (0x00007110 + (tc) * 0x4)
+/* bitmask for bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_msk 0x0fff0000
+/* inverted bitmask for bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_mskn 0xf000ffff
+/* lower bit position of bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_shift 16
+/* width of bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_width 12
+/* default value of bitfield data_tc{t}_credit_max[b:0] */
+#define tps_data_tctcredit_max_default 0x0
+
+/* tx data_tc{t}_weight[8:0] bitfield definitions
+ * preprocessor definitions for the bitfield "data_tc{t}_weight[8:0]".
+ * parameter: tc {t} | stride size 0x4 | range [0, 7]
+ * port="pif_tps_data_tc0_weight_i[8:0]"
+ */
+
+/* register address for bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_adr(tc) (0x00007110 + (tc) * 0x4)
+/* bitmask for bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_msk 0x000001ff
+/* inverted bitmask for bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_mskn 0xfffffe00
+/* lower bit position of bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_shift 0
+/* width of bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_width 9
+/* default value of bitfield data_tc{t}_weight[8:0] */
+#define tps_data_tctweight_default 0x0
+
+/* tx reg_res_dsbl bitfield definitions
+ * preprocessor definitions for the bitfield "reg_res_dsbl".
+ * port="pif_tx_reg_res_dsbl_i"
+ */
+
+/* register address for bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_adr 0x00007000
+/* bitmask for bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_msk 0x20000000
+/* inverted bitmask for bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_mskn 0xdfffffff
+/* lower bit position of bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_shift 29
+/* width of bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_width 1
+/* default value of bitfield reg_res_dsbl */
+#define tx_reg_res_dsbl_default 0x1
+
+/* mac_phy register access busy bitfield definitions
+ * preprocessor definitions for the bitfield "register access busy".
+ * port="msm_pif_reg_busy_o"
+ */
+
+/* register address for bitfield register access busy */
+#define msm_reg_access_busy_adr 0x00004400
+/* bitmask for bitfield register access busy */
+#define msm_reg_access_busy_msk 0x00001000
+/* inverted bitmask for bitfield register access busy */
+#define msm_reg_access_busy_mskn 0xffffefff
+/* lower bit position of bitfield register access busy */
+#define msm_reg_access_busy_shift 12
+/* width of bitfield register access busy */
+#define msm_reg_access_busy_width 1
+
+/* mac_phy msm register address[7:0] bitfield definitions
+ * preprocessor definitions for the bitfield "msm register address[7:0]".
+ * port="pif_msm_reg_addr_i[7:0]"
+ */
+
+/* register address for bitfield msm register address[7:0] */
+#define msm_reg_addr_adr 0x00004400
+/* bitmask for bitfield msm register address[7:0] */
+#define msm_reg_addr_msk 0x000000ff
+/* inverted bitmask for bitfield msm register address[7:0] */
+#define msm_reg_addr_mskn 0xffffff00
+/* lower bit position of bitfield msm register address[7:0] */
+#define msm_reg_addr_shift 0
+/* width of bitfield msm register address[7:0] */
+#define msm_reg_addr_width 8
+/* default value of bitfield msm register address[7:0] */
+#define msm_reg_addr_default 0x0
+
+/* mac_phy register read strobe bitfield definitions
+ * preprocessor definitions for the bitfield "register read strobe".
+ * port="pif_msm_reg_rden_i"
+ */
+
+/* register address for bitfield register read strobe */
+#define msm_reg_rd_strobe_adr 0x00004400
+/* bitmask for bitfield register read strobe */
+#define msm_reg_rd_strobe_msk 0x00000200
+/* inverted bitmask for bitfield register read strobe */
+#define msm_reg_rd_strobe_mskn 0xfffffdff
+/* lower bit position of bitfield register read strobe */
+#define msm_reg_rd_strobe_shift 9
+/* width of bitfield register read strobe */
+#define msm_reg_rd_strobe_width 1
+/* default value of bitfield register read strobe */
+#define msm_reg_rd_strobe_default 0x0
+
+/* mac_phy msm register read data[31:0] bitfield definitions
+ * preprocessor definitions for the bitfield "msm register read data[31:0]".
+ * port="msm_pif_reg_rd_data_o[31:0]"
+ */
+
+/* register address for bitfield msm register read data[31:0] */
+#define msm_reg_rd_data_adr 0x00004408
+/* bitmask for bitfield msm register read data[31:0] */
+#define msm_reg_rd_data_msk 0xffffffff
+/* inverted bitmask for bitfield msm register read data[31:0] */
+#define msm_reg_rd_data_mskn 0x00000000
+/* lower bit position of bitfield msm register read data[31:0] */
+#define msm_reg_rd_data_shift 0
+/* width of bitfield msm register read data[31:0] */
+#define msm_reg_rd_data_width 32
+
+/* mac_phy msm register write data[31:0] bitfield definitions
+ * preprocessor definitions for the bitfield "msm register write data[31:0]".
+ * port="pif_msm_reg_wr_data_i[31:0]"
+ */
+
+/* register address for bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_adr 0x00004404
+/* bitmask for bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_msk 0xffffffff
+/* inverted bitmask for bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_mskn 0x00000000
+/* lower bit position of bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_shift 0
+/* width of bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_width 32
+/* default value of bitfield msm register write data[31:0] */
+#define msm_reg_wr_data_default 0x0
+
+/* mac_phy register write strobe bitfield definitions
+ * preprocessor definitions for the bitfield "register write strobe".
+ * port="pif_msm_reg_wren_i"
+ */
+
+/* register address for bitfield register write strobe */
+#define msm_reg_wr_strobe_adr 0x00004400
+/* bitmask for bitfield register write strobe */
+#define msm_reg_wr_strobe_msk 0x00000100
+/* inverted bitmask for bitfield register write strobe */
+#define msm_reg_wr_strobe_mskn 0xfffffeff
+/* lower bit position of bitfield register write strobe */
+#define msm_reg_wr_strobe_shift 8
+/* width of bitfield register write strobe */
+#define msm_reg_wr_strobe_width 1
+/* default value of bitfield register write strobe */
+#define msm_reg_wr_strobe_default 0x0
+
+/* mif soft reset bitfield definitions
+ * preprocessor definitions for the bitfield "soft reset".
+ * port="pif_glb_res_i"
+ */
+
+/* register address for bitfield soft reset */
+#define glb_soft_res_adr 0x00000000
+/* bitmask for bitfield soft reset */
+#define glb_soft_res_msk 0x00008000
+/* inverted bitmask for bitfield soft reset */
+#define glb_soft_res_mskn 0xffff7fff
+/* lower bit position of bitfield soft reset */
+#define glb_soft_res_shift 15
+/* width of bitfield soft reset */
+#define glb_soft_res_width 1
+/* default value of bitfield soft reset */
+#define glb_soft_res_default 0x0
+
+/* mif register reset disable bitfield definitions
+ * preprocessor definitions for the bitfield "register reset disable".
+ * port="pif_glb_reg_res_dsbl_i"
+ */
+
+/* register address for bitfield register reset disable */
+#define glb_reg_res_dis_adr 0x00000000
+/* bitmask for bitfield register reset disable */
+#define glb_reg_res_dis_msk 0x00004000
+/* inverted bitmask for bitfield register reset disable */
+#define glb_reg_res_dis_mskn 0xffffbfff
+/* lower bit position of bitfield register reset disable */
+#define glb_reg_res_dis_shift 14
+/* width of bitfield register reset disable */
+#define glb_reg_res_dis_width 1
+/* default value of bitfield register reset disable */
+#define glb_reg_res_dis_default 0x1
+
+/* tx dma debug control definitions */
+#define tx_dma_debug_ctl_adr 0x00008920u
+
+/* tx dma descriptor base address msw definitions */
+#define tx_dma_desc_base_addrmsw_adr(descriptor) \
+			(0x00007c04u + (descriptor) * 0x40)
+
+/* pcie reg_res_dsbl bitfield definitions
+ * preprocessor definitions for the bitfield "reg_res_dsbl".
+ * port="pif_pci_reg_res_dsbl_i"
+ */
+
+/* register address for bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_adr 0x00001000
+/* bitmask for bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_msk 0x20000000
+/* inverted bitmask for bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_mskn 0xdfffffff
+/* lower bit position of bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_shift 29
+/* width of bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_width 1
+/* default value of bitfield reg_res_dsbl */
+#define pci_reg_res_dsbl_default 0x1
+
+/* global microprocessor scratch pad definitions */
+#define glb_cpu_scratch_scp_adr(scratch_scp) (0x00000300u + (scratch_scp) * 0x4)
+
+#endif /* #ifndef HW_ATL_LLH_INTERNAL_H */
-- 
2.7.4
