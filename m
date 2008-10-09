From: David Miller <davem@davemloft.net>
Subject: [PATCH]: ppp: Use skb_queue_walk() in ppp_mp_insert().
Date: Thu, 09 Oct 2008 16:40:54 -0700 (PDT)
Message-ID: <20081009.164054.145614629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751338AbYJIXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 19:41:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 12156C8C192
	for <netdev@vger.kernel.org>; Thu,  9 Oct 2008 16:40:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ppp: Use skb_queue_walk() in ppp_mp_insert().

Instead of open-coded version.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 5d4d215..0ca0fcb 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1863,9 +1863,10 @@ ppp_mp_insert(struct ppp *ppp, struct sk_buff *skb)
 
 	/* N.B. we don't need to lock the list lock because we have the
 	   ppp unit receive-side lock. */
-	for (p = list->next; p != (struct sk_buff *)list; p = p->next)
+	skb_queue_walk(list, p) {
 		if (seq_before(seq, p->sequence))
 			break;
+	}
 	__skb_queue_before(list, p, skb);
 }
 
-- 
1.5.6.5

