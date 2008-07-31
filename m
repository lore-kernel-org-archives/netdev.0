From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 10:29:24 +0800
Message-ID: <E1KONuu-00017h-00@gondolin.me.apana.org.au>
References: <20080731004123.GB22826@xi.wantstofly.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, akarkare@marvell.com,
	nico@cam.org
To: buytenh@wantstofly.org (Lennert Buytenhek)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57438 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753377AbYGaC3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 22:29:36 -0400
In-Reply-To: <20080731004123.GB22826@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote:
>
> Index: linux-2.6.27-rc1/net/ipv4/tcp_output.c
> ===================================================================
> --- linux-2.6.27-rc1.orig/net/ipv4/tcp_output.c
> +++ linux-2.6.27-rc1/net/ipv4/tcp_output.c
> @@ -1544,7 +1544,7 @@ static int tcp_write_xmit(struct sock *s
>                        break;
> 
>                if (tso_segs == 1) {
> -                       if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
> +                       if (unlikely(!tcp_nagle_test(tp, skb, 5 * mss_now,
>                                                     (tcp_skb_is_last(sk, skb) ?
>                                                      nonagle : TCP_NAGLE_PUSH))))
>                                break;

What's the size of your application's write calls?

But yeah we should at least offer something like this patch (with
5 * mss_now replaced by the TSO aggregation limit) as an option in
addition to nalge itself for those apps that do small writes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
