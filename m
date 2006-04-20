From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb->truesize assertion checking for TCP
Date: Thu, 20 Apr 2006 15:04:06 +1000
Message-ID: <20060420050406.GA22105@gondor.apana.org.au>
References: <20060419.215513.13034269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54029 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750887AbWDTFEJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 01:04:09 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060419.215513.13034269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David:

On Wed, Apr 19, 2006 at 09:55:13PM -0700, David S. Miller wrote:
> 
> Herbert what do you think of this?
> 
> I know it might be better to check this right where we
> make the manipulations, but this catch-all trap at the
> end points seems to make sense and will catch other kinds
> of errors.

Yes that should do the trick.

> +static inline void skb_truesize_check(struct sk_buff *skb)
> +{
> +	if (unlikely((int)skb->truesize < sizeof(struct sk_buff)))
> +		skb_truesize_bug(skb);
> +}

I think we can go for the stronger test:

skb->truesize < sizeof(struct sk_buff) + skb->len

> +void skb_truesize_bug(struct sk_buff *skb)
> +{
> +	printk("SKB BUG: Invalid truesize (%u) sizeof(sk_buff)=%Zd\n",
> +	       skb->truesize, sizeof(struct sk_buff));
> +}

Printing out skb->len would be good too if we changed the test.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
