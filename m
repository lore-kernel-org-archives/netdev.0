From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Mon, 19 Jan 2009 09:50:40 +1100
Message-ID: <20090118225040.GA30418@gondor.apana.org.au>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com> <20090117050839.GA24215@gondor.apana.org.au> <4971BCDE.50600@chelsio.com> <20090117130827.GA17896@gondor.apana.org.au> <49739226.3020104@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40914 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753089AbZARWut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 17:50:49 -0500
Content-Disposition: inline
In-Reply-To: <49739226.3020104@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 12:33:42PM -0800, Divy Le Ray wrote:
> 
> Thanks for the patch. It does improve the performance.
> I'm now getting about 5.3Gbs.

Thanks for testing Divy!

> Here is a oprofile output:
>       33.929900  copy_user_generic_unrolled          vmlinux
>        7.150300  process_responses                  cxgb3.ko
>        6.261100  refill_fl                          cxgb3.ko
>        6.181700  memcpy                              vmlinux

I wonder why this is still up there.

Maybe this patch will help?

diff --git a/net/core/dev.c b/net/core/dev.c
index 3742397..3cc19fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2554,7 +2554,8 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 
 	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
 	skb_shinfo(skb)->nr_frags = info->nr_frags;
-	memcpy(skb_shinfo(skb)->frags, info->frags, sizeof(info->frags));
+	memcpy(skb_shinfo(skb)->frags, info->frags,
+	       info->nr_frags * sizeof(*info->frags));
 
 	skb->data_len = info->len;
 	skb->len += info->len;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
