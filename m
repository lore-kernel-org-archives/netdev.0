From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] phy/marvell: Add special settings for D-Link DNS-323
	rev C1
Date: Mon, 17 May 2010 02:59:42 +0200
Message-ID: <20100517005942.GB27301@pengutronix.de>
References: <1274056058.21352.697.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1537200953=="
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@fluxnic.net>,
	linux-arm-kernel@lists.infradead.org, Herbert Valerio Riedel <hvr@gnu.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1274056058.21352.697.camel@pasglop>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============1537200953==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QKdGvSO+nmPlgiQ/"
Content-Disposition: inline


--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 17, 2010 at 10:27:38AM +1000, Benjamin Herrenschmidt wrote:
> Without this change, the network LED doesn't work on the device. The
> value itself comes from the vendor kernel.
>=20
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/phy/marvell.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 64c7fbe..22b1efa 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -34,6 +34,10 @@
>  #include <asm/irq.h>
>  #include <asm/uaccess.h>
> =20
> +#ifdef CONFIG_ARM
> +#include <asm/mach-types.h>
> +#endif
> +
>  #define MII_M1011_IEVENT		0x13
>  #define MII_M1011_IEVENT_CLEAR		0x0000
> =20
> @@ -350,7 +354,14 @@ static int m88e1118_config_init(struct phy_device *p=
hydev)
>  		return err;
> =20
>  	/* Adjust LED Control */
> +#ifdef CONFIG_MACH_DNS323
> +	/* The DNS-323 needs a special value in here for the LED to work */
> +	if (machine_is_dns323())
> +		err =3D phy_write(phydev, 0x10, 0x1100);
> +	else
> +#else
>  	err =3D phy_write(phydev, 0x10, 0x021e);
> +#endif

There is a fixup()-callback to prevent boardcode in the drivers. See
Documentation/networking/phy.txt, last chapter.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--QKdGvSO+nmPlgiQ/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkvwlP0ACgkQD27XaX1/VRtolACeJYm2Ni0mmkz/aNp2npE7NkiG
o2IAn19fQmrWloM5GE6g3m1lnCAdCDGH
=phOK
-----END PGP SIGNATURE-----

--QKdGvSO+nmPlgiQ/--


--===============1537200953==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============1537200953==--
