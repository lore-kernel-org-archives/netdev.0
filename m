From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Tue, 11 Oct 2016 22:40:00 +0300
Message-ID: <20161011194000.GO9282@leon.nu>
References: <20161011042222.2366145-1-tom@herbertland.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01E62DC@AcuExch.aculab.com>
 <CALzJLG_9Yr=jCPix2Oisxf22CLHxtYYyXejYxkBi-A85kZ_Shw@mail.gmail.com>
 <CALx6S346RSTg6Knik5J4-BdvnTLrx28y-ADCt9ga344OFq4V0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="y8OL7jWO5wDKNv+B"
Cc: Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@aculab.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44458 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751799AbcJKTkf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 15:40:35 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S346RSTg6Knik5J4-BdvnTLrx28y-ADCt9ga344OFq4V0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y8OL7jWO5wDKNv+B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 11, 2016 at 08:46:45AM -0700, Tom Herbert wrote:
> On Tue, Oct 11, 2016 at 4:57 AM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
> > On Tue, Oct 11, 2016 at 7:50 PM, David Laight <David.Laight@aculab.com> wrote:
> >> From: Tom Herbert
> >>> Sent: 11 October 2016 05:22
> >> ...
> >>> Fix is to create MLX5_SET64_VCHK that takes an additional argument
> >>> that is a constant. There are two callers of MLX5_SET64 that are
> >>> trying to get a variable offset, change those to call MLX5_SET64_VCHK
> >>> passing pas[0] as the argument to use in the offset check.
> >>
> >> I think I'd separate the array index instead.
> >> Something like:
> >>
> >> #define MLX5_SET64_INDEXED(typ, p, fld, ndx, v) do { \
> >>         BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
> >>         __MLX5_SET64(typ, p, fld[ndx], v); \
> >> } while (0)
> >>
> >>         David
> >
> > Yes, I think this looks more natural, but instead MLX5_SET64_INDEXED,
> > I prefer to have 2 macros
> > MLX5_SET64(typ, p, fld, v) and MLX5_ARRAY_SET64(typ, p, fld, idx, v).
> >
> > Tom, do you want me to fix it ?
> >
> Please do.

Saeed,

Do you success to send this patch before -rc1 is released? So Linus's
-rc1 will be clean from such build error.

>
> > Thanks,
> > Saeed.

--y8OL7jWO5wDKNv+B
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX/UAQAAoJEORje4g2clinmmYQAM5iBbCSte/J6zLZ64cxT6ww
UmlVtAL0LB6nXiwEkI7IlUcMw7uvABk+jYZ19hJM/R6BVaY7E+X/ASQM9REvw7ox
u3k7qloWum5USZIpA3F2YCptX4lozpST6SlSCfE7Ri6EbJ2g0dNYw3qxfafKn7VK
MbemDNCTaioS5EQ73T6iwyCaZVTnjcsK9a4YHs31094858Bp7mlXZLlZEQqDTjLm
lZT+68zhZPiKJEZ6ozBZXEZcLAuB8S4OPOyRGQoZ0/tJzxmX1+ii8SuHIimUPZAU
DbTdDwrcdWGwZGMZ2opn8fH4TUOyYq+yECw21kvdE+JU3nDv7IskkuyGi7vbrmss
bB5F4ej08Bt+pKAV8U2tXuJHeEB9M65xzIQVgZUv5S2wOVWITgiZ/IpMVyGngg1V
C2cRbaYZh757bUZt4+OjL0E1bAjrn5bt+ryOXYXjLysww9YZ8MCe6x5Y3tb3TCiH
m92h3wHHCVgA6LgWolbQCri+btfyR+hDaMX8GFy/pEJ0hHU9PEP2nDPxL5sLzuRT
nUK0FD/siSKMbL1PrqH6dBgZxCpuKDyW37PaIrUljA1Vnj4QYue6cg+nx+snIYag
IbOv4jcJsAZm306R9tRrkN41ijIHWSzy5ZVzWVpYLLWGQpvZ2TXVmr2jMan+T1d/
7FJW2EupykwIPEyPbLfB
=p+3E
-----END PGP SIGNATURE-----

--y8OL7jWO5wDKNv+B--
