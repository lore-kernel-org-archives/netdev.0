From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Relax 5717 serdes restriction
Date: Sun, 11 Jul 2010 12:31:43 -0700
Message-ID: <1278876707-21390-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1309 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754612Ab0GKTb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3 is coded to refuse to attach to 5717 serdes devices.  Now that the
hardware is better supported, we can relax this restriction.  This patch
also fixes a recently introduced bug which will cause serdes parallel
detection not to work with 5780 class devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index efac448..c91049b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8551,7 +8551,7 @@ static void tg3_timer(unsigned long __opaque)
 				tg3_setup_phy(tp, 0);
 			}
 		} else if ((tp->tg3_flags2 & TG3_FLG2_MII_SERDES) &&
-			   !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+			   (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 			tg3_serdes_parallel_detect(tp);
 		}
 
@@ -13427,8 +13427,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		return err;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
-	    (tp->pci_chip_rev_id != CHIPREV_ID_5717_A0 ||
-		 (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
+	    tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
 		return -ENOTSUPP;
 
 	/* Initialize data/descriptor byte/word swapping. */
-- 
1.6.4.4


