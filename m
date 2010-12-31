From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: eepro testing positive EBUSY return by
 request_irq()?
Date: Fri, 31 Dec 2010 15:27:42 +0000
Message-ID: <1293809262.2870.45.camel@localhost>
References: <4D1DECFC.8020701@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-jYbOy25JKJQuq2mVCUlZ"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: roel kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D1DECFC.8020701@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jYbOy25JKJQuq2mVCUlZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-12-31 at 15:47 +0100, roel kluin wrote:
> Fix -EBUSY test for request_irq().
>=20
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/eepro.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> I just found this in the code, no bug was observed. Is this patch needed?=
 the test
> for an -EBUSY return by request_irq() occurs much more frequently in kern=
el code.
>=20
> diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
> index 7c82631..47cfecb 100644
> --- a/drivers/net/eepro.c
> +++ b/drivers/net/eepro.c
> @@ -920,7 +920,7 @@ static int	eepro_grab_irq(struct net_device *dev)
> =20
>  		eepro_sw2bank0(ioaddr); /* Switch back to Bank 0 */
> =20
> -		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) !=3D EBUSY) {
> +		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) !=3D -EBUSY) =
{
>  			unsigned long irq_mask;
>  			/* Twinkle the interrupt, and check if it's seen */
>  			irq_mask =3D probe_irq_on();

This condition is completely bogus - request_irq() with a NULL handler
now returns -EINVAL before even checking whether the IRQ is in use.  The
code should be fixed along the lines of what I did for 3c503 in commit
b0cf4dfb7cd21556efd9a6a67edcba0840b4d98d.

The e2100 and hp net drivers have the same bug.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-jYbOy25JKJQuq2mVCUlZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATR32YOe/yOyVhhEJAQJRGRAAvRDwjYHPvS/fx8b2IDaj/aNUUVQ7pbrc
ev4HUASdN1KlNzDji2RvUSH9xZJP2F68gJwgEOeLf9aEbPEiDDOqQuNtiIq56cY+
kkYTENnV+fnrVEWxyyhIu6sNyZloZsxywx/tgTKMhXy8b4Aho1sehgOauEfNgJM+
oYS2LeHaeJVsjTHcllfcDTWBQOKSbjMuusEISl2CVaRmMhu1d7+ooU3meM2aIkB8
2D5PEnukgwqoEws/GDPygmq9uerL00HVM3IE+5f4HH3Hzf9W4g21KlCCoLK6Kaiu
kpg3/FWX4JbkpJkyz6pUGwdC0t0HkZHGLT6K/7phLZ2uCM05DBeLD7jp6uBRIIw3
e8PuSXaK3Z4fljmRh90/v6poVD5BXnT2H5R/uOQEV3awWA1xYsXc7KcCxUU3klCW
IQK++swfM5qr/I9VL2/+lDs/WmNd58pjIUbo5Odc7EXYzefuQP2VbE6p7qxo5XPu
VbAb8eMjM1TifjLOY1hM0FWEGR5zCyIvOFZ5TqklpDAtg2TWxLB7fj5ymirHFqqo
r5XosF3rnx9RwhNmRv+Z5OxFxuPOsvTUUOmxvUt9nNlYhX6gKPEJT+bKpEZTmZrz
N2iSwpROAAVfwltN11407wHP/KbFmtDi305KCfJpnLD1zfk7JygCobpYJAcAUxg7
qBsfH37V8U4=
=iQ9R
-----END PGP SIGNATURE-----

--=-jYbOy25JKJQuq2mVCUlZ--
