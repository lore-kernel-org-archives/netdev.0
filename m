From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-2.6.24] [L2TP] Fix lockup introduced by recent changes
Date: Tue, 18 Sep 2007 22:44:33 +0100
Message-ID: <200709182144.l8ILiXrx008249@quickie.katalix.com>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	mostrows@speakeasy.net, paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:47398 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757098AbXIRVon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 17:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[L2TP] Fix double skb free problem introduced by recent changes 

This patch is to be applied on top of Herbert's recent patch set:
"[PPP 3/3] L2TP: Fix skb handling in pppol2tp_xmit"

It fixes a double kfree_skb() issue introduced by that patch. Also
return 0 on error, allowing PPP to requeue the skb.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: net-2.6.24/drivers/net/pppol2tp.c
===================================================================
--- net-2.6.24.orig/drivers/net/pppol2tp.c
+++ net-2.6.24/drivers/net/pppol2tp.c
@@ -1066,11 +1066,10 @@ static int pppol2tp_xmit(struct ppp_chan
 		session->stats.tx_errors++;
 	}
 
-	/* Free the original skb */
-abort:
-	kfree_skb(skb);
-
 	return 1;
+
+abort:
+	return 0;
 }
 
 /*****************************************************************************
