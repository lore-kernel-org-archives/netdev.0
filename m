From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: release dst entry while cache-hot for GSO case too
Date: Thu, 10 Dec 2009 09:21:00 +0100
Message-ID: <4B20AF6C.2060604@gmail.com>
References: <20091210065958.10261.89370.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47194 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760788AbZLJIVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:21:00 -0500
In-Reply-To: <20091210065958.10261.89370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 07:59, Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Non-GSO code drops dst entry for performance reasons, but
> the same is missing for GSO code. Drop dst while cache-hot
> for GSO case too.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>=20
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c	2009-12-10 10:20:39.000000000 +0530
> +++ new/net/core/dev.c	2009-12-10 10:21:17.000000000 +0530
> @@ -1853,6 +1853,14 @@ gso:
> =20
>  		skb->next =3D nskb->next;
>  		nskb->next =3D NULL;
> +
> +		/*
> +		 * If device doesnt need nskb->dst, release it right now while
> +		 * its hot in this cpu cache
> +		 */
> +		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> +			skb_dst_drop(nskb);
> +
>  		rc =3D ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc !=3D NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

