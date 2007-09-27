From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 21:20:37 +0800
Message-ID: <20070927132037.GA17056@gondor.apana.org.au>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <20070927124515.GA16706@gondor.apana.org.au> <20070927131008.GA15997@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1870 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752911AbXI0NUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 09:20:50 -0400
Content-Disposition: inline
In-Reply-To: <20070927131008.GA15997@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 05:10:08PM +0400, Evgeniy Polyakov wrote:
>
> +static inline void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
> +			    __be32 from, __be32 to, int pseudohdr)
> +{
> +	__be32 diff[] = { ~from, to };
> +	if (skb->ip_summed != CHECKSUM_PARTIAL) {
> +		*sum = csum_fold(csum_partial(diff, sizeof(diff),
> +				~csum_unfold(*sum)));
> +		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
> +			skb->csum = ~csum_partial(diff, sizeof(diff),
> +						~skb->csum);
> +	} else if (pseudohdr)
> +		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
> +				csum_unfold(*sum)));
> +}

The embedded people are going to hate you for this :)

How about putting it in net/core/utils.c?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
