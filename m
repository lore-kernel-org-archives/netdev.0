From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 27/36] bnx2x: Missing smp_wmb for statistics state
 machine
Date: Wed, 12 Aug 2009 21:23:56 +0300
Message-ID: <1250101436.27379.179.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528AbZHLSZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 656ee97..bcf8362 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4411,6 +4411,9 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	bnx2x_stats_stm[state][event].action(bp);
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 
+	/* Make sure the state has been "changed" */
+	smp_wmb();
+
 	if ((event != STATS_EVENT_UPDATE) || (bp->msglevel & NETIF_MSG_TIMER))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
 		   state, event, bp->stats_state);
-- 
1.5.4.3




