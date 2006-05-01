From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: fix iwmode crash when down
Date: Mon, 1 May 2006 22:29:57 +0200
Message-ID: <200605012229.57886.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8961705.UxJqxt9Vx4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:22446
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932226AbWEAUZH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 16:25:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8961705.UxJqxt9Vx4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This should go into 2.6.17, as it fixes a user exploitable crash.

=2D-

This fixes a crash when
iwconfig ethX mode foo
is done before
ifconfig ethX up
or after
ifconfig ethX down

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-04-22 1=
7:47:03.000000000 +0200
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-05-01 22:10:18=
=2E000000000 +0200
@@ -182,8 +182,11 @@
 		mode =3D BCM43xx_INITIAL_IWMODE;
=20
 	bcm43xx_lock_mmio(bcm, flags);
=2D	if (bcm->ieee->iw_mode !=3D mode)
=2D		bcm43xx_set_iwmode(bcm, mode);
+	if (bcm->initialized) {
+		if (bcm->ieee->iw_mode !=3D mode)
+			bcm43xx_set_iwmode(bcm, mode);
+	} else
+		bcm->ieee->iw_mode =3D mode;
 	bcm43xx_unlock_mmio(bcm, flags);
=20
 	return 0;


=2D-=20
Greetings Michael.

--nextPart8961705.UxJqxt9Vx4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEVm/Flb09HEdWDKgRAqcyAKC9nnRvxWMI84+feYzniLe2X/N8RACgoHvb
K76LTIgfykkpLwEjbHFGwr8=
=s8wb
-----END PGP SIGNATURE-----

--nextPart8961705.UxJqxt9Vx4--
