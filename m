From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 10/11] bnx2x: Don't report link down if has
 been already down
Date: Mon, 19 Apr 2010 14:15:08 +0300
Message-ID: <1271675708.6900.284.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>, yanivr@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2214 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589Ab0DSLPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Author: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ab9a9eb..c4aac38 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2469,6 +2469,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
+	u32 prev_link_status = bp->link_vars.link_status;
 	/* Make sure that we are synced with the current statistics */
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
@@ -2501,8 +2502,9 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 	}
 
-	/* indicate link status */
-	bnx2x_link_report(bp);
+	/* indicate link status only if link status actually changed */
+	if (prev_link_status != bp->link_vars.link_status)
+		bnx2x_link_report(bp);
 
 	if (IS_E1HMF(bp)) {
 		int port = BP_PORT(bp);
-- 
1.6.3.3




