From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Mon, 9 Dec 2013 09:57:03 +0100
Message-ID: <20131209085703.GJ31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-3-git-send-email-fan.du@windriver.com>
 <20131206114248.GG31491@secunet.com>
 <52A562DF.4090302@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41668 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab3LII5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 03:57:05 -0500
Content-Disposition: inline
In-Reply-To: <52A562DF.4090302@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 09, 2013 at 02:27:43PM +0800, Fan Du wrote:
> On 2013=E5=B9=B412=E6=9C=8806=E6=97=A5 19:42, Steffen Klassert wrote:
> >
> >Also, the spi range is user defined, we should respect the
> >users configuration if the range is valid.
>=20
> Ok, then, speaking of respect user defined range, how about below inf=
ormal
> patch which only check the validity of the range? My original thought=
s is CPI
> is only 16bits wide, kernel itself can keep the CPI's validity. btw, =
v2 will
> also fix patch1/3 align issue.
>=20
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 6a9c402..2c6fb99 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1507,6 +1507,9 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 lo=
w, u32 high)
>=20
>         err =3D -ENOENT;
>=20
> +       if ((x->id.proto =3D=3D IPPROTO_COMP) && (high > 0xFFFF))
> +               goto unlock;
> +

This check is already done in verify_userspi_info() if xfrm_alloc_spi()
is called from xfrm_alloc_userspi().

Instead of doing this check here again, we should implement an equivale=
nt
to verify_userspi_info() for pfkey. Then we are sure to have a valid ra=
nge
in any case.
