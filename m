From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 4/32] rt2x00: Add eeprom_multiread function
Date: Fri, 28 Apr 2006 00:02:53 +0200
Message-ID: <200604280002.54192.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1922538.3lmZrnSWfz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751778AbWD0WBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:46 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:46 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1922538.3lmZrnSWfz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Add the eeprom_multiread function and clean up the code
a bit by using it as well. ;)

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:37:02.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:38:23.000000000 +0200
@@ -351,6 +351,17 @@ rt2x00_eeprom_read(
 	rt2x00_eeprom_pulse_low(rt2x00pci, &flags);
 }
=20
+static void
+rt2x00_eeprom_multiread(
+	const struct rt2x00_pci *rt2x00pci,
+	const u8 word, u16 *data, const u16 length)
+{
+	int			counter;
+
+	for (counter =3D 0; counter < (length / sizeof(u16)); counter++)
+		rt2x00_eeprom_read(rt2x00pci, word + counter, data++);
+}
+
 /*
  * Configuration handlers.
  */
@@ -1824,9 +1835,8 @@ rt2400pci_init_eeprom(struct rt2x00_pci=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
 	 */
=2D	for (counter =3D 0; counter < EEPROM_BBP_SIZE; counter++)
=2D		rt2x00_eeprom_read(rt2x00pci, EEPROM_BBP_START + counter,
=2D			&rt2x00pci->eeprom[counter]);
+	rt2x00_eeprom_multiread(rt2x00pci, EEPROM_BBP_START,
+		&rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
=20
 	return 0;
 }
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:37:02.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:38:23.000000000 +0200
@@ -351,6 +351,17 @@ rt2x00_eeprom_read(
 	rt2x00_eeprom_pulse_low(rt2x00pci, &flags);
 }
=20
+static void
+rt2x00_eeprom_multiread(
+	const struct rt2x00_pci *rt2x00pci,
+	const u8 word, u16 *data, const u16 length)
+{
+	int			counter;
+
+	for (counter =3D 0; counter < (length / sizeof(u16)); counter++)
+		rt2x00_eeprom_read(rt2x00pci, word + counter, data++);
+}
+
 /*
  * Configuration handlers.
  */
@@ -1886,9 +1897,8 @@ rt2500pci_init_eeprom(struct rt2x00_pci=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
 	 */
=2D	for (counter =3D 0; counter < EEPROM_BBP_SIZE; counter++)
=2D		rt2x00_eeprom_read(rt2x00pci, EEPROM_BBP_START + counter,
=2D			&rt2x00pci->eeprom[counter]);
+	rt2x00_eeprom_multiread(rt2x00pci, EEPROM_BBP_START,
+		&rt2x00pci->eeprom, EEPROM_BBP_SIZE * sizeof(u16));
=20
 	return 0;
 }
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:36:17.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:38:23.000000000 +0200
@@ -228,11 +228,21 @@ rf_write:
 static inline void
 rt2x00_eeprom_read(
 	const struct rt2x00_usb *rt2x00usb,
=2D	const u16 offset, u16 *value, const u16 length)
+	const u16 word, u16 *data)
 {
 	rt2x00_vendor_request(
 		rt2x00usb, USB_EEPROM_READ, USB_VENDOR_REQUEST_IN,
=2D		offset, 0x00, value, length);
+		word, 0x00, data, 2);
+}
+
+static void
+rt2x00_eeprom_multiread(
+	const struct rt2x00_usb *rt2x00usb,
+	const u8 word, u16 *data, const u16 length)
+{
+	rt2x00_vendor_request(
+		rt2x00usb, USB_EEPROM_READ, USB_VENDOR_REQUEST_IN,
+		word, 0x00, data, length);
 }
=20
 /*
@@ -1552,7 +1562,7 @@ rt2500usb_init_eeprom(struct rt2x00_usb=20
 	/*
 	 * 1 - Read EEPROM word for configuration.
 	 */
=2D	rt2x00_eeprom_read(rt2x00usb, EEPROM_ANTENNA, &eeprom, 2);
+	rt2x00_eeprom_read(rt2x00usb, EEPROM_ANTENNA, &eeprom);
=20
 	/*
 	 * 2 - Identify RF chipset.
@@ -1579,7 +1589,7 @@ rt2500usb_init_eeprom(struct rt2x00_usb=20
 	 * 5 - Read BBP data from EEPROM and store in private structure.
 	 */
 	memset(&rt2x00usb->eeprom, 0x00, sizeof(rt2x00usb->eeprom));
=2D	rt2x00_eeprom_read(rt2x00usb, EEPROM_BBP_START,
+	rt2x00_eeprom_multiread(rt2x00usb, EEPROM_BBP_START,
 		&rt2x00usb->eeprom[0], EEPROM_BBP_SIZE);
=20
 	return 0;
@@ -1595,7 +1605,7 @@ rt2500usb_init_mac(struct rt2x00_usb *rt
 	/*
 	 * Read MAC address from EEPROM.
 	 */
=2D	rt2x00_eeprom_read(rt2x00usb, EEPROM_MAC_ADDR, &reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00usb, EEPROM_MAC_ADDR, &reg[0], 6);
=20
 	net_dev->dev_addr[0] =3D rt2x00_get_field16(reg[0], MAC_CSR2_BYTE0);
 	net_dev->dev_addr[1] =3D rt2x00_get_field16(reg[0], MAC_CSR2_BYTE1);
@@ -1733,7 +1743,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		 */
 	for (counter =3D 0; counter < EEPROM_TXPOWER_SIZE; counter++) {
 		rt2x00_eeprom_read(rt2x00usb,
=2D			EEPROM_TXPOWER_START + counter, &eeprom, 2);
+			EEPROM_TXPOWER_START + counter, &eeprom);
=20
 		channels[(counter * 2)].power_level =3D
 			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1);

--nextPart1922538.3lmZrnSWfz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+OaqndE37Em0gRAs6WAJ9HuqCd5bjrjOASyePbuRCc7FO2cQCZAc7/
cmXzNSEPJrmwQOPnidGFO3s=
=kISL
-----END PGP SIGNATURE-----

--nextPart1922538.3lmZrnSWfz--
