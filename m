From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 17/26] et131x: continue pruning unused fields
Date: Tue, 25 Aug 2009 16:00:16 +0100
Message-ID: <20090825150013.16176.8156.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47807 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755385AbZHYPFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:05:37 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_jagcore.h |   19 -------------------
 drivers/staging/et131x/et1310_phy.c     |    2 +-
 drivers/staging/et131x/et131x_adapter.h |    4 ----
 3 files changed, 1 insertions(+), 24 deletions(-)


diff --git a/drivers/staging/et131x/et1310_jagcore.h b/drivers/staging/et131x/et1310_jagcore.h
index 78228af..0807a01 100644
--- a/drivers/staging/et131x/et1310_jagcore.h
+++ b/drivers/staging/et131x/et1310_jagcore.h
@@ -65,8 +65,6 @@
 #define INTERNAL_MEM_SIZE       0x400	/* 1024 of internal memory */
 #define INTERNAL_MEM_RX_OFFSET  0x1FF	/* 50%   Tx, 50%   Rx */
 
-#define REGS_MAX_ARRAY          4096
-
 /*
  * For interrupts, normal running is:
  *       rxdma_xfr_done, phy_interrupt, mac_stat_interrupt,
@@ -85,23 +83,6 @@
 #define INT_MASK_ENABLE             0xfffebf17
 #define INT_MASK_ENABLE_NO_FLOW     0xfffebfd7
 
-/* DATA STRUCTURES FOR DIRECT REGISTER ACCESS */
-
-typedef struct {
-	u8 bReadWrite;
-	u32 nRegCount;
-	u32 nData[REGS_MAX_ARRAY];
-	u32 nOffsets[REGS_MAX_ARRAY];
-} JAGCORE_ACCESS_REGS, *PJAGCORE_ACCESS_REGS;
-
-typedef struct {
-	u8 bReadWrite;
-	u32 nDataWidth;
-	u32 nRegCount;
-	u32 nOffsets[REGS_MAX_ARRAY];
-	u32 nData[REGS_MAX_ARRAY];
-} PCI_CFG_SPACE_REGS, *PPCI_CFG_SPACE_REGS;
-
 /* Forward declaration of the private adapter structure */
 struct et131x_adapter;
 
diff --git a/drivers/staging/et131x/et1310_phy.c b/drivers/staging/et131x/et1310_phy.c
index a16ce16..19ffb65 100644
--- a/drivers/staging/et131x/et1310_phy.c
+++ b/drivers/staging/et131x/et1310_phy.c
@@ -547,7 +547,7 @@ void et131x_Mii_check(struct et131x_adapter *etdev,
 			}
 
 			etdev->linkspeed = 0;
-			etdev->duplexMode = 0;
+			etdev->duplex_mode = 0;
 
 			/* Free the packets being actively sent & stopped */
 			et131x_free_busy_send_packets(etdev);
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 3ac2343..04bb603 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -284,10 +284,6 @@ struct et131x_adapter {
 	/* Rx Memory Variables */
 	RX_RING_t RxRing;
 
-	/* ET1310 register Access */
-	JAGCORE_ACCESS_REGS JagCoreRegs;
-	PCI_CFG_SPACE_REGS PciCfgRegs;
-
 	/* Loopback specifics */
 	u8 ReplicaPhyLoopbk;	/* Replica Enable */
 	u8 ReplicaPhyLoopbkPF;	/* Replica Enable Pass/Fail */

