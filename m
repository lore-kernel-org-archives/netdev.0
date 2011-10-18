From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/7] mlx4_en: Incoming traffic alignment optimizations
Date: Tue, 18 Oct 2011 03:53:19 +0200
Message-ID: <1318902799.2571.26.camel@edumazet-laptop>
References: <4E9C8D53.5040006@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38388 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757165Ab1JRBxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 21:53:24 -0400
Received: by wyg36 with SMTP id 36so89828wyg.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 18:53:23 -0700 (PDT)
In-Reply-To: <4E9C8D53.5040006@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 octobre 2011 =C3=A0 22:17 +0200, Yevgeny Petrilin a =C3=A9c=
rit :
> Packet headers are copied to skb linear part (which is IP aligned), s=
o there is no reason for
> the scatter entry to be IP aligned.
>=20
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---

> @@ -91,7 +91,7 @@
>  /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte=
 MTU
>   * and 4K allocations) */
>  enum {
> -	FRAG_SZ0 =3D 512 - NET_IP_ALIGN,
> +	FRAG_SZ0 =3D 2048,
>  	FRAG_SZ1 =3D 1024,
>  	FRAG_SZ2 =3D 4096,
>  	FRAG_SZ3 =3D MLX4_EN_ALLOC_SIZE

Is the 512 -> 2048 change really wanted ? Its not mentioned in changelo=
g
and is confusing.

This means mlx4 lost the ability to use a small frag (512 bytes) to
store small frames.
