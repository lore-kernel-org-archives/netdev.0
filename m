From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 14/32] rt2x00: Allocate eeprom memory
Date: Fri, 28 Apr 2006 00:03:05 +0200
Message-ID: <200604280003.06338.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3917718.5sBFN9es2K";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751782AbWD0WCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:03 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:02 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3917718.5sBFN9es2K
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Make the EEPROM array in rt2x00_pci and rt2x00_usb a pointer,
and allocate the memory seperately. This is needed for make
the structures more generic for all rt2x00 pci or usb modules.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:45:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:47:22.000000000 +0200
@@ -1831,7 +1831,6 @@ rt2400pci_init_eeprom(struct rt2x00_pci=20
 	u32			reg;
 	u16			value;
 	u16			eeprom;
=2D	int			counter;
=20
 	/*
 	 * 1 - Detect EEPROM width.
@@ -1886,8 +1885,12 @@ rt2400pci_init_eeprom(struct rt2x00_pci=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
 	 */
+	rt2x00pci->eeprom =3D kzalloc(EEPROM_BBP_SIZE * sizeof(u16), GFP_KERNEL);
+	if (!rt2x00pci->eeprom)=20
+		return -ENOMEM;
+
 	rt2x00_eeprom_multiread(rt2x00pci, EEPROM_BBP_START,
=2D		&rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
+		rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
=20
 	return 0;
 }
@@ -2197,6 +2200,8 @@ rt2400pci_uninitialize(struct net_device
 	del_timer_sync(&rt2x00pci->poll_timer);
 #endif /* CONFIG_RT2400PCI_BUTTON */
=20
+	kfree(rt2x00pci->eeprom);
+
 	if (likely(rt2x00pci->csr_addr)) {
 		iounmap(rt2x00pci->csr_addr);
 		rt2x00pci->csr_addr =3D NULL;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 21:45:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 21:47:22.000000000 +0200
@@ -945,7 +945,7 @@ struct rt2x00_pci{
 	/*
 	 * EEPROM BBP data.
 	 */
=2D	u16					eeprom[EEPROM_BBP_SIZE];
+	u16					*eeprom;
=20
 	/*
 	 * Low level statistics which will have
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:45:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:47:22.000000000 +0200
@@ -1939,7 +1939,6 @@ rt2500pci_init_eeprom(struct rt2x00_pci=20
 	u32			reg;
 	u16			value;
 	u16			eeprom;
=2D	int			counter;
=20
 	/*
 	 * 1 - Detect EEPROM width.
@@ -1998,8 +1997,12 @@ rt2500pci_init_eeprom(struct rt2x00_pci=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
 	 */
+	rt2x00pci->eeprom =3D kzalloc(EEPROM_BBP_SIZE * sizeof(u16), GFP_KERNEL);
+	if (!rt2x00pci->eeprom)
+		return -ENOMEM;
+
 	rt2x00_eeprom_multiread(rt2x00pci, EEPROM_BBP_START,
=2D		&rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
+		rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
=20
 	return 0;
 }
@@ -2495,6 +2498,8 @@ rt2500pci_uninitialize(struct net_device
 	del_timer_sync(&rt2x00pci->poll_timer);
 #endif /* CONFIG_RT2500PCI_BUTTON */
=20
+	kfree(rt2x00pci->eeprom);
+
 	if (likely(rt2x00pci->csr_addr)) {
 		iounmap(rt2x00pci->csr_addr);
 		rt2x00pci->csr_addr =3D NULL;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 21:43:27.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 21:47:22.000000000 +0200
@@ -1215,7 +1215,7 @@ struct rt2x00_pci{
 	/*
 	 * EEPROM BBP data.
 	 */
=2D	u16					eeprom[EEPROM_BBP_SIZE];
+	u16					*eeprom;
=20
 	/*
 	 * Low level statistics which will have
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:45:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:47:22.000000000 +0200
@@ -1657,9 +1657,12 @@ rt2500usb_init_eeprom(struct rt2x00_usb=20
 	/*
 	 * 5 - Read BBP data from EEPROM and store in private structure.
 	 */
=2D	memset(&rt2x00usb->eeprom, 0x00, sizeof(rt2x00usb->eeprom));
+	rt2x00usb->eeprom =3D kzalloc(EEPROM_BBP_SIZE * sizeof(u16), GFP_KERNEL);
+	if (!rt2x00usb->eeprom)=20
+		return -ENOMEM;
+
 	rt2x00_eeprom_multiread(rt2x00usb, EEPROM_BBP_START,
=2D		&rt2x00usb->eeprom[0], EEPROM_BBP_SIZE);
+		rt2x00usb->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
=20
 	return 0;
 }
@@ -2116,6 +2119,8 @@ rt2500usb_uninitialize(struct net_device
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=20
+	kfree(rt2x00usb->eeprom);
+
 	if (rt2x00usb->scan) {
 		rt2x00usb->scan->cancelled =3D 1;
 		complete_all(&rt2x00usb->scan->completion);
@@ -2129,7 +2134,7 @@ rt2500usb_uninitialize(struct net_device
=20
 		kfree(rt2x00usb->hw.modes);
 		rt2x00usb->hw.modes =3D NULL;
=2D	}
+}
=20
 /*
  * USB driver handlers.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:43:27.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:47:22.000000000 +0200
@@ -727,7 +727,7 @@ struct rt2x00_usb{
 	/*
 	 * EEPROM BBP data.
 	 */
=2D	u16					eeprom[EEPROM_BBP_SIZE];
+	u16					*eeprom;
=20
 	/*
 	 * Low level statistics which will have

--nextPart3917718.5sBFN9es2K
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+aaqndE37Em0gRAvRxAKCECJgztt5T31feFX0rfPWNn31AlQCeKzDC
No3SFzJp2hK/6X/sJ2HOIgQ=
=t5RQ
-----END PGP SIGNATURE-----

--nextPart3917718.5sBFN9es2K--
