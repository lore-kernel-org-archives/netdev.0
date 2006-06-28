From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Wed, 28 Jun 2006 13:10:52 +1000
Message-ID: <20060628031052.GA4570@gondor.apana.org.au>
References: <1151464007.5124.13.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7946 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1423006AbWF1DLG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:11:06 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151464007.5124.13.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 08:06:47PM -0700, Michael Chan wrote:
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 2d8d6ad..2c75172 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1033,7 +1033,8 @@ static inline void sk_setup_caps(struct 
>  	if (sk->sk_route_caps & NETIF_F_GSO)
>  		sk->sk_route_caps |= NETIF_F_TSO;
>  	if (sk->sk_route_caps & NETIF_F_TSO) {
> -		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
> +		if ((sock_flag(sk, SOCK_NO_LARGESEND) &&
> +		    !tso_ecn_capable(sk->sk_route_caps)) || dst->header_len)
>  			sk->sk_route_caps &= ~NETIF_F_TSO;

Why turn it off? With GSO in place the stack will handle it just fine
(even your description says so :)  We should instead remove all code
that turns off TSO/ECN when the other is present.

Otherwise the patch looks good.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
