From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: sch_dsmark bug
Date: Mon, 12 Apr 2004 00:52:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040411225246.GA8644@zion.homelinux.com>
References: <40793D5A.9060706@innerghost.net> <1081712583.1044.375.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ADZbWkCsHQ7r3kzd"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <1081712583.1044.375.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ADZbWkCsHQ7r3kzd
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Apr 11, 2004 at 03:43:03PM -0400, jamal told us:
>=20
> Looks legit nit. Why are you sending empty opts anyways? ;->
> patchlet attached - you should have sent one ;->
> Maybe you can inspect other qdiscs.
>=20
> cheers,
> jamal
>=20

I took a look at the others and found this ones...


Sven

--=20
Linux zion 2.6.5 #1 Sun Apr 4 19:56:55 CEST 2004 i686 athlon i386 GNU/Linux
 00:43:25  up 7 days,  1:27,  2 users,  load average: 0.02, 0.05, 0.01

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="sched.patch"
Content-Transfer-Encoding: quoted-printable

--- net/sched/sch_cbq.c.orig	2004-04-12 00:24:08.123743284 +0200
+++ net/sched/sch_cbq.c	2004-04-12 00:40:30.186534165 +0200
@@ -1399,7 +1399,8 @@ static int cbq_init(struct Qdisc *sch, s
 	struct rtattr *tb[TCA_CBQ_MAX];
 	struct tc_ratespec *r;
=20
-	if (rtattr_parse(tb, TCA_CBQ_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0 ||
+	if (!opt ||=20
+	    rtattr_parse(tb, TCA_CBQ_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0 ||
 	    tb[TCA_CBQ_RTAB-1] =3D=3D NULL || tb[TCA_CBQ_RATE-1] =3D=3D NULL ||
 	    RTA_PAYLOAD(tb[TCA_CBQ_RATE-1]) < sizeof(struct tc_ratespec))
 		return -EINVAL;
--- net/sched/sch_csz.c.orig	2004-04-12 00:24:08.126743018 +0200
+++ net/sched/sch_csz.c	2004-04-12 00:36:16.195184499 +0200
@@ -763,6 +763,8 @@ static int csz_init(struct Qdisc *sch, s
 	struct tc_csz_qopt *qopt;
 	int    i;
=20
+	if (!opt)
+		return -EINVAL;
 	rtattr_parse(tb, TCA_CSZ_PTAB, RTA_DATA(opt), RTA_PAYLOAD(opt));
 	if (tb[TCA_CSZ_PARMS-1] =3D=3D NULL ||
 	    RTA_PAYLOAD(tb[TCA_CSZ_PARMS-1]) < sizeof(*qopt))

--Kj7319i9nmIyA2yE--

--ADZbWkCsHQ7r3kzd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAecw+o4FAdB2PneQRAmHIAJ9YyIEveq5zX/P+R4dcbYowsxhOvgCfVBLY
fpVeWUPpePlbroynOrZvxA0=
=dZoe
-----END PGP SIGNATURE-----

--ADZbWkCsHQ7r3kzd--
