From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of locked section
Date: Wed, 7 Nov 2007 17:17:42 +0100
Message-ID: <200711071717.43429.netdev@axxeo.de>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:2959 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925AbXKGQSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:18:20 -0500
In-Reply-To: <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu schrieb:
> diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
> index a7bc8c6..4a01cb3 100644
> --- a/net/ipv6/xfrm6_mode_ro.c
> +++ b/net/ipv6/xfrm6_mode_ro.c
> @@ -53,7 +54,9 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
>  	__skb_pull(skb, hdr_len);
>  	memmove(ipv6_hdr(skb), iph, hdr_len);
>  
> +	spin_lock_bh(&x->lock);
>  	x->lastused = get_seconds();
> +	spin_unlock_bh(&x->lock);
>  
>  	return 0;
>  }

Can you move the retrieval of the seconds outside the spinlock?

e.g.

tmp = get_seconds();
spin_lock_bh(&x->lock);
x->lastused = tmp;
spin_unlock_bh(&x->lock);

or is it not really worth it?

Best Regards

Ingo Oeser
