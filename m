From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 03:48:45 +0200
Message-ID: <1318902525.2571.24.camel@edumazet-laptop>
References: <4E9C8D8B.90606@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40903 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757165Ab1JRBsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 21:48:50 -0400
Received: by wwe6 with SMTP id 6so138711wwe.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 18:48:49 -0700 (PDT)
In-Reply-To: <4E9C8D8B.90606@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 octobre 2011 =C3=A0 22:18 +0200, Yevgeny Petrilin a =C3=A9c=
rit :
> Moving to Toeplitz function in RSS calculation.
> Reporting rxhash in skb.
>=20
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

>  	rss_context->flags =3D rss_mask;
> +	rss_context->hash_fn =3D 1;
> +	for (i =3D 0; i < 10; i++)
> +		rss_context->rss_key[i] =3D random32();
> =20

Thats bit of a problem : Two NICS will have different seeds, and thus
provide different rxhash for a given flow. A bonding of two NICS will
not be able to provide a consistent rxhash.

drivers/net/ethernet/intel/igb/igb_main.c uses a static table to avoid
this problem.
