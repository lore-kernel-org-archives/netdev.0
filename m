From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Wed, 28 Jun 2006 14:42:09 +1000
Message-ID: <20060628044209.GA5673@gondor.apana.org.au>
References: <1151464007.5124.13.camel@rh4> <20060628031052.GA4570@gondor.apana.org.au> <1151466034.5124.18.camel@rh4> <20060628034823.GA5125@gondor.apana.org.au> <1151469421.3502.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12811 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1423073AbWF1EmU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:42:20 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151469421.3502.3.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 09:37:01PM -0700, Michael Chan wrote:
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good to me too!

> @@ -56,6 +55,9 @@ static inline void TCP_ECN_send(struct s
>  			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
>  				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
>  				skb->h.th->cwr = 1;
> +				if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> +					skb_shinfo(skb)->gso_type |=
> +						SKB_GSO_TCPV4_ECN;

As a byte-pincher I must suggest that you turn this check into something
like 

				if (skb_shinfo(skb)->gso_type)

or even

				if (skb_shinfo(skb)->gso_size)

:)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
