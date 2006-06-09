From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/3] [NET] ppp: Remove unnecessary pskb_may_pull
Date: Fri, 9 Jun 2006 17:43:44 +1000
Message-ID: <20060609074344.GA19524@gondor.apana.org.au>
References: <20060609074234.GA17580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36369 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751422AbWFIHnr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:43:47 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060609074234.GA17580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET] ppp: Remove unnecessary pskb_may_pull

In ppp_receive_nonmp_frame, we call pskb_may_pull(skb, skb->len) if the
tailroom is >= 124.  This is pointless because this pskb_may_pull is only
needed if the skb is non-linear.  However, if it is non-linear then the
tailroom would be zero.

So it can be safely removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.patch"

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1609,8 +1609,6 @@ ppp_receive_nonmp_frame(struct ppp *ppp,
 			kfree_skb(skb);
 			skb = ns;
 		}
-		else if (!pskb_may_pull(skb, skb->len))
-			goto err;
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 

--ibTvN161/egqYuK8--
