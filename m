From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [XFRM]: Don't dereference error pointer dst1
Date: Wed, 29 Sep 2010 22:45:13 +0200
Message-ID: <1285793113.5211.8.camel@edumazet-laptop>
References: <4CA3BFA3.1060204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA3BFA3.1060204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 septembre 2010 =C3=A0 00:37 +0200, Roel Kluin a =C3=A9crit =
:
> Don't dereference dst1 when it's an error pointer.
>=20
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  net/xfrm/xfrm_policy.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> I just noticed this by code analysis. It wasn't tested in any way.
>=20
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index cbab6e1..b186c3d 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1414,13 +1414,14 @@ static struct dst_entry *xfrm_bundle_create(s=
truct xfrm_policy *policy,
> =20
>  	for (; i < nx; i++) {
>  		struct xfrm_dst *xdst =3D xfrm_alloc_dst(net, family);
> -		struct dst_entry *dst1 =3D &xdst->u.dst;
> +		struct dst_entry *dst1;
> =20
>  		err =3D PTR_ERR(xdst);
>  		if (IS_ERR(xdst)) {
>  			dst_release(dst);
>  			goto put_states;
>  		}
> +		dst1 =3D &xdst->u.dst;
> =20
>  		if (!dst_prev)
>  			dst0 =3D dst1;
>=20

This is not a dereference, but a cast from "struct xfrm_dst *" to
"struct dst_entry *"
