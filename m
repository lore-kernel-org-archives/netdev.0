From: akpm@osdl.org
Subject: [patch 14/17] irda: missing allocation result check in irlap_change_speed()
Date: Thu, 01 Jun 2006 20:32:34 -0700
Message-ID: <200606020328.k523SFGT028844@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, fmalita@gmail.com,
	samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10421 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751210AbWFBD2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:36 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Florin Malita <fmalita@gmail.com>

The skb allocation may fail, which can result in a NULL pointer dereference
in irlap_queue_xmit().

Coverity CID: 434.

davem: "If the allocation fails we should probably do something more
interesting here, such as schedule a timer to try again later.  Otherwise the
speed change will silently never occur."

Signed-off-by: Florin Malita <fmalita@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/irda/irlap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/irda/irlap.c~irda-missing-allocation-result-check-in-irlap_change_speed net/irda/irlap.c
--- devel/net/irda/irlap.c~irda-missing-allocation-result-check-in-irlap_change_speed	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/irda/irlap.c	2006-06-01 20:31:50.000000000 -0700
@@ -884,7 +884,8 @@ static void irlap_change_speed(struct ir
 	if (now) {
 		/* Send down empty frame to trigger speed change */
 		skb = dev_alloc_skb(0);
-		irlap_queue_xmit(self, skb);
+		if (skb)
+			irlap_queue_xmit(self, skb);
 	}
 }
 
_
