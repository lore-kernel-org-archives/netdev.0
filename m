From: Martin Josefsson <gandalf@netfilter.org>
Subject: [PATCH 2.6] Netfilter: Sane ip_ct_tcp_timeout_close_wait value
Date: Fri, 28 Nov 2003 20:06:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070046413.18456.23.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Z8Pz66szwxPS3LCKFoY/"
Cc: Harald Welte <laforge@netfilter.org>,
        Netfilter-devel <netfilter-devel@lists.netfilter.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Z8Pz66szwxPS3LCKFoY/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi Dave.

Harald submitted this to you for 2.4.23
It's needed for 2.6 as well, couldn't find the original mail on any list
so here's the bk-commits-24 mail (slightly edited)

It applies fine to -test11.
It's needed before 2.6.0 is out.

ChangeSet 1.1211, 2003/11/17 15:26:43-02:00, laforge@netfilter.org

	[PATCH] Netfilter: Sane ip_ct_tcp_timeout_close_wait value
=09
	Hi Dave, hi Marcelo.
=09
	The following (trivial) patch _needs_ to go into 2.4.22-preX before
	2.4.23 is released.
=09
	While doing the backport of the tune-conntrack-timeouts-via-procfs
	patch, we have made the default for the CLOSE_WAIT state accidentially
	to 3 days.  3 days are the timeout when using the tcp window tracking
	patch, but not for the stock kernel.
=09
	Please apply, thanks.

diff -Nru a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilte=
r/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Mon Nov 17 10:02:36 2003
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Mon Nov 17 10:02:36 2003
@@ -53,7 +53,7 @@
 unsigned long ip_ct_tcp_timeout_syn_recv =3D     60 SECS;
 unsigned long ip_ct_tcp_timeout_established =3D   5 DAYS;
 unsigned long ip_ct_tcp_timeout_fin_wait =3D      2 MINS;
-unsigned long ip_ct_tcp_timeout_close_wait =3D    3 DAYS;
+unsigned long ip_ct_tcp_timeout_close_wait =3D   60 SECS;
 unsigned long ip_ct_tcp_timeout_last_ack =3D     30 SECS;
 unsigned long ip_ct_tcp_timeout_time_wait =3D     2 MINS;
 unsigned long ip_ct_tcp_timeout_close =3D        10 SECS;

--=20
/Martin

--=-Z8Pz66szwxPS3LCKFoY/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/x5zNWm2vlfa207ERAowZAJ0RzFCCL/KVaLrTCukkkSWBkkWA6gCguYUN
Qrv0yjWDTKlfxP+ErcQ75jc=
=HKdP
-----END PGP SIGNATURE-----

--=-Z8Pz66szwxPS3LCKFoY/--
