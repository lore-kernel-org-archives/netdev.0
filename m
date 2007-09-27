From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 15:16:48 +0200
Message-ID: <46FBAD40.8040806@trash.net>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <20070927124515.GA16706@gondor.apana.org.au> <20070927131008.GA15997@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbXI0NRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 09:17:12 -0400
In-Reply-To: <20070927131008.GA15997@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> +static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
> +{
> +	__be32 diff[] = { ~from, to };
> +
> +	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
> +}
> +
> +static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
> +{
> +	nf_csum_replace4(sum, (__force __be32)from, (__force __be32)to);
> +}
> +
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
> +
> +static inline void nf_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
> +				      __be16 from, __be16 to, int pseudohdr)
> +{
> +	nf_proto_csum_replace4(sum, skb, (__force __be32)from,
> +				(__force __be32)to, pseudohdr);
> +}


These are way too large to get inlined, please move somewhere below
net/core.
