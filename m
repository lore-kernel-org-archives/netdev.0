From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/3] gro: Fix error handling on extremely short frags
Date: Sun, 18 Jan 2009 16:47:18 +1100
Message-ID: <20090118054718.GA24943@gondor.apana.org.au>
References: <20090118054616.GA24899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56413 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752257AbZARFrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 00:47:20 -0500
Content-Disposition: inline
In-Reply-To: <20090118054616.GA24899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second is a trivial error handling bug.

gro: Fix error handling on extremely short frags

When a frag is shorter than an Ethernet header, we'd return a
zeroed packet instead of aborting.  This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 4f69a2d..2fb3a00 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2514,6 +2514,7 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 
 	if (!pskb_may_pull(skb, ETH_HLEN)) {
 		napi_reuse_skb(napi, skb);
+		skb = NULL;
 		goto out;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
