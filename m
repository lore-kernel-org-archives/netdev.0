From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 26/41]bnx2x: Increasing FW timeout
Date: Thu, 12 Feb 2009 20:37:23 +0200
Message-ID: <1234463843.1863.158.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758583AbZBLShv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 26/41]bnx2x: Increasing FW timeout
When enabling many debug prints, it can take a while before processing an event.
To ease the debug process, allow bigger timeout before giving up

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6c04539..6bd9219 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6671,7 +6671,7 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 			     int *state_p, int poll)
 {
 	/* can take a while if any port is running */
-	int cnt = 500;
+	int cnt = 5000;
 
 	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
 	   poll ? "polling" : "waiting", state, idx);
@@ -6689,8 +6689,12 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 		}
 
 		mb(); /* state is changed by bnx2x_sp_event() */
-		if (*state_p == state)
+		if (*state_p == state) {
+#ifdef BNX2X_STOP_ON_ERROR
+			DP(NETIF_MSG_IFUP, "exit  (cnt %d)\n", 5000 - cnt);
+#endif
 			return 0;
+		}
 
 		msleep(1);
 	}
-- 
1.5.4.3




