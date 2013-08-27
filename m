From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/5] bnx2x: vf mark stats started
Date: Wed, 28 Aug 2013 01:13:00 +0300
Message-ID: <1377641584-2939-2-git-send-email-yuvalmin@broadcom.com>
References: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3463 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab3H0WNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:13:24 -0400
In-Reply-To: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Solve issue where no stats were being collected for VF devices due to missing
configuration in the stats' atomic synchronization mechanism.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index d63d132..fed9b15 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -522,20 +522,16 @@ static void bnx2x_func_stats_init(struct bnx2x *bp)
 /* should be called under stats_sema */
 static void __bnx2x_stats_start(struct bnx2x *bp)
 {
-	/* vfs travel through here as part of the statistics FSM, but no action
-	 * is required
-	 */
-	if (IS_VF(bp))
-		return;
-
-	if (bp->port.pmf)
-		bnx2x_port_stats_init(bp);
+	if (IS_PF(bp)) {
+		if (bp->port.pmf)
+			bnx2x_port_stats_init(bp);
 
-	else if (bp->func_stx)
-		bnx2x_func_stats_init(bp);
+		else if (bp->func_stx)
+			bnx2x_func_stats_init(bp);
 
-	bnx2x_hw_stats_post(bp);
-	bnx2x_storm_stats_post(bp);
+		bnx2x_hw_stats_post(bp);
+		bnx2x_storm_stats_post(bp);
+	}
 
 	bp->stats_started = true;
 }
-- 
1.8.1.227.g44fe835
