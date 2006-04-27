From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 00:03:12 +0200
Message-ID: <200604280003.12743.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2048950.nZ3aBFzt26";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751795AbWD0WCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:14 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:13 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2048950.nZ3aBFzt26
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

=46ix various little/big endian conversions.
rt2500pci should use cpu_to_le32 and rt2500usb should not.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:50:36.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:51:11.000000000 +0200
@@ -441,7 +441,7 @@ rt2500pci_config_channel(struct rt2x00_p
 	txpower =3D (txpower > 31) ? 31 : txpower;
=20
 	if (rt2x00_rf(&rt2x00pci->chip, RF2525E) && channel =3D=3D 14)
=2D		rf4 |=3D 0x00000010;
+		rf4 |=3D cpu_to_le32(0x00000010);
=20
 	if (rt2x00_rf(&rt2x00pci->chip, RF5222)) {
 		if (channel < 14) {
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:50:36.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:51:11.000000000 +0200
@@ -324,20 +324,20 @@ rt2500usb_config_channel(struct rt2x00_u
=20
 	if (rt2x00_rf(&rt2x00usb->chip, RF5222)) {
 		if (channel < 14) {
=2D			rf1 =3D cpu_to_le32(0x00022020);
=2D			rf4 =3D cpu_to_le32(0x00000a0b);
+			rf1 =3D 0x00022020;
+			rf4 =3D 0x00000a0b;
 		} else if (channel =3D=3D 14) {
=2D			rf1 =3D cpu_to_le32(0x00022010);
=2D			rf4 =3D cpu_to_le32(0x00000a1b);
+			rf1 =3D 0x00022010;
+			rf4 =3D 0x00000a1b;
 		} else if (channel < 64) {
=2D			rf1 =3D cpu_to_le32(0x00022010);
=2D			rf4 =3D cpu_to_le32(0x00000a1f);
+			rf1 =3D 0x00022010;
+			rf4 =3D 0x00000a1f;
 		} else if (channel < 140) {
=2D			rf1 =3D cpu_to_le32(0x00022010);
=2D			rf4 =3D cpu_to_le32(0x00000a0f);
+			rf1 =3D 0x00022010;
+			rf4 =3D 0x00000a0f;
 		} else if (channel < 161) {
=2D			rf1 =3D cpu_to_le32(0x00022020);
=2D			rf4 =3D cpu_to_le32(0x00000a07);
+			rf1 =3D 0x00022020;
+			rf4 =3D 0x00000a07;
 		}
 	}
=20
@@ -1829,7 +1829,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		};
=20
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
=2D			channels[counter].val =3D cpu_to_le32(vals[counter]);
+			channels[counter].val =3D vals[counter];
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2523)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2524)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2525)) {
@@ -1841,8 +1841,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		};
=20
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
=2D				channels[counter].val =3D
=2D				cpu_to_le32(vals[counter] | rf2_base);
+			channels[counter].val =3D vals[counter] | rf2_base;
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2525E)) {
 		u32 vals[] =3D {
 			0x0000089a, 0x0000089e, 0x0000089e, 0x000008a2,
@@ -1852,7 +1851,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		};
=20
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
=2D			channels[counter].val =3D cpu_to_le32(vals[counter]);
+			channels[counter].val =3D vals[counter];
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF5222)) {
 		static u32 vals[] =3D {
 			0x00001136, 0x0000113a, 0x0000113e, 0x00001182,
@@ -1868,7 +1867,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		};
=20
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
=2D			channels[counter].val =3D cpu_to_le32(vals[counter]);
+			channels[counter].val =3D vals[counter];
 		}
=20
 		/*
@@ -1895,9 +1894,9 @@ rt2500usb_init_hw_channels(struct rt2x00
 	 */
 	for (counter =3D 0; counter < ARRAY_SIZE(rf); counter++) {
 		if (rt2x00_rf(&rt2x00usb->chip, rf[counter].chip)) {
=2D			rt2x00usb->rf1 =3D cpu_to_le32(rf[counter].val[0]);
=2D			rt2x00usb->rf3 =3D cpu_to_le32(rf[counter].val[1]);
=2D			rt2x00usb->rf4 =3D cpu_to_le32(rf[counter].val[2]);
+			rt2x00usb->rf1 =3D rf[counter].val[0];
+			rt2x00usb->rf3 =3D rf[counter].val[1];
+			rt2x00usb->rf4 =3D rf[counter].val[2];
 		}
 	}
 }

--nextPart2048950.nZ3aBFzt26
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+gaqndE37Em0gRAiStAKCv9biFw+76uj04L4TH07dVZB33bgCg0ani
aBwrh2/Ci3iNi2JIU/wdifg=
=q9yO
-----END PGP SIGNATURE-----

--nextPart2048950.nZ3aBFzt26--
