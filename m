From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Fix OOM crash in deliver_clone
Date: Wed, 16 Jun 2010 14:02:19 +1000
Message-ID: <20100616040219.GA18000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Wagner <mwagner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33448 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750812Ab0FPECo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 00:02:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

bridge: Fix OOM crash in deliver_clone

The bridge multicast patches introduced an OOM crash in the forward
path, when deliver_clone fails to clone the skb.

This patch fixes it.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6e97711..cbfe87f 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -130,10 +130,10 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb))
 {
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (!skb) {
-		struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
-
 		dev->stats.tx_dropped++;
 		return -ENOMEM;
 	}

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
