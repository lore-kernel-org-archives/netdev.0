From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Fri, 30 Nov 2007 20:59:48 +1100
Message-ID: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au>
References: <474C2DFB.1090706@myri.com>
Cc: davem@davemloft.net, ossthema@de.ibm.com, netdev@vger.kernel.org
To: gallatin@myri.com (Andrew Gallatin)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2733 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756325AbXK3J77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 04:59:59 -0500
In-Reply-To: <474C2DFB.1090706@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Gallatin <gallatin@myri.com> wrote:
>
> diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
> index ac3b1d3..91e9371 100644
> --- a/net/ipv4/inet_lro.c
> +++ b/net/ipv4/inet_lro.c
> @@ -401,10 +401,11 @@ static struct sk_buff *lro_gen_skb(struc
>        int data_len = len;
>        int hdr_len = min(len, hlen);
> 
> -       skb = netdev_alloc_skb(lro_mgr->dev, hlen);
> +       skb = netdev_alloc_skb(lro_mgr->dev, hlen + NET_IP_ALIGN);

NET_IP_ALIGN should only be used if you're DMAing into the skb head.
Otherwise you should say 2.  It would be nice to have another macro
for that I suppose.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
