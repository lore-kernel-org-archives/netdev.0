From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 16:09:22 +0200
Message-ID: <20170609140922.GD31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
 <20170609132624.GC20756@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="sgneBHv3152wZ8jf"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:44830 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdFIOJY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 10:09:24 -0400
Content-Disposition: inline
In-Reply-To: <20170609132624.GC20756@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sgneBHv3152wZ8jf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, Jun 09, 2017 at 03:26:24PM +0200, Andrew Lunn wrote:
> On Fri, Jun 09, 2017 at 10:25:41AM +0200, Antoine Tenart wrote:
> > On Thu, Jun 08, 2017 at 09:42:21AM -0700, Florian Fainelli wrote:
> > >=20
> > > If I get this right, the xMDIO controller is actually a superset of t=
he
> > > MDIO controller and has an extra MVMDIO_XSMI_ADDR_REG register to
> > > preform C45 accesses?
> >=20
> > This is also a mistake. It's not a superset as the register offsets are
> > different. So we can't use the same smi operations in both cases. We
> > would need dedicated xmdio smi operations, but I don't think there is a
> > board where a c22 PHY is connected to the xMDIO interface.
>=20
> Is it described as one device, which can do c22 via one set of
> registers, and c45 by another set of registers?
>=20
> Or are there two separate devices. In particular, does each device
> have there own MDC and MDIO pins? Do we have an C22 only device/bus,
> and a C45 only device/bus?

The MDIO/xMDIO registers are embedded into the network controller. The
mvmdio driver was created at first to abstract this functionality
outside the network controller driver because it is shared between all
ports and used in different IPs. So it's not really devices per say.

Looking at the datasheet/schematics there are two hardware buses, one
for c22 and one for c45. So we should keep two separate nodes to
describe the two interfaces. From what I read c45 is backward
compatible with c22 so the xSMI interface should be capable to speak to
c22 PHYs as well. And by looking at the datasheet this seems possible,
although it's not completely clear. But anyway this wouldn't impact the
dt bindings.

What I'll propose in v3 is two separate nodes, with their own
compatibles. The driver will have smi ops for the marvell,orion-mdio and
xsmi ops for the marvell,xmdio. I won't implement for now the smi ops
for marvell,xmdio as I can't test them and can't be 100% sure it would
work. (But again this won't impact the dt and can be updated in the
driver later).

Does that sound right?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--sgneBHv3152wZ8jf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOqwRAAoJEFxNi8it27zYONoP/32rRCZl6ZZpysP9UFfSmFbY
QL9vY1bql34ERxjfqcd8rCVtTcvrhUsnW5O4BkVUu6uNrAmaqYi5A/Bdl7uyRAaV
jPVawzcYof89mi4odrJwyqDj1PN4ceVDuXfqYAFk0dOwWABAX5QaVStSJ+xJ5/VB
7FcIIn/QXfPiu/noB7nt6W54mBua1MKCjWggYnZdHtpCz8uzBfPZXQGvqHAaguVg
TfJVyndQYLDTwlmOCYCMD9tzvNg0p+7v8ydvEuCuM/rFBee8Ern5HBohgtV1UAWd
29aB4sNYM6I5hHdNbxZLMUFGyzjCAS7Y5EQeyU0NVJ5JBWYe1Q8SeOBYWlvG6uuf
klz7OB07IsxwvJlD9MzHDbEUYkcNBH3DaPCJV0zJJ8/0K5dr/rSi/0Ix8HbD8GIw
8YOJjHYyNF2XQTWtXBG+G2/lVgD2cteTwvQNEeZoJHxNocF/blNqolbcpifBKab2
dvLMRp1s9N7QE0y6REBLmowHonwHWp6Hegh1xdZhtBifhM6ERjVuvpT8soqlzPLL
iHZvtE1nV7WqsNQDwfJAQ1+Zl05vWkWPLFsP1Vghp7dnuhLGup56wQ68BS+IcD79
qzW7LJKasHF2FzcEcb+qrxF4KQDoDjIrRZOezfhEdsHlPDTgB+O2dYKqwRyHb7lp
0EYlDp1/FkAJ8GYtlM6l
=CiFS
-----END PGP SIGNATURE-----

--sgneBHv3152wZ8jf--
