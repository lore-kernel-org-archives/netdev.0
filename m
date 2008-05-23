From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/8] tg3: Add 5785 ASIC revision
Date: Thu, 22 May 2008 19:57:08 -0700
Message-ID: <1211511428.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1131 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761654AbYEWCxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch added the 5785 device ID and ASIC revision to the code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a555ddc..62e6e26 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -204,6 +204,7 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5723)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5785)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -5710,7 +5711,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tw32(GRC_FASTBOOT_PC, 0);
 
 	/*
@@ -7004,7 +7006,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		return err;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
 		/* This value is determined during the probe time DMA
 		 * engine test, tg3_test_dma.
 		 */
@@ -7243,7 +7246,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
 		      RDMAC_MODE_LNGREAD_ENAB);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		rdmac_mode |= RDMAC_MODE_BD_SBD_CRPT_ENAB |
 			      RDMAC_MODE_MBUF_RBD_CRPT_ENAB |
 			      RDMAC_MODE_MBUF_SBD_CRPT_ENAB;
@@ -7411,7 +7415,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761))
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785))
 		val |= WDMAC_MODE_STATUS_TAG_FIX;
 
 	tw32_f(WDMAC_MODE, val);
@@ -7473,7 +7478,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tp->rx_mode = RX_MODE_ENABLE;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
@@ -9028,7 +9035,10 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)) {
 		if (value) {
 			dev->features |= NETIF_F_TSO6;
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+			    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+			     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 				dev->features |= NETIF_F_TSO_ECN;
 		} else
 			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
@@ -9286,7 +9296,8 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
 		ethtool_op_set_tx_csum(dev, data);
@@ -9807,7 +9818,8 @@ static int tg3_test_memory(struct tg3 *tp)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 			mem_tbl = mem_tbl_5755;
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			mem_tbl = mem_tbl_5906;
@@ -10014,7 +10026,8 @@ static int tg3_test_loopback(struct tg3 *tp)
 		return TG3_LOOPBACK_FAILED;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		int i;
 		u32 status;
 
@@ -10042,7 +10055,8 @@ static int tg3_test_loopback(struct tg3 *tp)
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */
@@ -10690,7 +10704,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 			tg3_get_5755_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 			tg3_get_5787_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 			tg3_get_5761_nvram_info(tp);
@@ -11021,6 +11036,7 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) &&
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
 		    (nvram_cmd & NVRAM_CMD_FIRST)) {
 
@@ -11924,6 +11940,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
@@ -11945,6 +11962,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
@@ -12147,7 +12165,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
@@ -12231,7 +12250,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
 			if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5755M)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_ADJUST_TRIM;
-		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
+		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906 &&
+			   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785)
 			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 	}
 
@@ -12252,6 +12272,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
 		tp->coalesce_mode |= HOSTCC_MODE_32BYTE;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
+
 	err = tg3_mdio_init(tp);
 	if (err)
 		return err;
@@ -12383,6 +12406,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->dev->hard_start_xmit = tg3_start_xmit;
 	else
@@ -13307,7 +13331,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906))
 			dev->features |= NETIF_F_TSO6;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
+			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 			dev->features |= NETIF_F_TSO_ECN;
 	}
 
@@ -13373,7 +13400,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 			dev->features |= NETIF_F_IPV6_CSUM;
 
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 48f45c1..95ac4c9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -128,6 +128,7 @@
 #define   ASIC_REV_USE_PROD_ID_REG	 0x0f
 #define   ASIC_REV_5784			 0x5784
 #define   ASIC_REV_5761			 0x5761
+#define   ASIC_REV_5785			 0x5785
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index cf6dbd7..72c0385 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1979,6 +1979,7 @@
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
 #define PCI_DEVICE_ID_TIGON3_5784	0x1698
+#define PCI_DEVICE_ID_TIGON3_5785	0x1699
 #define PCI_DEVICE_ID_TIGON3_5786	0x169a
 #define PCI_DEVICE_ID_TIGON3_5787	0x169b
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c


