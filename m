From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/13] tg3: CPMU adjustments for loopback tests
Date: Fri, 09 Nov 2007 16:38:52 -0800
Message-ID: <1194655132.5745.268.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3333 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbXKJAjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the LINK_SPEED mode to the list of CPMU modes that can
cause the loopback tests to fail.  These bugs are planned to be fixed in
future revisions of the chip, so the patch qualifies the fixes as such.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ef849b1..25e57d8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9354,7 +9354,8 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (err)
 		return TG3_LOOPBACK_FAILED;
 
-	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
 		int i;
 		u32 status;
 
@@ -9371,17 +9372,18 @@ static int tg3_test_loopback(struct tg3 *tp)
 		if (status != CPMU_MUTEX_GNT_DRIVER)
 			return TG3_LOOPBACK_FAILED;
 
-		cpmuctrl = tr32(TG3_CPMU_CTRL);
-
 		/* Turn off power management based on link speed. */
+		cpmuctrl = tr32(TG3_CPMU_CTRL);
 		tw32(TG3_CPMU_CTRL,
-		     cpmuctrl & ~CPMU_CTRL_LINK_SPEED_MODE);
+		     cpmuctrl & ~(CPMU_CTRL_LINK_SPEED_MODE |
+				  CPMU_CTRL_LINK_AWARE_MODE));
 	}
 
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
-	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */


