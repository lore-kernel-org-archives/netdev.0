From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 5/32] rt2x00: Optimize RATE flag handling
Date: Fri, 28 Apr 2006 00:02:55 +0200
Message-ID: <200604280002.55541.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1170669.EXRAdqD2kT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751780AbWD0WBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:48 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:47 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1170669.EXRAdqD2kT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Optimize RATE flags by using the FIELD32() macro's,
also make the unit in which the rate is handled the
same as is used in the dscape stack.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:38:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:39:24.000000000 +0200
@@ -550,7 +550,7 @@ rt2400pci_config_duration(struct rt2x00_
 	rt2x00_register_read(rt2x00pci, CSR19, &reg);
 	value =3D SIFS + (2 * short_slot_time);
 	rt2x00_set_field32(&reg, CSR19_DIFS, value);
=2D	value =3D SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 2);
+	value =3D SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, CSR19_EIFS, value);
 	rt2x00_register_write(rt2x00pci, CSR19, reg);
=20
@@ -580,11 +580,11 @@ rt2400pci_config_rate(struct rt2x00_pci=20
 	value =3D SIFS + PLCP
 		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
=2D		+ get_duration(ACK_SIZE, 2);
+		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
 	value =3D SIFS + PLCP
 		+ preamble
=2D		+ get_duration(ACK_SIZE, 2);
+		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00pci, TXCSR1, reg[0]);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:38:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:39:24.000000000 +0200
@@ -565,7 +565,7 @@ rt2500pci_config_duration(struct rt2x00_
 	rt2x00_register_read(rt2x00pci, CSR19, &reg);
 	value =3D SIFS + (2 * short_slot_time);
 	rt2x00_set_field32(&reg, CSR19_DIFS, value);
=2D	value =3D SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 2);
+	value =3D SIFS + get_duration(IEEE80211_HEADER + ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, CSR19_EIFS, value);
 	rt2x00_register_write(rt2x00pci, CSR19, reg);
=20
@@ -595,11 +595,11 @@ rt2500pci_config_rate(struct rt2x00_pci=20
 	value =3D SIFS + PLCP
 		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
=2D		+ get_duration(ACK_SIZE, 2);
+		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
 	value =3D SIFS + PLCP
 		+ preamble
=2D		+ get_duration(ACK_SIZE, 2);
+		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_CONSUME_TIME, value);
 	rt2x00_register_write(rt2x00pci, TXCSR1, reg[0]);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:38:23.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:39:24.000000000 +0200
@@ -467,7 +467,7 @@ rt2500usb_config_rate(struct rt2x00_usb=20
 	value =3D SIFS + PLCP
 		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
=2D		+ get_duration(ACK_SIZE, 2);
+		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field16_nb(&reg, TXRX_CSR1_ACK_TIMEOUT, value);
 	rt2x00_register_write(rt2x00usb, TXRX_CSR1, reg);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:36:19.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:39:24.000000000 +0200
@@ -609,71 +609,69 @@ struct scanning{
  * passed to the ieee80211 kernel. We need to make it a consist of
  * multiple fields because we want to store more then 1 device specific
  * values inside the value.
=2D *	1 - rate, stored as 0.5Mbit/s.
=2D *	2 - MASK_RATE, which rates are enabled in this mode, this mask
+ *	1 - rate, stored as 100 kbit/s.
+ *	2 - preamble, short_preamble enabled flag.
+ *	3 - MASK_RATE, which rates are enabled in this mode, this mask
  *	corresponds with the TX register format for the current device.
=2D *	3 - plcp, 802.11b rates are device specific,
+ *	4 - plcp, 802.11b rates are device specific,
  *	802.11g rates are set according to the ieee802.11a-1999 p.14.
=2D *	4 - preamble, short_preamble enabled flag.
  * The bit to enable preamble is set in a seperate define.
  */
=2D#define OFFSET_RATE			0
=2D#define MASK_RATE			0x000000ff
=2D#define OFFSET_RATEMASK			8
=2D#define MASK_RATEMASK			0x00000fff
=2D#define OFFSET_PLCP			20
=2D#define MASK_PLCP			0x000000ff
=2D#define OFFSET_PREAMBLE			28
=2D#define MASK_PREAMBLE			0x000000ff
+#define DEV_RATE			FIELD32(0x000007ff)
+#define DEV_PREAMBLE			FIELD32(0x00000800)
+#define DEV_RATEMASK			FIELD32(0x00fff000)
+#define DEV_PLCP			FIELD32(0xff000000)
=20
 /*
=2D * Macro to set or get a field in the device
=2D * specific value.
+ * Macro's for creating the device specific rate value.
  */
 #define DEVICE_RATE_VALUE(__rate, __mask, __plcp) \
=2D	(int)( (__rate) << OFFSET_RATE \
=2D	| (__mask) << OFFSET_RATEMASK \
=2D	| (__plcp) << OFFSET_PLCP )
+	(int) ((((__rate) << DEV_RATE.bit_offset) & DEV_RATE.bit_mask) \
+	| (((__mask) << DEV_RATEMASK.bit_offset) & DEV_RATEMASK.bit_mask) \
+	| (((__plcp) << DEV_PLCP.bit_offset) & DEV_PLCP.bit_mask) )
=20
 #define DEVICE_RATE_PREAMBLE(__value) \
=2D	(int)( (__value) | 1 << OFFSET_PREAMBLE )
+	(int)( (__value) | (1 << DEV_PREAMBLE.bit_offset) )
=20
+/*
+ * Macro for reading the device specific rate value.
+ */
 #define DEVICE_RATE_FIELD(__value, __mask) \
=2D	(int)( ((__value) >> OFFSET_##__mask) & MASK_##__mask )
+	(int)( ((__value) & DEV_##__mask.bit_mask) >> DEV_##__mask.bit_offset)
=20
=2D#define DEVICE_RATE_1MB			DEVICE_RATE_VALUE(2, 0x001, 0x00)
=2D#define DEVICE_RATE_2MB			DEVICE_RATE_VALUE(4, 0x003, 0x01)
+#define DEVICE_RATE_1MB			DEVICE_RATE_VALUE(10, 0x001, 0x00)
+#define DEVICE_RATE_2MB			DEVICE_RATE_VALUE(20, 0x003, 0x01)
 #define DEVICE_RATE_2MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_2MB)
=2D#define DEVICE_RATE_55MB		DEVICE_RATE_VALUE(11, 0x007, 0x02)
+#define DEVICE_RATE_55MB		DEVICE_RATE_VALUE(55, 0x007, 0x02)
 #define DEVICE_RATE_55MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_55MB)
=2D#define DEVICE_RATE_11MB		DEVICE_RATE_VALUE(22, 0x00f, 0x03)
+#define DEVICE_RATE_11MB		DEVICE_RATE_VALUE(110, 0x00f, 0x03)
 #define DEVICE_RATE_11MB_PREAMBLE	DEVICE_RATE_PREAMBLE(DEVICE_RATE_11MB)
=2D#define DEVICE_RATE_6MB			DEVICE_RATE_VALUE(12, 0x01f, 0x0b)
=2D#define DEVICE_RATE_9MB			DEVICE_RATE_VALUE(18, 0x03f, 0x0f)
=2D#define DEVICE_RATE_12MB		DEVICE_RATE_VALUE(24, 0x07f, 0x0a)
=2D#define DEVICE_RATE_18MB		DEVICE_RATE_VALUE(36, 0x0ff, 0x0e)
=2D#define DEVICE_RATE_24MB		DEVICE_RATE_VALUE(48, 0x1ff, 0x09)
=2D#define DEVICE_RATE_36MB		DEVICE_RATE_VALUE(72, 0x3ff, 0x0d)
=2D#define DEVICE_RATE_48MB		DEVICE_RATE_VALUE(96, 0x7ff, 0x08)
=2D#define DEVICE_RATE_54MB		DEVICE_RATE_VALUE(108, 0xfff, 0x0c)
+#define DEVICE_RATE_6MB			DEVICE_RATE_VALUE(60, 0x01f, 0x0b)
+#define DEVICE_RATE_9MB			DEVICE_RATE_VALUE(90, 0x03f, 0x0f)
+#define DEVICE_RATE_12MB		DEVICE_RATE_VALUE(120, 0x07f, 0x0a)
+#define DEVICE_RATE_18MB		DEVICE_RATE_VALUE(180, 0x0ff, 0x0e)
+#define DEVICE_RATE_24MB		DEVICE_RATE_VALUE(240, 0x1ff, 0x09)
+#define DEVICE_RATE_36MB		DEVICE_RATE_VALUE(360, 0x3ff, 0x0d)
+#define DEVICE_RATE_48MB		DEVICE_RATE_VALUE(480, 0x7ff, 0x08)
+#define DEVICE_RATE_54MB		DEVICE_RATE_VALUE(540, 0xfff, 0x0c)
=20
 /*
  * Duration calculations
=2D * The rate variable passed is: 0.5MBs.
+ * The rate variable passed is: 100kbs.
  * To convert from bytes to bits we multiply size with 8,
=2D * then the size is multiplied with 2 to make the
+ * then the size is multiplied with 10 to make the
  * real rate -> rate argument correction.
  */
 static inline u16
 get_duration(const unsigned int size, const u8 rate)
 {
=2D	return ((size * 8 * 2) / rate);
+	return ((size * 8 * 10) / rate);
 }
=20
 static inline u16
 get_duration_res(const unsigned int size, const u8 rate)
 {
=2D	return ((size * 8 * 2) % rate);
+	return ((size * 8 * 10) % rate);
 }
=20
 #define ACK_SIZE			14

--nextPart1170669.EXRAdqD2kT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+PaqndE37Em0gRAmpBAJ9We5li/B2/M4gzIMfqJEA6ve//TQCeJGSR
8W2XgvuuDop0qhmQYRqv8II=
=Xe9T
-----END PGP SIGNATURE-----

--nextPart1170669.EXRAdqD2kT--
