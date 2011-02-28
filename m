From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 5/7] bnx2x: perform statistics "action" before
 state transition.
Date: Mon, 28 Feb 2011 15:37:10 +0200
Message-ID: <1298900230.28024.117.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1936 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727Ab1B1Ni4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:38:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index bda60d5..3445ded 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -1239,14 +1239,14 @@ void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	if (unlikely(bp->panic))
 		return;
 
+	bnx2x_stats_stm[bp->stats_state][event].action(bp);
+
 	/* Protect a state change flow */
 	spin_lock_bh(&bp->stats_lock);
 	state = bp->stats_state;
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 	spin_unlock_bh(&bp->stats_lock);
 
-	bnx2x_stats_stm[state][event].action(bp);
-
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
 		   state, event, bp->stats_state);
-- 
1.7.2.2




