From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP encapsulation  mode
Date: Thu, 18 Dec 2008 14:47:26 +1100
Message-ID: <E1LD9rC-0007y7-KY@gondolin.me.apana.org.au>
References: <1228396731.1643.57.camel@martin>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: martin@strongswan.org (Martin Willi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60778 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751970AbYLRDrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:47:32 -0500
In-Reply-To: <1228396731.1643.57.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Willi <martin@strongswan.org> wrote:
> An IPsec node speaking IKEv2 MUST accept incoming UDP encapsulated
> ESP packets, even if no NAT situation is detected. This is important
> if MOBIKE is in use. Some implementation keep the encapsulation
> mode if they move out of a NAT situation.
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index b4a1317..65bcf09 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -167,11 +167,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>                        goto drop_unlock;
>                }
> 
> -               if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
> -                       XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
> -                       goto drop_unlock;
> -               }

This can't work as ESP relies on this check.  Now that it's gone
ESP may touch a UDP header which doesn't exist.

What exactly are you trying to achieve?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
