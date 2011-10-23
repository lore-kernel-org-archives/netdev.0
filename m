From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Sun, 23 Oct 2011 11:03:10 +0200
Message-ID: <1319360590.6180.75.camel@edumazet-laptop>
References: <4EA3C91C.3090801@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Kim Phillips <kim.phillips@freescale.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57644 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab1JWJDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 05:03:15 -0400
Received: by wwe6 with SMTP id 6so7578357wwe.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 02:03:14 -0700 (PDT)
In-Reply-To: <4EA3C91C.3090801@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 octobre 2011 =C3=A0 15:58 +0800, Yan, Zheng a =C3=A9crit=
 :
> There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtable)=
=2E
> It makes xfrm4_fill_dst() modify wrong data structure.
>=20
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
>  net/ipv4/xfrm4_policy.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index fc5368a..a0b4c5d 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -79,13 +79,13 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, =
struct net_device *dev,
>  	struct rtable *rt =3D (struct rtable *)xdst->route;
>  	const struct flowi4 *fl4 =3D &fl->u.ip4;
> =20
> -	rt->rt_key_dst =3D fl4->daddr;
> -	rt->rt_key_src =3D fl4->saddr;
> -	rt->rt_key_tos =3D fl4->flowi4_tos;
> -	rt->rt_route_iif =3D fl4->flowi4_iif;
> -	rt->rt_iif =3D fl4->flowi4_iif;
> -	rt->rt_oif =3D fl4->flowi4_oif;
> -	rt->rt_mark =3D fl4->flowi4_mark;
> +	xdst->u.rt.rt_key_dst =3D fl4->daddr;
> +	xdst->u.rt.rt_key_src =3D fl4->saddr;
> +	xdst->u.rt.rt_key_tos =3D fl4->flowi4_tos;
> +	xdst->u.rt.rt_route_iif =3D fl4->flowi4_iif;
> +	xdst->u.rt.rt_iif =3D fl4->flowi4_iif;
> +	xdst->u.rt.rt_oif =3D fl4->flowi4_oif;
> +	xdst->u.rt.rt_mark =3D fl4->flowi4_mark;
> =20
>  	xdst->u.dst.dev =3D dev;
>  	dev_hold(dev);

Good catch, thanks !

Reported-by: Kim Phillips <kim.phillips@freescale.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
