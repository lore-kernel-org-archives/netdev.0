From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] wan/hdlc_x25.c: fix a NULL dereference
Date: Fri, 29 Aug 2008 17:08:30 +1000
Message-ID: <E1KYy5u-000243-00@gondolin.me.apana.org.au>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi>
Cc: khc@pm.waw.pl, jgarzik@redhat.com, netdev@vger.kernel.org
To: bunk@kernel.org (Adrian Bunk)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48960 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751646AbYH2HIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 03:08:47 -0400
In-Reply-To: <20080827220549.GS11734@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk <bunk@kernel.org> wrote:
>
> static int x25_rx(struct sk_buff *skb)
> {
> -       if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
> -               skb->dev->stats.rx_dropped++;
> +       if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
>                return NET_RX_DROP;
> -       }

Why not keep the stat collection? It's not like saving skb->dev
on the stack is hard or anything...

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
