From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 2/9] tg3: 5717_PLUS => 57765_PLUS
Date: Tue, 5 Apr 2011 17:22:44 -0700
Message-ID: <1302049371-13799-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4643 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57765 arrived before the 5717 and has a subset of the features
supported by the 5717.  This patch renames the 5717_PLUS flag so that it
can be reintroduced to designate only 5717 and later devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   42 +++++++++++++++++++++---------------------
 drivers/net/tg3.h |    2 +-
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8ffa5af..4f8976b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7095,7 +7095,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
 		/* Force PCIe 1.0a mode */
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-		    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+		    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
 		    tr32(TG3_PCIE_PHY_TSTCTL) ==
 		    (TG3_PCIE_PHY_TSTCTL_PCIE10 | TG3_PCIE_PHY_TSTCTL_PSCRAM))
 			tw32(TG3_PCIE_PHY_TSTCTL, TG3_PCIE_PHY_TSTCTL_PSCRAM);
@@ -7248,7 +7248,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
+	    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
 		val = tr32(0x7c00);
 
 		tw32(0x7c00, val | (1 << 25));
@@ -7958,7 +7958,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 		val = tr32(TG3PCI_DMA_RW_CTRL) &
 		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0)
@@ -8126,7 +8126,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     BDINFO_FLAGS_DISABLED);
 		}
 
-		if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+		if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 				val = TG3_RX_STD_MAX_SIZE_5700;
 			else
@@ -8147,7 +8147,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			  tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 		tw32(STD_REPLENISH_LWM, 32);
 		tw32(JMB_REPLENISH_LWM, 16);
 	}
@@ -8218,7 +8218,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
+	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
 			val &= ~(TG3_RDMA_RSRVCTRL_TXMRGN_MASK |
@@ -8866,7 +8866,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	 * Turn off MSI one shot mode.  Otherwise this test has no
 	 * observable way to know whether the interrupt was delivered.
 	 */
-	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+	if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
 	    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 		val = tr32(MSGINT_MODE) | MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
@@ -8909,7 +8909,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	if (intr_ok) {
 		/* Reenable MSI one shot mode. */
-		if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+		if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
 		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
 			tw32(MSGINT_MODE, val);
@@ -9212,7 +9212,7 @@ static int tg3_open(struct net_device *dev)
 			goto err_out2;
 		}
 
-		if (!(tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+		if (!(tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
 		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
 			u32 val = tr32(PCIE_TRANSACTION_CFG);
 
@@ -12470,7 +12470,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg2 & (1 << 18))
 			tp->phy_flags |= TG3_PHYFLG_SERDES_PREEMPHASIS;
 
-		if (((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) ||
+		if (((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) ||
 		    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX))) &&
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
@@ -12478,7 +12478,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 
 		if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-		    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
+		    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
 			u32 cfg3;
 
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &cfg3);
@@ -13335,7 +13335,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
-		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
+		tp->tg3_flags3 |= TG3_FLG3_57765_PLUS;
 
 	/* Intentionally exclude ASIC_REV_5906 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
@@ -13344,7 +13344,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
+	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS))
 		tp->tg3_flags3 |= TG3_FLG3_5755_PLUS;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
@@ -13376,7 +13376,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* Determine TSO capabilities */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		; /* Do nothing. HW bug. */
-	else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	else if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
 	else if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
@@ -13412,7 +13412,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
 		}
 
-		if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+		if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 			tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
 			tp->irq_max = TG3_IRQ_MAX_VECS;
 		}
@@ -13431,7 +13431,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+	if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
 		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
 
@@ -13637,7 +13637,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
+	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS))
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 	/* Set up tp->grc_local_ctrl before calling tg_power_up().
@@ -13716,7 +13716,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    !(tp->phy_flags & TG3_PHYFLG_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780 &&
-	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
+	    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
@@ -14052,7 +14052,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 #endif
 #endif
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 		val = goal ? 0 : DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		goto out;
 	}
@@ -14269,7 +14269,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 
 	tp->dma_rwctrl = tg3_calc_dma_bndry(tp, tp->dma_rwctrl);
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
 		goto out;
 
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
@@ -14444,7 +14444,7 @@ out_nofree:
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 4c498ed..6f34db5 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2915,7 +2915,7 @@ struct tg3 {
 #define TG3_FLG3_SHORT_DMA_BUG		0x00200000
 #define TG3_FLG3_USE_JUMBO_BDFLAG	0x00400000
 #define TG3_FLG3_L1PLLPD_EN		0x00800000
-#define TG3_FLG3_5717_PLUS		0x01000000
+#define TG3_FLG3_57765_PLUS		0x01000000
 #define TG3_FLG3_APE_HAS_NCSI		0x02000000
 
 	struct timer_list		timer;
-- 
1.7.3.4


