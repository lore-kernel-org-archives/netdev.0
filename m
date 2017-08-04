From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: uapi: MAX_ADDR_LEN vs. numeric 32
Date: Sat, 5 Aug 2017 01:25:19 +0300
Message-ID: <20170804222519.GA11085@altlinux.org>
References: <20170804213325.GC28459@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@virtuozzo.com>
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:49726 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751525AbdHDWZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 18:25:20 -0400
Content-Disposition: inline
In-Reply-To: <20170804213325.GC28459@lakka.kapsi.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, Aug 05, 2017 at 12:33:25AM +0300, Mikko Rapeli wrote:
> First, thanks Dmitry for fixing several uapi compilation problems in
> user space. I got a bit demotivated

That's quite understandable.

> about the slow review progress, e.g.
> no feedback what so ever, on some of the patches, but lets try again...
>=20
> I rebased my tree now and saw
>=20
> commit 745cb7f8a5de0805cade3de3991b7a95317c7c73
> Author: Dmitry V. Levin <ldv@altlinux.org>
> Date:   Tue Mar 7 23:50:50 2017 +0300
>=20
>     uapi: fix linux/packet_diag.h userspace compilation error
>=20
> which does:
>=20
> --- a/include/uapi/linux/packet_diag.h
> +++ b/include/uapi/linux/packet_diag.h
> @@ -64,7 +64,7 @@ struct packet_diag_mclist {
>         __u32   pdmc_count;
>         __u16   pdmc_type;
>         __u16   pdmc_alen;
> -       __u8    pdmc_addr[MAX_ADDR_LEN];
> +       __u8    pdmc_addr[32]; /* MAX_ADDR_LEN */
>  };
> =20
>  struct packet_diag_ring {
>=20
> In my tree I had fixed that case with:
>=20
> --- a/include/uapi/linux/packet_diag.h
> +++ b/include/uapi/linux/packet_diag.h
> @@ -2,6 +2,7 @@
>  #define __PACKET_DIAG_H__
> =20
>  #include <linux/types.h>
> +#include <linux/netdevice.h>
> =20
>  struct packet_diag_req {
>         __u8    sdiag_family;
>=20
> since netdevice.h has the definition also in user space
>=20
> #define MAX_ADDR_LEN    32              /* Largest hardware address lengt=
h */
>=20
> I find using MAX_ADDR_LEN better than numeric 32, though I doubt this will
> change any time soon. Would you mind if I change packet_diag.h and
> if_link.h to use that instead and fix the userspace compilation
> problems by including netdevice.h?

The alternative fix, that is, to include <linux/netdevice.h>
which pulls in other headers and a lot of definitions with them,
has been mentioned in the discussion, too.
We decided that the fix that was applied would be the least of all evils.


--=20
ldv

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJZhPROAAoJEAVFT+BVnCUIDMgP/1NJufpQMb9mZ23Vsp09i7Nj
NveEJMuOeh6mGZwpdZezn4ReucVe7MC+XsITcllwVmCD03j80qZBWXo2wiVtKaub
hbqcIzI1ltVyj814UXXhGS15P1WBu5OVTrPlLzLWUnIDY+akVfMPOMcf2XwJUvGZ
SpgcvSTSEFJR23P0D5YIn+bMeyYqwk7qojm2LgepOXgojWyDxMg14YGIbfkugMmc
eKtK7F0+pqsT/BEMPCbvlZU5fQUD8Hnpb2PMKwExOci1IR4L39tognq9xcdwVxU0
4zUUEKm8aDuLQK/qbELyKDQgnKRahS20GxL/l+cDWolptW1TU8HdWHEYfYZqWNTv
Jp4q82jAeombfOxZheBcH8NpItBf4u0aXdNC5uATnphth9ef9dgdabbmRxLw8Kkm
N7TH6JzypvKq7wTkThIBCP0fRizNeClkMNBkAeIrtDMby+6p4HUXvvIrr1gX4sFn
a6XtkKac7RNeZT5V2gEa3/BDEuQUVHMkMKAfEAQeahvPiJm2tp21tgyBjLNU1/+2
bH1mwYxSlpmP32+3o82k1wyKFmwx4Em09fnnlF7oSXmotW7qsWaNK8Ga0TQVQnRR
9OUzSIL1utZ713X5JkSToDbJgvmNBNahT199wAfsn4SAeDk7xc1QCSpvXrbhpnLs
coAxHUkD2tXgm2ZMoPO8
=RjiJ
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
