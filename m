From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Wed, 11 Sep 2013 00:50:23 +0200
Message-ID: <20130910225023.GB4794@order.stressinduktion.org>
References: <522D7444.20505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49475 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab3IJWuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 18:50:24 -0400
Content-Disposition: inline
In-Reply-To: <522D7444.20505@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 03:09:56PM +0800, Duan Jiong wrote:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 5c71501..61fe8e5 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  
>  	np = inet6_sk(sk);
>  
> -	if (type == NDISC_REDIRECT) {
> -		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
> -
> -		if (dst)
> -			dst->ops->redirect(dst, sk, skb);
> -		goto out;
> -	}
> -

You dropped the "goto out" here in case of an NDISC_REDIRECT, so this sends an
EPROTO further up the socket layer. Was this intended?

Also:

In some _err() functions there is this check, e.g. ah6.c:

    621         if (type != ICMPV6_DEST_UNREACH &&
    622             type != ICMPV6_PKT_TOOBIG &&
    623             type != NDISC_REDIRECT)
    624                 return;

It could actually be adjusted now as we don't handle NDISC_REDIRECTs here any
more. I don't see any side-effects down the code in these functions. We could
also only just match on ICMPV6_PKT_TOOBIG. Can you confirm?

Greetings,

  Hannes
