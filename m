From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 09:33:57 +0200
Message-ID: <1271921637.7895.4791.camel@edumazet-laptop>
References: <1271920233.7895.4723.camel@edumazet-laptop>
	 <20100422.001625.200862474.davem@davemloft.net>
	 <1271921045.7895.4763.camel@edumazet-laptop>
	 <20100422.002623.00784210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50314 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab0DVHeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:34:07 -0400
Received: by mail-bw0-f225.google.com with SMTP id 25so9184722bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:34:06 -0700 (PDT)
In-Reply-To: <20100422.002623.00784210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 00:26 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 Apr 2010 09:24:05 +0200
>=20
> > Hmm... are you sure we want to call destructor for each skb ?
> >=20
> > Should'nt we do it before initial skb is split ?
>=20
> Good idea, therefore you mean something like this?
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3ba774b..f3c3885 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1865,6 +1865,7 @@ static int dev_gso_segment(struct sk_buff *skb)
>  	int features =3D dev->features & ~(illegal_highdma(dev, skb) ?
>  					 NETIF_F_SG : 0);
> =20
> +	skb_orphan_try(skb);
>  	segs =3D skb_gso_segment(skb, features);
> =20
>  	/* Verifying header integrity only. */

Yes, it seems better.

What about the=20

if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
	skb_dst_drop(skb);

This thing might also be moved before the split, since split probably
clone all dst ?


