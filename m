From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: skbuff: Copy csum instead of csum_start/csum_offset
Date: Sat, 23 May 2009 18:20:02 +1000
Message-ID: <20090523082002.GA14135@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60600 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751509AbZEWIUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 04:20:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

skbuff: Copy csum instead of csum_start/csum_offset

It's easier to copy the u32 csum instead of its two u16
constituents.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cb58b4b..d429c41 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -526,8 +526,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->sp			= secpath_get(old->sp);
 #endif
 	memcpy(new->cb, old->cb, sizeof(old->cb));
-	new->csum_start		= old->csum_start;
-	new->csum_offset	= old->csum_offset;
+	new->csum		= old->csum;
 	new->local_df		= old->local_df;
 	new->pkt_type		= old->pkt_type;
 	new->ip_summed		= old->ip_summed;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
