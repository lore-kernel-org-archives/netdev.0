From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: skbuff: Fix checksum start check in skb_postpull_rcsum
Date: Thu, 1 Oct 2015 19:34:07 +0800
Message-ID: <20151001113407.GA26772@gondor.apana.org.au>
References: <20151001084222.GA25104@gondor.apana.org.au>
 <1443698177.3401.1.camel@gmail.com>
 <20151001112134.GA26657@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40869 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbbJALeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 07:34:13 -0400
Content-Disposition: inline
In-Reply-To: <20151001112134.GA26657@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In skb_postpull_rcsum the skb has already been pulled so we should
be testing whether the checksum start offset is non-negative rather
than how it compares to the length that we have pulled.

Fixes: 6ae459bdaaee ("skbuff: Fix skb checksum flag on skb pull")
Reported-by: Mike Galbraith <umgwanakikbuti@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2b0a30a..4398411 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2708,7 +2708,7 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		 skb_checksum_start_offset(skb) <= len)
+		 skb_checksum_start_offset(skb) < 0)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
