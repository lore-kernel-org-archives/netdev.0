From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] tg3: Remove define and single use of GET_CHIP_REV_ID
Date: Sat, 16 Feb 2013 13:20:03 -0800
Message-ID: <dea1c655b2c1380821aae6cd8438ad742ddf6e12.1361049158.git.joe@perches.com>
Cc: Matt Carlson <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's the same value as tp->pci_chip_rev_id so use that
instead.  This makes all CHIPREV_ID_<foo> tests the same.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 10 ++++------
 drivers/net/ethernet/broadcom/tg3.h |  4 +---
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 1b59876..f511e8b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15761,12 +15761,10 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 			      &pci_state_reg);
 	if ((pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0 &&
 	    !tg3_flag(tp, PCIX_TARGET_HWBUG)) {
-		u32 chiprevid = GET_CHIP_REV_ID(tp->misc_host_ctrl);
-
-		if (chiprevid == CHIPREV_ID_5701_A0 ||
-		    chiprevid == CHIPREV_ID_5701_B0 ||
-		    chiprevid == CHIPREV_ID_5701_B2 ||
-		    chiprevid == CHIPREV_ID_5701_B5) {
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5701_B2 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5701_B5) {
 			void __iomem *sram_base;
 
 			/* Write some dummy words into the SRAM status block
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index b676728..3e27f2e 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -120,9 +120,7 @@
 #define  MISC_HOST_CTRL_TAGGED_STATUS	 0x00000200
 #define  MISC_HOST_CTRL_CHIPREV		 0xffff0000
 #define  MISC_HOST_CTRL_CHIPREV_SHIFT	 16
-#define  GET_CHIP_REV_ID(MISC_HOST_CTRL) \
-	 (((MISC_HOST_CTRL) & MISC_HOST_CTRL_CHIPREV) >> \
-	  MISC_HOST_CTRL_CHIPREV_SHIFT)
+
 #define  CHIPREV_ID_5700_A0		 0x7000
 #define  CHIPREV_ID_5700_A1		 0x7001
 #define  CHIPREV_ID_5700_B0		 0x7100
-- 
1.8.1.2.459.gbcd45b4.dirty
