From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 8/32] rt2x00: Invalid memory allocation check
Date: Fri, 28 Apr 2006 00:02:58 +0200
Message-ID: <200604280002.59427.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1999205.FEkrRxI0yp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751781AbWD0WBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:51 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:51 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1999205.FEkrRxI0yp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

=46ix invalid check when allocating the memory for
the rate structures. Instead of the channel pointer
the rates pointer should be verified.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:40:43.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:41:20.000000000 +0200
@@ -2036,7 +2036,7 @@ rt2400pci_init_hw(struct rt2x00_pci *rt2
 	hw->modes->num_rates =3D 4;
 	hw->modes->rates =3D
 		kzalloc(sizeof(struct ieee80211_rate) * 4, GFP_KERNEL);
=2D	if (!hw->modes->channels)
+	if (!hw->modes->rates)
 		goto exit_free_channels;
=20
 	/*
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:40:43.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:41:20.000000000 +0200
@@ -2236,7 +2236,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
 		hw->modes->rates =3D
 			kzalloc((sizeof(struct ieee80211_rate) * 12),
 			GFP_KERNEL);
=2D		if (!hw->modes->channels)
+		if (!hw->modes->rates)
 			goto exit_free_channels;
 	} else {
 		hw->num_modes =3D 3;
@@ -2255,7 +2255,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
 		hw->modes->rates =3D
 			kzalloc((sizeof(struct ieee80211_rate) * 12),
 			GFP_KERNEL);
=2D		if (!hw->modes->channels)
+		if (!hw->modes->rates)
 			goto exit_free_channels;
 	}
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:40:43.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:41:20.000000000 +0200
@@ -1931,7 +1931,7 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 		hw->modes->rates =3D
 			kzalloc((sizeof(struct ieee80211_rate) * 12),
 			GFP_KERNEL);
=2D		if (!hw->modes->channels)
+		if (!hw->modes->rates)
 			goto exit_free_channels;
 	} else {
 		hw->num_modes =3D 3;
@@ -1950,7 +1950,7 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 		hw->modes->rates =3D
 			kzalloc((sizeof(struct ieee80211_rate) * 12),
 			GFP_KERNEL);
=2D		if (!hw->modes->channels)
+		if (!hw->modes->rates)
 			goto exit_free_channels;
 	}
=20

--nextPart1999205.FEkrRxI0yp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+TaqndE37Em0gRAiUNAKDhcaSMSrShirw5YCKyK3KBN7UypgCfZn6S
uU2db2LwNrL6Q9UMayL2GWg=
=dbdL
-----END PGP SIGNATURE-----

--nextPart1999205.FEkrRxI0yp--
