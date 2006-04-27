From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 21/32] rt2x00: PRIO ring should be treated as regular TX ring
Date: Fri, 28 Apr 2006 00:03:13 +0200
Message-ID: <200604280003.13578.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart18492556.Ii7SUMroOz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751784AbWD0WCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:14 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:13 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart18492556.Ii7SUMroOz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Remove PRIO_ENTRIES define, the prio ring
should be treated as a regular TX ring.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:50:36.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:52:01.000000000 +0200
@@ -1145,7 +1145,7 @@ rt2400pci_allocate_rings(struct rt2x00_p
 		ATIM_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))
 	|| rt2400pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->prio, rt2400pci_txdone,
=2D		PRIO_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
+		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2400pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->beacon, rt2400pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:51:11.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:52:01.000000000 +0200
@@ -1227,7 +1227,7 @@ rt2500pci_allocate_rings(struct rt2x00_p
 		ATIM_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->prio, rt2500pci_txdone,
=2D		PRIO_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
+		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->beacon, rt2500pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:51:11.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:52:01.000000000 +0200
@@ -996,7 +996,7 @@ rt2500usb_allocate_rings(struct rt2x00_u
 		ATIM_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500usb_alloc_ring(
 		rt2x00usb, &rt2x00usb->prio, &rt2500usb_txdone,
=2D		PRIO_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
+		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500usb_alloc_ring(
 		rt2x00usb, &rt2x00usb->beacon, &rt2500usb_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:49:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:52:01.000000000 +0200
@@ -90,7 +90,6 @@ static int rt2x00_debug_level =3D 0;
 #define RX_ENTRIES			12
 #define TX_ENTRIES			12
 #define ATIM_ENTRIES			1
=2D#define PRIO_ENTRIES			6
 #define BEACON_ENTRIES			1
=20
 /*

--nextPart18492556.Ii7SUMroOz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+haqndE37Em0gRAvteAJ9N7Wipywz+/11E1RDCM7pAoe8a2wCfexmQ
ghHrFb17Hz+Lab8Hx8B66i0=
=vsVQ
-----END PGP SIGNATURE-----

--nextPart18492556.Ii7SUMroOz--
