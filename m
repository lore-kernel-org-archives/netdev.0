From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/7] tg3: Add 5720 ASIC rev
Date: Mon, 4 Apr 2011 11:24:49 -0700
Message-ID: <1301941495-8069-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1128 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176Ab1DDSTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:19:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 5720 ASIC rev.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   67 +++++++++++++++++++++++++++++++++++++---------------
 drivers/net/tg3.h |    5 ++++
 2 files changed, 52 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b7e03a6..b105cdd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -98,12 +98,14 @@
  */
 #define TG3_RX_STD_RING_SIZE(tp) \
 	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
-	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
+	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 || \
+	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) ? \
 	 RX_STD_MAX_SIZE_5717 : 512)
 #define TG3_DEF_RX_RING_PENDING		200
 #define TG3_RX_JMB_RING_SIZE(tp) \
 	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
-	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
+	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 || \
+	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) ? \
 	 1024 : 256)
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
 #define TG3_RSS_INDIR_TBL_SIZE		128
@@ -1045,7 +1047,8 @@ static int tg3_mdio_init(struct tg3 *tp)
 	struct phy_device *phydev;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 		u32 is_serdes;
 
 		tp->phy_addr = PCI_FUNC(tp->pdev->devfn) + 1;
@@ -1624,7 +1627,8 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
 	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	      GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) &&
+	      GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	      GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
 	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)))
 		return;
 
@@ -2048,7 +2052,8 @@ static int tg3_phy_reset(struct tg3 *tp)
 	}
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) &&
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
 	    (tp->phy_flags & TG3_PHYFLG_MII_SERDES))
 		return 0;
 
@@ -2130,7 +2135,8 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) &&
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
 	    tp->pdev_peer != tp->pdev) {
 		struct net_device *dev_peer;
 
@@ -7256,6 +7262,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(0x7c00, val | (1 << 25));
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
+		val = tr32(TG3_CPMU_CLCK_ORIDE);
+		tw32(TG3_CPMU_CLCK_ORIDE, val & ~CPMU_CLCK_ORIDE_MAC_ORIDE_EN);
+	}
+
 	/* Reprobe ASF enable state.  */
 	tp->tg3_flags &= ~TG3_FLAG_ENABLE_ASF;
 	tp->tg3_flags2 &= ~TG3_FLG2_ASF_NEW_HANDSHAKE;
@@ -7674,7 +7685,8 @@ static void tg3_rings_reset(struct tg3 *tp)
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
@@ -7689,7 +7701,8 @@ static void tg3_rings_reset(struct tg3 *tp)
 
 	/* Disable all receive return rings but the first. */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
 	else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
@@ -8092,7 +8105,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tpr->rx_std_mapping & 0xffffffff));
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5720)
 		tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 		     NIC_SRAM_RX_BUFFER_DESC);
 
@@ -8221,7 +8235,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
 	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 			val &= ~(TG3_RDMA_RSRVCTRL_TXMRGN_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_LWM_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_HWM_MASK);
@@ -8233,7 +8248,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		     val | TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX);
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 		val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
 		tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val |
 		     TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K |
@@ -8422,7 +8438,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
 	val = RCVDBDI_MODE_ENABLE | RCVDBDI_MODE_INV_RING_SZ;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		val |= RCVDBDI_MODE_LRG_RING_SZ;
 	tw32(RCVDBDI_MODE, val);
 	tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
@@ -9058,7 +9075,9 @@ static bool tg3_enable_msix(struct tg3 *tp)
 
 	if (tp->irq_cnt > 1) {
 		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
 			netif_set_real_num_tx_queues(tp->dev, tp->irq_cnt - 1);
 		}
@@ -10851,7 +10870,8 @@ static int tg3_test_memory(struct tg3 *tp)
 	int i;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		mem_tbl = mem_tbl_5717;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		mem_tbl = mem_tbl_57765;
@@ -11933,7 +11953,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 			tg3_get_57780_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 			tg3_get_5717_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
@@ -13126,7 +13147,8 @@ static inline void vlan_features_add(struct net_device *dev, unsigned long flags
 static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 {
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		return 4096;
 	else if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
 		 !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
@@ -13177,7 +13199,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719)
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720)
 			pci_read_config_dword(tp->pdev,
 					      TG3PCI_GEN2_PRODID_ASICREV,
 					      &prod_id_asic_rev);
@@ -13332,11 +13355,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		tp->pdev_peer = tg3_find_peer(tp);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
 
@@ -13449,7 +13474,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 		tp->pcie_readrq = 4096;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 			tp->pcie_readrq = 2048;
 
 		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
@@ -13962,7 +13988,8 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		else
 			tg3_nvram_unlock(tp);
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 		if (PCI_FUNC(tp->pdev->devfn) & 1)
 			mac_offset = 0xcc;
 		if (PCI_FUNC(tp->pdev->devfn) > 1)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 73884b6..9027032 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -54,6 +54,7 @@
 #define  TG3PCI_DEVICE_TIGON3_57791	 0x16b2
 #define  TG3PCI_DEVICE_TIGON3_57795	 0x16b6
 #define  TG3PCI_DEVICE_TIGON3_5719	 0x1657
+#define  TG3PCI_DEVICE_TIGON3_5720	 0x165f
 /* 0x04 --> 0x2c unused */
 #define TG3PCI_SUBVENDOR_ID_BROADCOM		PCI_VENDOR_ID_BROADCOM
 #define TG3PCI_SUBDEVICE_ID_BROADCOM_95700A6	0x1644
@@ -163,6 +164,7 @@
 #define   ASIC_REV_5717			 0x5717
 #define   ASIC_REV_57765		 0x57785
 #define   ASIC_REV_5719			 0x5719
+#define   ASIC_REV_5720			 0x5720
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -1079,6 +1081,9 @@
 #define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
 /* 0x3620 --> 0x3630 unused */
 
+#define TG3_CPMU_CLCK_ORIDE		0x00003624
+#define  CPMU_CLCK_ORIDE_MAC_ORIDE_EN	 0x80000000
+
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
 #define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
-- 
1.7.3.4


