From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net/core: neighbour update Oops
Date: Tue, 13 Jul 2010 17:38:31 +0200
Message-ID: <1279035511.2634.456.camel@edumazet-laptop>
References: <734423.1943.qm@web52004.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Doug Kehn <rdkehn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:42839 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931Ab0GMPif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 11:38:35 -0400
Received: by wwi18 with SMTP id 18so560140wwi.1
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 08:38:34 -0700 (PDT)
In-Reply-To: <734423.1943.qm@web52004.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 juillet 2010 =C3=A0 08:23 -0700, Doug Kehn a =C3=A9crit :
> When configuring DMVPN (GRE + openNHRP) and a GRE remote
> address is configured a kernel Oops is observed.  The
> obserseved Oops is caused by a NULL header_ops pointer
> (neigh->dev->header_ops) in neigh_update_hhs() when
>=20
> void (*update)(struct hh_cache*, const struct net_device*, const unsi=
gned char *)
> =3D neigh->dev->header_ops->cache_update;
>=20
> is executed.  The dev associated with the NULL header_ops is
> the GRE interface.  This patch guards against the
> possibility that header_ops is NULL.
>=20
> This Oops was first observed in kernel version 2.6.26.8.
>=20
> Signed-off-by: Doug Kehn <rdkehn@yahoo.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/core/neighbour.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 6ba1c0e..a4e0a74 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -949,7 +949,10 @@ static void neigh_update_hhs(struct neighbour *n=
eigh)
>  {
>  	struct hh_cache *hh;
>  	void (*update)(struct hh_cache*, const struct net_device*, const un=
signed char *)
> -		=3D neigh->dev->header_ops->cache_update;
> +		=3D NULL;
> +
> +	if (neigh->dev->header_ops)
> +		update =3D neigh->dev->header_ops->cache_update;
> =20
>  	if (update) {
>  		for (hh =3D neigh->hh; hh; hh =3D hh->hh_next) {


