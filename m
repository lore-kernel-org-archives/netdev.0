From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH] prism54: fix iwconfig freq listing
Date: Mon, 23 Aug 2004 16:36:51 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040823203651.GH22126@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1275677400=="
Cc: Netdev <netdev@oss.sgi.com>, Jouni Malinen <jkmaline@cc.hut.fi>,
	prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1275677400==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KIzF6Cje4W/osXrF"
Content-Disposition: inline


--KIzF6Cje4W/osXrF
Content-Type: multipart/mixed; boundary="K/NRh952CO+2tg14"
Content-Disposition: inline


--K/NRh952CO+2tg14
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jeff,

my previous patch fixed iwlist eth0 scan listing for frequencies but
broke iwconfig freq listing. I shouldn't have done the first change.
This reverts it. Sorry for the trouble all.

2004-08-23	Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

	* isl_ioctl.c (prism54_get_freq): reverted change to=20
	use frwq->e as 6. This is the mantissa, setting it to 3.
	The other change was correct.

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--K/NRh952CO+2tg14
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="freq2.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.=
6.8.1-wpa/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-23 00:31=
:36.000000000 -0400
+++ linux-2.6.8.1-wpa/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-23 0=
0:17:19.000000000 -0400
@@ -303,7 +303,7 @@ prism54_get_freq(struct net_device *ndev
 	fwrq->i =3D r.u;
 	rvalue |=3D mgt_get_request(priv, DOT11_OID_FREQUENCY, 0, NULL, &r);
 	fwrq->m =3D r.u;
-	fwrq->e =3D 6;
+	fwrq->e =3D 3;
=20
 	return rvalue;
 }

--K/NRh952CO+2tg14--

--KIzF6Cje4W/osXrF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBKlVjat1JN+IKUl4RAgskAJ4iVbenOnRZ0dk88QCBW4l9ms0Y2wCgrkMP
zOxZ1XO7zsJ444ZeKAs8F0U=
=5XKm
-----END PGP SIGNATURE-----

--KIzF6Cje4W/osXrF--

--===============1275677400==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1275677400==--
