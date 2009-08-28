From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/17] tg3: Move the JUMBO_CAPABLE and SUPPORT_MSI flags
Date: Fri, 28 Aug 2009 16:58:24 -0700
Message-ID: <1251585281.29675@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2417 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616AbZH2Wev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves where the jumbo capable and msi support flags are
located.  This is prep work for the addition of msix support flags.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   10 +++++-----
 drivers/net/tg3.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 606703c..5e74a19 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -92,7 +92,7 @@
 /* hardware minimum and maximum for a single frame's data payload */
 #define TG3_MIN_MTU			60
 #define TG3_MAX_MTU(tp)	\
-	((tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) ? 9000 : 1500)
+	((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ? 9000 : 1500)
 
 /* These numbers seem to be hard coded in the NIC firmware somehow.
  * You can't change the ring sizes, but you can change where you place
@@ -1921,7 +1921,7 @@ out:
 	if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
 		/* Cannot do read-modify-write on 5401 */
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4c20);
-	} else if (tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) {
+	} else if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
 		u32 phy_reg;
 
 		/* Set bit 14 with read-modify-write to preserve other bits */
@@ -1933,7 +1933,7 @@ out:
 	/* Set phy register 0x10 bit 0 to high fifo elasticity to support
 	 * jumbo frames transmission.
 	 */
-	if (tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) {
+	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
 		u32 phy_reg;
 
 		if (!tg3_readphy(tp, MII_TG3_EXT_CTRL, &phy_reg))
@@ -6975,7 +6975,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Program the jumbo buffer descriptor ring control
 	 * blocks on those devices that have them.
 	 */
-	if ((tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) &&
+	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
 	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 		/* Setup replenish threshold. */
 		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
@@ -12034,7 +12034,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
 	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
-		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
+		tp->tg3_flags |= TG3_FLAG_JUMBO_CAPABLE;
 
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
 			      &pci_state_reg);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 1c9495d..5efae2c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2601,6 +2601,7 @@ struct tg3 {
 #define TG3_FLAG_EEPROM_WRITE_PROT	0x00001000
 #define TG3_FLAG_NVRAM			0x00002000
 #define TG3_FLAG_NVRAM_BUFFERED		0x00004000
+#define TG3_FLAG_SUPPORT_MSI		0x00008000
 #define TG3_FLAG_PCIX_MODE		0x00020000
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000
@@ -2613,7 +2614,7 @@ struct tg3 {
 #define TG3_FLAG_CPMU_PRESENT		0x04000000
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
-#define TG3_FLAG_SUPPORT_MSI		0x20000000
+#define TG3_FLAG_JUMBO_CAPABLE		0x20000000
 #define TG3_FLAG_CHIP_RESETTING		0x40000000
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;
@@ -2639,7 +2640,6 @@ struct tg3 {
 #define TG3_FLG2_5750_PLUS		0x00080000
 #define TG3_FLG2_PROTECTED_NVRAM	0x00100000
 #define TG3_FLG2_USING_MSI		0x00200000
-#define TG3_FLG2_JUMBO_CAPABLE		0x00400000
 #define TG3_FLG2_MII_SERDES		0x00800000
 #define TG3_FLG2_ANY_SERDES		(TG3_FLG2_PHY_SERDES |	\
 					TG3_FLG2_MII_SERDES)
-- 
1.6.3.3


