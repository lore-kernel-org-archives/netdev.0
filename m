From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ax25: Use skb_orphan before touching skb destructor
Date: Mon, 22 Jun 2009 16:52:04 +0800
Message-ID: <20090622085204.GA22333@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42825 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755927AbZFVIwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 04:52:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This is the first in a series of patches (yet to be written :)
to allow the removal of the skb_orphan call that I recently
added to netif_receive_skb.

ax25: Use skb_orphan before touching skb destructor

Before taking ownership of skb->destructor, we should ensure
that the existing destructor is called through skb_orphan.

In future this should be moved further down to where we actually
call skb_set_owner_*.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 5f1d210..de56d39 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -437,8 +437,7 @@ free:
 int ax25_kiss_rcv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
-	skb->sk = NULL;		/* Initially we don't know who it's for */
-	skb->destructor = NULL;	/* Who initializes this, dammit?! */
+	skb_orphan(skb);
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
