From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH] prism54: fix wpa_supplicant frequency
	parsing
Date: Sun, 22 Aug 2004 11:15:21 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040822151521.GB22126@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1500878883=="
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


--===============1500878883==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Ycz6tD7Th1CMF4v7"
Content-Disposition: inline


--Ycz6tD7Th1CMF4v7
Content-Type: multipart/mixed; boundary="4ZLFUWh1odzi/v6L"
Content-Disposition: inline


--4ZLFUWh1odzi/v6L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jeff,

the attached patch fixes wpa_supplicant frequency parsing as it relies
on frequency and not channel. With this patch both channel and frequency
are shown in a scan (iwlist eth0 scan). This patch goes on top of my previo=
us set
of patches (and before that ontop of Margit's patches, which you have
not yet committed). This goes for 2.6 and 2.4.=20

2004-08-22      Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

This work fixes wpa_supplicant frequency parsing. iwlist eth0
scan will now show channel and frequency.

* isl_ioctl (prism54_get_freq): use fwrq->e=3D6 as default

* isl_ioctl (prism54_translate_bss): no need now of=20
  channel_of_freq, and use fwrq->e=3D6 as default

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--4ZLFUWh1odzi/v6L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="freq.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.=
6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-18 14:15=
:13.000000000 -0400
+++ linux-2.6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-=
22 09:08:37.000000000 -0400
@@ -303,7 +303,7 @@ prism54_get_freq(struct net_device *ndev
 	fwrq->i =3D r.u;
 	rvalue |=3D mgt_get_request(priv, DOT11_OID_FREQUENCY, 0, NULL, &r);
 	fwrq->m =3D r.u;
-	fwrq->e =3D 3;
+	fwrq->e =3D 6;
=20
 	return rvalue;
 }
@@ -604,8 +604,8 @@ prism54_translate_bss(struct net_device=20
 	current_ev =3D iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
=20
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
-	iwe.u.freq.m =3D channel_of_freq(bss->channel);
-	iwe.u.freq.e =3D 0;
+	iwe.u.freq.m =3D bss->channel;
+	iwe.u.freq.e =3D 6;
 	iwe.cmd =3D SIOCGIWFREQ;
 	current_ev =3D
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);

--4ZLFUWh1odzi/v6L--

--Ycz6tD7Th1CMF4v7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBKLiJat1JN+IKUl4RAlL9AJwIPCZlXTDsTwAui5q1FQlAKH6WbQCcC+QX
2drL/YlkzJw0TAnJMQmEOm0=
=0euk
-----END PGP SIGNATURE-----

--Ycz6tD7Th1CMF4v7--

--===============1500878883==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1500878883==--
