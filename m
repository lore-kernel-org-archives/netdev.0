From: Florian Schirmer <jolt@tuxbox.org>
Subject: [PATCH][1/4] b44: Ignore carrier lost errors
Date: Sun, 29 Aug 2004 22:33:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408292233.03879.jolt@tuxbox.org>
References: <200408292218.00756.jolt@tuxbox.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4363059.hI9ds1C5mR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <200408292218.00756.jolt@tuxbox.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart4363059.hI9ds1C5mR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

some (?) hardware seems to be buggy and is reporting bogus carrier lost=20
values. Both reference implementations from Broadcom indicate that this=20
counter is not reliable and therefore ignore it. We should do the same.=20
"Fixes" the carrier lost problem i've seen.

Regards,
  Florian

Signed-off-by: Florian Schirmer <jolt@tuxbox.org>

=2D-- linux/drivers/net/b44.c-old1 2004-08-29 16:29:08.000000000 +0200
+++ linux/drivers/net/b44.c 2004-08-29 16:27:00.000000000 +0200
@@ -1347,7 +1347,10 @@ static struct net_device_stats *b44_get_
        hwstat->rx_symbol_errs);
=20
  nstat->tx_aborted_errors =3D hwstat->tx_underruns;
+#if 0
+ /* Carrier lost counter seems to be broken for some devices */
  nstat->tx_carrier_errors =3D hwstat->tx_carrier_lost;
+#endif
=20
  return nstat;
 }


--nextPart4363059.hI9ds1C5mR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBMj1/XRF2vHoIlBsRAuu+AJ4g0h+y0C6Pzxs5KRHbzRFYxxQkMgCffMc5
xi/gaTBErr9kmuH3A8usvZE=
=mPTU
-----END PGP SIGNATURE-----

--nextPart4363059.hI9ds1C5mR--
