From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Get peer more cheaply in rt_init_metrics().
Date: Sat, 05 Mar 2011 07:46:44 +0100
Message-ID: <1299307604.2758.67.camel@edumazet-laptop>
References: <20110304.212636.226786422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49023 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1CEGqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 01:46:48 -0500
Received: by wwb22 with SMTP id 22so3411937wwb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 22:46:47 -0800 (PST)
In-Reply-To: <20110304.212636.226786422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 21:26 -0800, David Miller  =C3=A9crit :
> We know this is a new route object, so doing atomics and
> stuff makes no sense at all.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6c87403..9794a2c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1759,9 +1759,9 @@ static void rt_init_metrics(struct rtable *rt, =
struct fib_info *fi)
>  	if (rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)
>  		create =3D 1;
> =20
> -	rt_bind_peer(rt, create);
> -	peer =3D rt->peer;
> +	rt->peer =3D peer =3D inet_getpeer_v4(rt->rt_dst, create);
>  	if (peer) {
> +		rt->rt_peer_genid =3D rt_peer_genid();
>  		if (inet_metrics_new(peer))
>  			memcpy(peer->metrics, fi->fib_metrics,
>  			       sizeof(u32) * RTAX_MAX);

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


