From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 2/4] bnx2x: fix link notification
Date: Sun, 6 Mar 2011 22:49:15 +0200
Message-ID: <1299444555.13442.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2224 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab1CFU6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 15:58:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Report link to OS and other PFs after HW is fully reconfigured
according to new link parameters. (Affected only Multi Function modes).

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 469ca60..aa03233 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2163,13 +2163,6 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 	}
 
-	/* indicate link status only if link status actually changed */
-	if (prev_link_status != bp->link_vars.link_status)
-		bnx2x_link_report(bp);
-
-	if (IS_MF(bp))
-		bnx2x_link_sync_notify(bp);
-
 	if (bp->link_vars.link_up && bp->link_vars.line_speed) {
 		int cmng_fns = bnx2x_get_cmng_fns_mode(bp);
 
@@ -2181,6 +2174,13 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			DP(NETIF_MSG_IFUP,
 			   "single function mode without fairness\n");
 	}
+
+	if (IS_MF(bp))
+		bnx2x_link_sync_notify(bp);
+
+	/* indicate link status only if link status actually changed */
+	if (prev_link_status != bp->link_vars.link_status)
+		bnx2x_link_report(bp);
 }
 
 void bnx2x__link_status_update(struct bnx2x *bp)
-- 
1.7.2.2




