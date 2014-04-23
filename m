From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] e1000e: Cleanup to fix checkpatch missing blank lines
Date: Wed, 23 Apr 2014 04:15:20 -0700
Message-ID: <1398251726-13638-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbaDWLPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:36 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Fixing "WARNING:SPACING: networking uses a blank line after declarations"

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |  3 +++
 drivers/net/ethernet/intel/e1000e/ich8lan.c |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  | 13 +++++++++++++
 drivers/net/ethernet/intel/e1000e/nvm.c     |  1 +
 drivers/net/ethernet/intel/e1000e/param.c   |  4 ++++
 drivers/net/ethernet/intel/e1000e/phy.c     |  1 +
 6 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 2204a9c..4e5ad7e 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -169,6 +169,7 @@ static int e1000_get_settings(struct net_device *netdev,
 		}
 	} else if (!pm_runtime_suspended(netdev->dev.parent)) {
 		u32 status = er32(STATUS);
+
 		if (status & E1000_STATUS_LU) {
 			if (status & E1000_STATUS_SPEED_1000)
 				speed = SPEED_1000;
@@ -793,6 +794,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 			      int reg, u32 mask, u32 write)
 {
 	u32 val;
+
 	__ew32(&adapter->hw, reg, write & mask);
 	val = __er32(&adapter->hw, reg);
 	if ((write & mask) != (val & mask)) {
@@ -1717,6 +1719,7 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	*data = 0;
 	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
+
 		hw->mac.serdes_has_link = false;
 
 		/* On some blade server designs, link establishment
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9866f26..a290113 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1320,6 +1320,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	 */
 	if ((hw->mac.type == e1000_pch2lan) && link) {
 		u32 reg;
+
 		reg = er32(STATUS);
 		if (!(reg & (E1000_STATUS_FD | E1000_STATUS_SPEED_MASK))) {
 			reg = er32(TIPG);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 255481c..90077e8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -599,6 +599,7 @@ static void e1000e_update_rdt_wa(struct e1000_ring *rx_ring, unsigned int i)
 
 	if (unlikely(!ret_val && (i != readl(rx_ring->tail)))) {
 		u32 rctl = er32(RCTL);
+
 		ew32(RCTL, rctl & ~E1000_RCTL_EN);
 		e_err("ME firmware caused invalid RDT - resetting\n");
 		schedule_work(&adapter->reset_task);
@@ -615,6 +616,7 @@ static void e1000e_update_tdt_wa(struct e1000_ring *tx_ring, unsigned int i)
 
 	if (unlikely(!ret_val && (i != readl(tx_ring->tail)))) {
 		u32 tctl = er32(TCTL);
+
 		ew32(TCTL, tctl & ~E1000_TCTL_EN);
 		e_err("ME firmware caused invalid TDT - resetting\n");
 		schedule_work(&adapter->reset_task);
@@ -1198,6 +1200,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring *tx_ring)
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+
 		rmb();		/* read buffer_info after eop_desc */
 		for (; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
@@ -1753,6 +1756,7 @@ static irqreturn_t e1000_intr_msi(int __always_unused irq, void *data)
 		    adapter->flags & FLAG_RX_NEEDS_RESTART) {
 			/* disable receives */
 			u32 rctl = er32(RCTL);
+
 			ew32(RCTL, rctl & ~E1000_RCTL_EN);
 			adapter->flags |= FLAG_RESTART_NOW;
 		}
@@ -1960,6 +1964,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 	/* Workaround issue with spurious interrupts on 82574 in MSI-X mode */
 	if (hw->mac.type == e1000_82574) {
 		u32 rfctl = er32(RFCTL);
+
 		rfctl |= E1000_RFCTL_ACK_DIS;
 		ew32(RFCTL, rfctl);
 	}
@@ -2204,6 +2209,7 @@ static void e1000_irq_disable(struct e1000_adapter *adapter)
 
 	if (adapter->msix_entries) {
 		int i;
+
 		for (i = 0; i < adapter->num_vectors; i++)
 			synchronize_irq(adapter->msix_entries[i].vector);
 	} else {
@@ -2921,6 +2927,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	if (adapter->flags2 & FLAG2_DMA_BURST) {
 		u32 txdctl = er32(TXDCTL(0));
+
 		txdctl &= ~(E1000_TXDCTL_PTHRESH | E1000_TXDCTL_HTHRESH |
 			    E1000_TXDCTL_WTHRESH);
 		/* set up some performance related parameters to encourage the
@@ -3239,6 +3246,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 
 		if (adapter->flags & FLAG_IS_ICH) {
 			u32 rxdctl = er32(RXDCTL(0));
+
 			ew32(RXDCTL(0), rxdctl | 0x3);
 		}
 
@@ -4695,6 +4703,7 @@ static void e1000e_update_stats(struct e1000_adapter *adapter)
 	/* Correctable ECC Errors */
 	if (hw->mac.type == e1000_pch_lpt) {
 		u32 pbeccsts = er32(PBECCSTS);
+
 		adapter->corr_errors +=
 		    pbeccsts & E1000_PBECCSTS_CORR_ERR_CNT_MASK;
 		adapter->uncorr_errors +=
@@ -4808,6 +4817,7 @@ static void e1000e_enable_receives(struct e1000_adapter *adapter)
 	    (adapter->flags & FLAG_RESTART_NOW)) {
 		struct e1000_hw *hw = &adapter->hw;
 		u32 rctl = er32(RCTL);
+
 		ew32(RCTL, rctl | E1000_RCTL_EN);
 		adapter->flags &= ~FLAG_RESTART_NOW;
 	}
@@ -4930,6 +4940,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			if ((adapter->flags & FLAG_TARC_SPEED_MODE_BIT) &&
 			    !txb2b) {
 				u32 tarc0;
+
 				tarc0 = er32(TARC(0));
 				tarc0 &= ~SPEED_MODE_BIT;
 				ew32(TARC(0), tarc0);
@@ -6209,6 +6220,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 		e1e_wphy(&adapter->hw, BM_WUS, ~0);
 	} else {
 		u32 wus = er32(WUS);
+
 		if (wus) {
 			e_info("MAC Wakeup cause - %s\n",
 			       wus & E1000_WUS_EX ? "Unicast Packet" :
@@ -7144,6 +7156,7 @@ static struct pci_driver e1000_driver = {
 static int __init e1000_init_module(void)
 {
 	int ret;
+
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
 	pr_info("Copyright(c) 1999 - 2014 Intel Corporation.\n");
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index a9a976f..b1f212b 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -398,6 +398,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		/* Loop to allow for up to whole page write of eeprom */
 		while (widx < words) {
 			u16 word_out = data[widx];
+
 			word_out = (word_out >> 8) | (word_out << 8);
 			e1000_shift_out_eec_bits(hw, word_out, 16);
 			widx++;
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index d0ac0f3..aa1923f 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -436,6 +436,7 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_IntMode > bd) {
 			unsigned int int_mode = IntMode[bd];
+
 			e1000_validate_option(&int_mode, &opt, adapter);
 			adapter->int_mode = int_mode;
 		} else {
@@ -457,6 +458,7 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_SmartPowerDownEnable > bd) {
 			unsigned int spd = SmartPowerDownEnable[bd];
+
 			e1000_validate_option(&spd, &opt, adapter);
 			if ((adapter->flags & FLAG_HAS_SMART_POWER_DOWN) && spd)
 				adapter->flags |= FLAG_SMART_POWER_DOWN;
@@ -473,6 +475,7 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_CrcStripping > bd) {
 			unsigned int crc_stripping = CrcStripping[bd];
+
 			e1000_validate_option(&crc_stripping, &opt, adapter);
 			if (crc_stripping == OPTION_ENABLED) {
 				adapter->flags2 |= FLAG2_CRC_STRIPPING;
@@ -495,6 +498,7 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_KumeranLockLoss > bd) {
 			unsigned int kmrn_lock_loss = KumeranLockLoss[bd];
+
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			enabled = kmrn_lock_loss;
 		}
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 00b3fc9..b2005e1 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -2896,6 +2896,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 		    (hw->phy.addr == 2) &&
 		    !(MAX_PHY_REG_ADDRESS & reg) && (data & (1 << 11))) {
 			u16 data2 = 0x7EFF;
+
 			ret_val = e1000_access_phy_debug_regs_hv(hw,
 								 (1 << 6) | 0x3,
 								 &data2, false);
-- 
1.9.0
