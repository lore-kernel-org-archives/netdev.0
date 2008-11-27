From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/2] ethtool: Show short message for syntax error
Date: Thu, 27 Nov 2008 04:11:12 +0000
Message-ID: <20081127041112.GK15344@decadentplace.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8sldprk+5E/pDEv"
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:1242 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752119AbYK0Evv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 23:51:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--a8sldprk+5E/pDEv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

In case of a syntax error it's likely to be more helpful to just say
that rather than showing the entire usage information, which is now
very long.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This change has been in Debian for some years, made in response to
bug report http://bugs.debian.org/256249

Ben.

--- ethtool-6+20080227.orig/ethtool.c
+++ ethtool-6+20080227/ethtool.c
@@ -196,15 +196,24 @@
 static void show_usage(int badarg)
 {
 	int i;
-	fprintf(stderr, PACKAGE " version " VERSION "\n");
-	fprintf(stderr,
+	if (badarg !=3D 0) {
+		fprintf(stderr,
+			"ethtool: bad command line argument(s)\n"
+			"For more information run ethtool -h\n"
+		);
+	}
+	else {
+		/* ethtool -h */
+		fprintf(stdout, PACKAGE " version " VERSION "\n");
+		fprintf(stdout,
 		"Usage:\n"
 		"ethtool DEVNAME\tDisplay standard information about device\n");
-	for (i =3D 0; args[i].srt; i++) {
-		fprintf(stderr, "        ethtool %s|%s DEVNAME\t%s\n%s",
-			args[i].srt, args[i].lng,
-			args[i].help,
-			args[i].opthelp ? args[i].opthelp : "");
+		for (i =3D 0; args[i].srt; i++) {
+			fprintf(stdout, "        ethtool %s|%s DEVNAME\t%s\n%s",
+				args[i].srt, args[i].lng,
+				args[i].help,
+				args[i].opthelp ? args[i].opthelp : "");
+		}
 	}
 	exit(badarg);
 }

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at once.

--a8sldprk+5E/pDEv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJLh3g79ZNCRIGYgcRArp7AJ4pPK0tnq484r+oZ8F/sc/EtDjEzwCeKrsd
IQiAcF9EoQeB+FhnU+7Rrs4=
=P2P1
-----END PGP SIGNATURE-----

--a8sldprk+5E/pDEv--
