From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 2/14] rhashtable: Introduce max_size/min_size
Date: Mon, 16 Mar 2015 07:21:19 +1100
Message-ID: <20150315202119.GA25353@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61y-0005mR-MK@gondolin.me.apana.org.au>
 <5505A142.6020606@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38019 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbCOUVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 16:21:34 -0400
Content-Disposition: inline
In-Reply-To: <5505A142.6020606@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 06:12:02PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 3/15/2015 1:44 PM, Herbert Xu wrote:
> 
> >This patch adds the parameters max_size and min_size which are
> >meant to replace max_shift and min_shift.
> 
> >Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> [...]
> >diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> >index 4a99c0c..5101e18 100644
> >--- a/lib/rhashtable.c
> >+++ b/lib/rhashtable.c
> [...]
> >@@ -872,7 +874,8 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
> >  static size_t rounded_hashtable_size(struct rhashtable_params *params)
> >  {
> >  	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
> >-		   1UL << params->min_shift);
> >+		   max(1UL << params->min_shift,
> 
>    max_t(), perhaps?

max works just fine.  Besides, this max goes away a few patches
down.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
