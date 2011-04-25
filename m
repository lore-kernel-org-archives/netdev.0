From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Organize loopback test failure flags
Date: Mon, 25 Apr 2011 15:42:46 -0700
Message-ID: <1303771370-32579-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4284 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756806Ab1DYWao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As more test modes are added to each loopback mode, the need to
organise the results increases.  This patch groups the results by
loopback mode, and then by test mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a72d031..88cd231 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11276,10 +11276,12 @@ out:
 	return err;
 }
 
-#define TG3_MAC_LOOPBACK_FAILED		1
-#define TG3_PHY_LOOPBACK_FAILED		2
-#define TG3_LOOPBACK_FAILED		(TG3_MAC_LOOPBACK_FAILED |	\
-					 TG3_PHY_LOOPBACK_FAILED)
+#define TG3_STD_LOOPBACK_FAILED		1
+#define TG3_JMB_LOOPBACK_FAILED		2
+
+#define TG3_MAC_LOOPBACK_SHIFT		0
+#define TG3_PHY_LOOPBACK_SHIFT		4
+#define TG3_LOOPBACK_FAILED			0x00000033
 
 static int tg3_test_loopback(struct tg3 *tp)
 {
@@ -11338,11 +11340,11 @@ static int tg3_test_loopback(struct tg3 *tp)
 	}
 
 	if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
-		err |= TG3_MAC_LOOPBACK_FAILED;
+		err |= TG3_STD_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
 	if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
 	    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
-		err |= (TG3_MAC_LOOPBACK_FAILED << 2);
+		err |= TG3_JMB_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
 	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
@@ -11354,10 +11356,12 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
-			err |= TG3_PHY_LOOPBACK_FAILED;
+			err |= TG3_STD_LOOPBACK_FAILED <<
+			       TG3_PHY_LOOPBACK_SHIFT;
 		if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
 		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
-			err |= (TG3_PHY_LOOPBACK_FAILED << 2);
+			err |= TG3_JMB_LOOPBACK_FAILED <<
+			       TG3_PHY_LOOPBACK_SHIFT;
 	}
 
 	/* Re-enable gphy autopowerdown. */
-- 
1.7.3.4


