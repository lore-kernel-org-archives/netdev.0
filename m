From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 29 Jan 2009 08:25:26 +1100
Message-ID: <20090128212526.GA22141@gondor.apana.org.au>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu> <20090125.213222.192571170.davem@davemloft.net> <20090126223022.GA24046@gondor.apana.org.au> <497EA5B5.5090806@cs.wisc.edu> <46A00B48CC54E4468EF6911F877AC4CA01EF2BC9@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michaelc@cs.wisc.edu, davem@davemloft.net,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	olaf.kirch@oracle.com, tgraf@suug.ch, kkeil@suse.de
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45058 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751051AbZA1VZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 16:25:42 -0500
Content-Disposition: inline
In-Reply-To: <46A00B48CC54E4468EF6911F877AC4CA01EF2BC9@blrx3m10.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 05:47:57PM +0530, Shyam_Iyer@Dell.com wrote:
> 
> --- skbuff.c.orig	2009-01-29 01:12:03.000000000 +0530
> +++ skbuff.c	2009-01-29 01:34:57.000000000 +0530
> @@ -2039,15 +2039,15 @@
>  		st->frag_data = NULL;
>  	}
>  
> -	if (st->cur_skb->next) {
> -		st->cur_skb = st->cur_skb->next;
> -		st->frag_idx = 0;
> -		goto next_skb;
> -	} else if (st->root_skb == st->cur_skb &&
> +	if (st->root_skb == st->cur_skb &&
>  		   skb_shinfo(st->root_skb)->frag_list) {
>  		st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
>  		st->frag_idx=0;
>  		goto next_skb;
> +	} else if (st->cur_skb->next) {
> +		st->cur_skb = st->cur_skb->next;
> +		st->frag_idx = 0;
> +		goto next_skb;
>  	}
>  
>  	return 0;

Good catch!

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
