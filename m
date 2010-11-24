From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/10] tg3: Apply 10Mbps fix to all 57765
 revisions
Date: Wed, 24 Nov 2010 10:31:45 -0800
Message-ID: <1290623514-18193-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3201 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab0KXScK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a977dbe8445b8a81d6127c4aa9112a2c29a1a008, entitled
"tg3: Reduce 57765 core clock when link at 10Mbps" needs to be applied
to all revisions of the 57765 asic rev, not just the A0 revision.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30ccbb6..ca6b3cb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7860,18 +7860,21 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(GRC_MODE, grc_mode);
 	}
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
-		u32 grc_mode = tr32(GRC_MODE);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
+			u32 grc_mode = tr32(GRC_MODE);
 
-		/* Access the lower 1K of PL PCIE block registers. */
-		val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
-		tw32(GRC_MODE, val | GRC_MODE_PCIE_PL_SEL);
+			/* Access the lower 1K of PL PCIE block registers. */
+			val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
+			tw32(GRC_MODE, val | GRC_MODE_PCIE_PL_SEL);
 
-		val = tr32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL5);
-		tw32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL5,
-		     val | TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ);
+			val = tr32(TG3_PCIE_TLDLPL_PORT +
+				   TG3_PCIE_PL_LO_PHYCTL5);
+			tw32(TG3_PCIE_TLDLPL_PORT + TG3_PCIE_PL_LO_PHYCTL5,
+			     val | TG3_PCIE_PL_LO_PHYCTL5_DIS_L2CLKREQ);
 
-		tw32(GRC_MODE, grc_mode);
+			tw32(GRC_MODE, grc_mode);
+		}
 
 		val = tr32(TG3_CPMU_LSPD_10MB_CLK);
 		val &= ~CPMU_LSPD_10MB_MACCLK_MASK;
-- 
1.7.2.2


