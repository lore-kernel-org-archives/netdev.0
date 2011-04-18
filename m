From: David Miller <davem@davemloft.net>
Subject: [PATCH 24/42] isdn: l3dss1: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:45 -0700 (PDT)
Message-ID: <20110417.173345.200364904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754020Ab1DRAeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 68BE824C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'cause' is set but unused in dss1up().  Just
kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/l3dss1.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
index 8e2fd02..b0d9ab1 100644
--- a/drivers/isdn/hisax/l3dss1.c
+++ b/drivers/isdn/hisax/l3dss1.c
@@ -2943,7 +2943,7 @@ global_handler(struct PStack *st, int mt, struct sk_buff *skb)
 static void
 dss1up(struct PStack *st, int pr, void *arg)
 {
-	int i, mt, cr, cause, callState;
+	int i, mt, cr, callState;
 	char *ptr;
 	u_char *p;
 	struct sk_buff *skb = arg;
@@ -3034,12 +3034,10 @@ dss1up(struct PStack *st, int pr, void *arg)
 				return;
 			}
 		} else if (mt == MT_STATUS) {
-			cause = 0;
 			if ((ptr = findie(skb->data, skb->len, IE_CAUSE, 0)) != NULL) {
 				ptr++;
 				if (*ptr++ == 2)
 					ptr++;
-				cause = *ptr & 0x7f;
 			}
 			callState = 0;
 			if ((ptr = findie(skb->data, skb->len, IE_CALL_STATE, 0)) != NULL) {
-- 
1.7.4.3

