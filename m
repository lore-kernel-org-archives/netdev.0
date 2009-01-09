From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipcomp: Remove spurious truesize increase
Date: Fri, 9 Jan 2009 18:27:06 +1100
Message-ID: <20090109072706.GA7599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbZAIH1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 02:27:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

ipcomp: Remove spurious truesize increase

When I made ipcomp use frags, I forgot to take out the original
truesize update that was added for pskb_expand_head.  As we no
longer expand the head of skb, that update should have been removed.

This bug is not related to the truesize warnings since we only
made it bigger than what it should've been.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index c609a4b..42cd183 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -63,7 +63,6 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	if (len > skb_tailroom(skb))
 		len = skb_tailroom(skb);
 
-	skb->truesize += len;
 	__skb_put(skb, len);
 
 	len += plen;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
