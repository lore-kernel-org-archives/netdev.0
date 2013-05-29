From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: Fix build warnings after mac_header and
Date: Wed, 29 May 2013 12:14:09 +0900
Message-ID: <20130529031409.GA16040@verge.net.au>
References: <20130528.131614.2137913181835631312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55293 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759194Ab3E2DRR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 23:17:17 -0400
Content-Disposition: inline
In-Reply-To: <20130528.131614.2137913181835631312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 01:16:14PM -0700, David Miller wrote:
>=20
> net/core/skbuff.c: In function =E2=80=98__alloc_skb_head=E2=80=99:
> net/core/skbuff.c:203:2: warning: large integer implicitly truncated =
to unsigned type [-Woverflow]
> net/core/skbuff.c: In function =E2=80=98__alloc_skb=E2=80=99:
> net/core/skbuff.c:279:2: warning: large integer implicitly truncated =
to unsigned type [-Woverflow]
> net/core/skbuff.c:280:2: warning: large integer implicitly truncated =
to unsigned type [-Woverflow]
> net/core/skbuff.c: In function =E2=80=98build_skb=E2=80=99:
> net/core/skbuff.c:348:2: warning: large integer implicitly truncated =
to unsigned type [-Woverflow]
> net/core/skbuff.c:349:2: warning: large integer implicitly truncated =
to unsigned type [-Woverflow]
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Sorry about that. I think there are also some other warnings which show=
 up
on i386 (at least). I will work on fixing them too.

> ---
>  net/core/skbuff.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d629891..f45de07 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -200,7 +200,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, =
int node)
>  	atomic_set(&skb->users, 1);
> =20
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header =3D ~0U;
> +	skb->mac_header =3D (__u16) ~0U;
>  #endif
>  out:
>  	return skb;
> @@ -276,8 +276,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
>  	skb_reset_tail_pointer(skb);
>  	skb->end =3D skb->tail + size;
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header =3D ~0U;
> -	skb->transport_header =3D ~0U;
> +	skb->mac_header =3D (__u16) ~0U;
> +	skb->transport_header =3D (__u16) ~0U;
>  #endif
> =20
>  	/* make sure we initialize shinfo sequentially */
> @@ -345,8 +345,8 @@ struct sk_buff *build_skb(void *data, unsigned in=
t frag_size)
>  	skb_reset_tail_pointer(skb);
>  	skb->end =3D skb->tail + size;
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header =3D ~0U;
> -	skb->transport_header =3D ~0U;
> +	skb->mac_header =3D (__u16) ~0U;
> +	skb->transport_header =3D (__u16) ~0U;
>  #endif
> =20
>  	/* make sure we initialize shinfo sequentially */
> --=20
> 1.7.11.7
>=20
> N=C2=8B=C2=A7=C2=B2=CE=B6=CE=BCr=CE=88=C2=9By=CF=8A=CE=B8=C2=9A=CE=A8=
b=C2=B2X=C2=AC=CE=86=CE=97=C2=A7v=CE=A8^=C2=96)=CE=AE=CE=8A{.n=CE=97+=C2=
=89=C2=B7=C2=A7z=CE=A7^=CE=8E)=CE=BD=C2=85=CE=B6=CE=B8w*=1Fjg=C2=AC=C2=B1=
=C2=A8=1E=CE=86=C2=89=C2=9A=C2=8E=C2=8A=CE=AD=E2=80=99j/=C2=81=CE=BA=CE=
=B4z=CE=89=CE=AE=C2=96=C2=8A=CE=B02=C2=8A=CE=AE=C2=99=C2=A8=CE=B8=C2=AD=
=CE=AA&=E2=80=99)=CE=AF=E2=80=98=C2=ABa=CE=86=CE=AA=7F=CF=8E=CF=88=1E?G=
=C2=AB=C2=9D=CE=B9h?=0F=CE=B6j:+v=C2=89=C2=A8=C2=8Aw=CE=B8=C2=86=CE=A9=E2=
=82=AF
