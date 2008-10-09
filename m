From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] gre: Add Transparent Ethernet Bridging
Date: Thu, 9 Oct 2008 18:39:56 +0800
Message-ID: <20081009103956.GA18751@gondor.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au> <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au> <48EDC429.5090502@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41547 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753932AbYJIKkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 06:40:03 -0400
Content-Disposition: inline
In-Reply-To: <48EDC429.5090502@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 06:43:21PM +1000, Philip Craig wrote:
>
> Herbert Xu wrote:
> > @@ -530,7 +572,13 @@ static int ipgre_rcv(struct sk_buff *skb)
> >  		dst_release(skb->dst);
> >  		skb->dst = NULL;
> >  		nf_reset(skb);
> > +
> > +		if (tunnel->dev->type == ARPHRD_ETHER)
> > +			skb->protocol = eth_type_trans(skb, skb->dev);
> 
> Do you need to check pskb_may_pull(skb, ETH_HLEN)?

Good point, I'll fix this up.

> +/*
> + * We've finished passing through netfilter, so we can remove the fake dst.
> + * This is required by some lower layers, eg ip_gre
> + */
> +static int br_nf_dev_queue_xmit_finish(struct sk_buff *skb)
> +{
> +	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
> +		dst_release(skb->dst);
> +		skb->dst = NULL;
> +	}
> +
> +	return br_dev_queue_push_xmit(skb);
> +}

Alternatively we could give fake_rtable an ops structure.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
