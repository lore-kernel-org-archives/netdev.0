From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 20/26] et131x: sort out the mmc enable routine
Date: Tue, 25 Aug 2009 16:00:42 +0100
Message-ID: <20090825150038.16176.64713.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47819 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755347AbZHYPGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:06:05 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_address_map.h |   34 +++++++--------------------
 drivers/staging/et131x/et1310_jagcore.c     |   14 +----------
 2 files changed, 10 insertions(+), 38 deletions(-)


diff --git a/drivers/staging/et131x/et1310_address_map.h b/drivers/staging/et131x/et1310_address_map.h
index 388ac40..d2ac26c 100644
--- a/drivers/staging/et131x/et1310_address_map.h
+++ b/drivers/staging/et131x/et1310_address_map.h
@@ -2267,30 +2267,14 @@ typedef struct _MAC_STAT_t {		/* Location: */
  * structure for Main Memory Controller Control reg in mmc address map.
  * located at address 0x7000
  */
-typedef union _MMC_CTRL_t {
-	u32 value;
-	struct {
-#ifdef _BIT_FIELDS_HTOL
-		u32 reserved:25;		/* bits 7-31 */
-		u32 force_ce:1;		/* bit 6 */
-		u32 rxdma_disable:1;	/* bit 5 */
-		u32 txdma_disable:1;	/* bit 4 */
-		u32 txmac_disable:1;	/* bit 3 */
-		u32 rxmac_disable:1;	/* bit 2 */
-		u32 arb_disable:1;		/* bit 1 */
-		u32 mmc_enable:1;		/* bit 0 */
-#else
-		u32 mmc_enable:1;		/* bit 0 */
-		u32 arb_disable:1;		/* bit 1 */
-		u32 rxmac_disable:1;	/* bit 2 */
-		u32 txmac_disable:1;	/* bit 3 */
-		u32 txdma_disable:1;	/* bit 4 */
-		u32 rxdma_disable:1;	/* bit 5 */
-		u32 force_ce:1;		/* bit 6 */
-		u32 reserved:25;		/* bits 7-31 */
-#endif
-	} bits;
-} MMC_CTRL_t, *PMMC_CTRL_t;
+ 
+#define ET_MMC_ENABLE		1
+#define ET_MMC_ARB_DISABLE	2
+#define ET_MMC_RXMAC_DISABLE	4
+#define ET_MMC_TXMAC_DISABLE	8
+#define ET_MMC_TXDMA_DISABLE	16
+#define ET_MMC_RXDMA_DISABLE	32
+#define ET_MMC_FORCE_CE		64
 
 /*
  * structure for Main Memory Controller Host Memory Access Address reg in mmc
@@ -2329,7 +2313,7 @@ typedef union _MMC_SRAM_ACCESS_t {
  * Memory Control Module of JAGCore Address Mapping
  */
 typedef struct _MMC_t {			/* Location: */
-	MMC_CTRL_t mmc_ctrl;		/*  0x7000 */
+	u32 mmc_ctrl;		/*  0x7000 */
 	MMC_SRAM_ACCESS_t sram_access;	/*  0x7004 */
 	u32 sram_word1;		/*  0x7008 */
 	u32 sram_word2;		/*  0x700C */
diff --git a/drivers/staging/et131x/et1310_jagcore.c b/drivers/staging/et131x/et1310_jagcore.c
index 5c847ad..2767e4d 100644
--- a/drivers/staging/et131x/et1310_jagcore.c
+++ b/drivers/staging/et131x/et1310_jagcore.c
@@ -175,21 +175,9 @@ void ConfigGlobalRegs(struct et131x_adapter *etdev)
  */
 void ConfigMMCRegs(struct et131x_adapter *etdev)
 {
-	MMC_CTRL_t mmc_ctrl = { 0 };
-
 	DBG_ENTER(et131x_dbginfo);
-
 	/* All we need to do is initialize the Memory Control Register */
-	mmc_ctrl.bits.force_ce = 0x0;
-	mmc_ctrl.bits.rxdma_disable = 0x0;
-	mmc_ctrl.bits.txdma_disable = 0x0;
-	mmc_ctrl.bits.txmac_disable = 0x0;
-	mmc_ctrl.bits.rxmac_disable = 0x0;
-	mmc_ctrl.bits.arb_disable = 0x0;
-	mmc_ctrl.bits.mmc_enable = 0x1;
-
-	writel(mmc_ctrl.value, &etdev->regs->mmc.mmc_ctrl.value);
-
+	writel(ET_MMC_ENABLE, &etdev->regs->mmc.mmc_ctrl);
 	DBG_LEAVE(et131x_dbginfo);
 }
 

