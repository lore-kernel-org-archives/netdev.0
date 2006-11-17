From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 16/17][BNX2]: Add 5709 PCI ID.
Date: Thu, 16 Nov 2006 19:14:56 -0800
Message-ID: <1163733296.6658.49.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:35857 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424932AbWKQCWd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:22:33 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 5709 PCI ID.

Add PCI ID and detection for 5709 copper and SerDes chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 92897ef..157463b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -86,6 +86,7 @@ typedef enum {
 	NC370F,
 	BCM5708,
 	BCM5708S,
+	BCM5709,
 } board_t;
 
 /* indexed by board_t, above */
@@ -99,6 +100,7 @@ static const struct {
 	{ "HP NC370F Multifunction Gigabit Server Adapter" },
 	{ "Broadcom NetXtreme II BCM5708 1000Base-T" },
 	{ "Broadcom NetXtreme II BCM5708 1000Base-SX" },
+	{ "Broadcom NetXtreme II BCM5709 1000Base-T" },
 	};
 
 static struct pci_device_id bnx2_pci_tbl[] = {
@@ -116,6 +118,8 @@ static struct pci_device_id bnx2_pci_tbl
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5706S },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5708S,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5708S },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709 },
 	{ 0, }
 };
 
@@ -5854,10 +5858,15 @@ bnx2_init_board(struct pci_dev *pdev, st
 	bp->phy_addr = 1;
 
 	/* Disable WOL support if we are running on a SERDES chip. */
-	if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT) {
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		if (CHIP_BOND_ID(bp) != BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_C)
+			bp->phy_flags |= PHY_SERDES_FLAG;
+	} else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
 		bp->phy_flags |= PHY_SERDES_FLAG;
+
+	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		bp->flags |= NO_WOL_FLAG;
-		if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
 			bp->phy_addr = 2;
 			reg = REG_RD_IND(bp, bp->shmem_base +
 					 BNX2_SHARED_HW_CFG_CONFIG);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index fa4e1d7..6294559 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1893,6 +1893,7 @@
 #define PCI_VENDOR_ID_BROADCOM		0x14e4
 #define PCI_DEVICE_ID_TIGON3_5752	0x1600
 #define PCI_DEVICE_ID_TIGON3_5752M	0x1601
+#define PCI_DEVICE_ID_NX2_5709		0x1639
 #define PCI_DEVICE_ID_TIGON3_5700	0x1644
 #define PCI_DEVICE_ID_TIGON3_5701	0x1645
 #define PCI_DEVICE_ID_TIGON3_5702	0x1646


