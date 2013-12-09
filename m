From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Mon, 9 Dec 2013 10:51:33 +0100
Message-ID: <20131209095133.GK31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-3-git-send-email-fan.du@windriver.com>
 <20131206114248.GG31491@secunet.com>
 <52A562DF.4090302@windriver.com>
 <20131209085703.GJ31491@secunet.com>
 <52A589D0.4000802@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43108 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932878Ab3LIJvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 04:51:39 -0500
Content-Disposition: inline
In-Reply-To: <52A589D0.4000802@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 09, 2013 at 05:13:52PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 16:57, Steffen Klassert wrote:
> >
> >Instead of doing this check here again, we should implement an equiv=
alent
> >to verify_userspi_info() for pfkey. Then we are sure to have a valid=
 range
> >in any case.
> >
>=20
> How about export an common function in xfrm_state.c to check this cor=
ner case?
> This could be shared by both netlink and pfkey interface, and verify_=
userspi_info
> simplified also?
>=20
> int check_ipcomp_spirange(u8 proto, u32 high)
> {
> 	if ((proto =3D=3D IPPROTO_COMP) && (high > 0xFFFF))
> 		return -EINVAL;
> 	else return 0;
> }
> EXPORT_SYMBOL(check_ipcomp_spirange);

I don't think that we should export such a function,
it is not sufficient.

The netlink interface is ok, it does verify_userspi_info(),
and the pfkey interface need all the checks done in
verify_userspi_info() too. In particular the check if
the minimum spi value is not bigger than the maximum.

So we could either make verify_userspi_info() shared,
or implement a own function for pfkey.
