From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Set rt->rt_iif more sanely on output routes.
Date: Sat, 05 Mar 2011 07:52:21 +0100
Message-ID: <1299307941.2758.69.camel@edumazet-laptop>
References: <20110304.213625.104050222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49303 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab1CEGw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 01:52:26 -0500
Received: by wwb22 with SMTP id 22so3414229wwb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 22:52:25 -0800 (PST)
In-Reply-To: <20110304.213625.104050222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 21:36 -0800, David Miller a =C3=A9crit =
:
> rt->rt_iif is only ever inspected on input routes, for example DCCP
> uses this to populate a route lookup flow key when generating replies
> to another packet.
>=20
> Therefore, setting it to anything other than zero on output routes
> makes no sense.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 9794a2c..602473c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2381,7 +2381,7 @@ static struct rtable *__mkroute_output(const st=
ruct fib_result *res,
>  	rth->fl.mark    =3D oldflp->mark;
>  	rth->rt_dst	=3D fl->fl4_dst;
>  	rth->rt_src	=3D fl->fl4_src;
> -	rth->rt_iif	=3D oldflp->oif ? : dev_out->ifindex;
> +	rth->rt_iif	=3D 0;
>  	/* get references to the devices that are to be hold by the routing
>  	   cache entry */
>  	rth->dst.dev	=3D dev_out;

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


