From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.4] fix ipt_ULOG bogus error messages
Date: Mon, 25 Oct 2004 09:47:58 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041025074758.GP18934@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CbqR2XcyIs6OSP+I"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--CbqR2XcyIs6OSP+I
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[sorry for forgetting the Signed-off-by in the 2.6.x patch, it is hereby
 implied]

Hi Dave!

Please apply the fix below, it addresses some bogus error messages
("error during NLMSG_PUT") that were printed because of a wrong
calculation of the 'len' parameter to NLMSG_PUT().

Signed-off-by: Harald Welte <laforge@netfilter.org>


diff -Nru --exclude .depend --exclude '*.o' --exclude '*.ko' --exclude '*.v=
er' --exclude '.*.flags' --exclude '*.orig' --exclude '*.rej' --exclude '*.=
cmd' --exclude '*.mod.c' --exclude '*~' linux-2.4.28-pre3-plain/net/ipv4/ne=
tfilter/ipt_ULOG.c linux-2.4.28-pre3-ulog/net/ipv4/netfilter/ipt_ULOG.c
--- linux-2.4.28-pre3-plain/net/ipv4/netfilter/ipt_ULOG.c	2004-08-08 01:26:=
06.000000000 +0200
+++ linux-2.4.28-pre3-ulog/net/ipv4/netfilter/ipt_ULOG.c	2004-10-25 09:46:0=
6.319745399 +0200
@@ -1,7 +1,7 @@
 /*
  * netfilter module for userspace packet logging daemons
  *
- * (C) 2000-2002 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2000-2004 by Harald Welte <laforge@netfilter.org>
  *
  * 2000/09/22 ulog-cprange feature added
  * 2001/01/04 in-kernel queue as proposed by Sebastian Zander=20
@@ -13,6 +13,8 @@
  * 2002/07/07 remove broken nflog_rcv() function -HW
  * 2002/08/29 fix shifted/unshifted nlgroup bug -HW
  * 2002/10/30 fix uninitialized mac_len field - <Anders K. Pedersen>
+ * 2004/10/25 fix erroneous calculation of 'len' parameter to NLMSG_PUT
+ *	      resulting in bogus 'error during NLMSG_PUT' messages.
  *
  * Released under the terms of the GPL
  *
@@ -203,7 +205,7 @@
=20
 	/* NLMSG_PUT contains a hidden goto nlmsg_failure !!! */
 	nlh =3D NLMSG_PUT(ub->skb, 0, ub->qlen, ULOG_NL_EVENT,=20
-			size - sizeof(*nlh));
+			sizeof(*pm)+copy_len);
 	ub->qlen++;
=20
 	pm =3D NLMSG_DATA(nlh);

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--CbqR2XcyIs6OSP+I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBfK+uXaXGVTD0i/8RAradAJ9iD4JfKx4vdn8fh8n8TrUVwtyXYwCfUhNB
p+oi2EG8PBOTBvsbt+8sibg=
=4ntx
-----END PGP SIGNATURE-----

--CbqR2XcyIs6OSP+I--
