From: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Subject: [PATCH 6/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 74, 75
Date: Mon, 24 May 2004 04:32:54 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040524083254.GG3330@ruslug.rutgers.edu>
Reply-To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opU1cLy5W6t5oyvs"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--opU1cLy5W6t5oyvs
Content-Type: multipart/mixed; boundary="T5F8Mpu1Sg8jtYtl"
Content-Disposition: inline


--T5F8Mpu1Sg8jtYtl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


2004-03-22      Aurelien Alleaume <slts@free.fr>

        * oid_mgt.c, isl_ioctl.c : Minor bugfixes : #74 and #75.

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--T5F8Mpu1Sg8jtYtl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="06-fix-bug-74-75.patch"
Content-Transfer-Encoding: quoted-printable

2004-03-22	Aurelien Alleaume <slts@free.fr>

	* oid_mgt.c, isl_ioctl.c : Minor bugfixes : #74 and #75.

Index: linux-2.6.7-rc1/drivers/net/wireless/prism54/isl_ioctl.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /var/lib/cvs/prism54-ng/ksrc/isl_ioctl.c,v
retrieving revision 1.149
retrieving revision 1.150
diff -u -r1.149 -r1.150
--- linux-2.6.7-rc1/drivers/net/wireless/prism54/isl_ioctl.c	20 Mar 2004 16=
:58:36 -0000	1.149
+++ linux-2.6.7-rc1/drivers/net/wireless/prism54/isl_ioctl.c	22 Mar 2004 11=
:21:22 -0000	1.150
@@ -1,4 +1,4 @@
-/*  $Header: /var/lib/cvs/prism54-ng/ksrc/isl_ioctl.c,v 1.149 2004/03/20 1=
6:58:36 mcgrof Exp $
+/*  $Header: /var/lib/cvs/prism54-ng/ksrc/isl_ioctl.c,v 1.150 2004/03/22 1=
1:21:22 ajfa Exp $
  * =20
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
@@ -329,9 +329,9 @@
 	int rvalue;
 	u32 c;
=20
-	if (fwrq->m  < 1000)
+	if (fwrq->m < 1000)
 		/* we have a channel number */
-		c =3D  fwrq->m;
+		c =3D fwrq->m;
 	else
 		c =3D (fwrq->e =3D=3D 1) ? channel_of_freq(fwrq->m / 100000) : 0;
=20
@@ -1893,7 +1893,8 @@
 	struct net_device *ndev =3D frame->ndev;
 	enum oid_num_t n =3D mgt_oidtonum(frame->header->oid);
=20
-	prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
+	if (n !=3D OID_NUM_LAST)
+		prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
 	islpci_mgt_release(frame);
 }
=20
Index: linux-2.6.7-rc1/drivers/net/wireless/prism54/oid_mgt.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /var/lib/cvs/prism54-ng/ksrc/oid_mgt.c,v
retrieving revision 1.12
retrieving revision 1.13
diff -u -r1.12 -r1.13
--- linux-2.6.7-rc1/drivers/net/wireless/prism54/oid_mgt.c	20 Mar 2004 16:5=
8:37 -0000	1.12
+++ linux-2.6.7-rc1/drivers/net/wireless/prism54/oid_mgt.c	22 Mar 2004 11:2=
1:22 -0000	1.13
@@ -688,13 +688,13 @@
 {
 	int i;
=20
-	for (i =3D 0; i < OID_NUM_LAST - 1; i++)
+	for (i =3D 0; i < OID_NUM_LAST; i++)
 		if (isl_oid[i].oid =3D=3D oid)
 			return i;
=20
 	printk(KERN_DEBUG "looking for an unknown oid 0x%x", oid);
=20
-	return 0;
+	return OID_NUM_LAST;
 }
=20
 int

--T5F8Mpu1Sg8jtYtl--

--opU1cLy5W6t5oyvs
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAsbM2at1JN+IKUl4RAk0WAJ9+VNBMyM0t6T5D/BLcop3yWm0NngCgjRcq
WP2doe+T86MQPtDxketM0HQ=
=9/Wy
-----END PGP SIGNATURE-----

--opU1cLy5W6t5oyvs--
