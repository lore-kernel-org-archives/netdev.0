From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [STABLE][3.0][3.2][Add PATCH] phy/fixed: use an unique MDIO bus
 name
Date: Sun, 07 Oct 2012 16:33:39 +0100
Message-ID: <1349624019.16173.113.camel@deadeye.wl.decadent.org.uk>
References: <1349441987.6755.45.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-doV17NCNOcq6R/qjgEMb"
Cc: LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35000 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753316Ab2JGPdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 11:33:47 -0400
In-Reply-To: <1349441987.6755.45.camel@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-doV17NCNOcq6R/qjgEMb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-10-05 at 08:59 -0400, Steven Rostedt wrote:
> I started testing my 3.2-rt branch on a powerpc box and it would
> constantly spit out the following warning causing ktest to think the
> boot failed:
>=20
> sysfs: cannot create duplicate filename '/class/mdio_bus/0
[...]
> Doing some investigations, I found it only triggered on some configs,
> and it was fixed by 3.3. I ran a ktest.pl reverse bisect (bad is good
> and good is bad) and it ended on this commit:
>=20
> commit 9e6c643bb4502c50b6511206601b7760c610dfcc
> Author: Florian Fainelli <florian@openwrt.org>
> Date:   Mon Jan 9 23:59:25 2012 +0000
>=20
>     phy/fixed: use an unique MDIO bus name.
>    =20
>     Signed-off-by: Florian Fainelli <florian@openwrt.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 1fa4d73..633680d 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -220,7 +220,7 @@ static int __init fixed_mdio_bus_init(void)
>                 goto err_mdiobus_reg;
>         }
> =20
> -       snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
> +       snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "fixed-0");
>         fmb->mii_bus->name =3D "Fixed MDIO Bus";
>         fmb->mii_bus->priv =3D fmb;
>         fmb->mii_bus->parent =3D &pdev->dev;
>=20
> Sure enough, adding this patch to both 3.2 and 3.0 fixed the bug.
>=20
> Please pull this patch into the 3.2 and 3.0 stable trees.

Networking stable fixes are normally vetted, backported and bundled up
by David, so I'll let him decide on this.

There are a lot more MDIO bus drivers that don't play nicely with
others, most of which seem to be fixed in mainline.  If David agrees
that these are generally worthwhile then perhaps someone could try to
gather those up?

Ben.

--=20
Ben Hutchings
You can't have everything.  Where would you put it?

--=-doV17NCNOcq6R/qjgEMb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUHGg0+e/yOyVhhEJAQrCsg//WyyzCYf7cBedhxDFTzulIJ1bnoP2kK6+
VfmvVxlfrxec5f5nWfsWHlF+JYG8o/a44yWPIfMgvaUMfmGchHpvqC2a0Zih3W9z
76kDH1wwBR9ui87IGwfFDgznaVfetONYy0U82pRldVzxHPjN4hFL+zKOoXdkMGxp
fMqgxyEav+G1WxpNsOOwXkxPvP3IHeMafO7FxG4lxUcEtSrpJ45SFBJNbrT3vCb7
NSgr64QLGAsCRSBlOQuh69iSa2CDiekKVqzGuW4uczhYviDgu/DtRhHLjZXFCXA6
28JjtizuLig6ThWwteXaF/bxLFj8sZE0t0Yz3un8m1MHZK8/fyXDeQNAcaHh5fhK
brxloxzfkZAZv8CkVwSjAoOYPTGiRD2SUNt9kDfXR3QE1gRp6hhCHvb5teZ131nH
kV4g+FufOnciC47647687Qh5ZSurKISX5ynOyPSjrNrda8469TP67pjd05XJw7KT
q6pkNuXogqkR5L2mvn4kJHoaa2fszY219wU3KUVxS9Z/OqwbG1cWWkFDPLKcoMea
sDfyzon5JWC5bFdMwXOYqwD+MP6S5YEl8XLiFbIv/uaBeDKM+JjoSPksv9Lpr8wY
bgkYpF4N7Dl7EiBFpdqSXMSbStaiSCjY4O5vJp/3dBbxMOH3+l2VKj6K5KHWZbLK
0mW3luBYjhE=
=0myO
-----END PGP SIGNATURE-----

--=-doV17NCNOcq6R/qjgEMb--
