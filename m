From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [DECNET]: Fix inverted wait flag in xfrm_lookup call
Date: Thu, 13 Dec 2007 13:25:16 +0800
Message-ID: <20071213052516.GA2134@gondor.apana.org.au>
References: <E1J2GrH-0005SK-00@gondolin.me.apana.org.au> <20071212.104342.206132994.davem@davemloft.net> <20071213014623.GB32308@gondor.apana.org.au> <20071212.184919.157572948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750743AbXLMFZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 00:25:19 -0500
Content-Disposition: inline
In-Reply-To: <20071212.184919.157572948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 06:49:19PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 13 Dec 2007 09:46:23 +0800
> 
> > [IPSEC]: Make callers of xfrm_lookup to use XFRM_LOOKUP_WAIT

Sorry, I was too quick too :) I managed to invert the DECNet
xfrm_lookup call.  Here's a fix.

[DECNET]: Fix inverted wait flag in xfrm_lookup call

My previous patch made the wait flag take the opposite value to what it
should be.  This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 62f3ae7..2d95cf1 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1197,7 +1197,7 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
 	if (err == 0 && fl->proto) {
 		err = xfrm_lookup(pprt, fl, sk, (flags & MSG_DONTWAIT) ?
-						XFRM_LOOKUP_WAIT : 0);
+						0 : XFRM_LOOKUP_WAIT);
 	}
 	return err;
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
