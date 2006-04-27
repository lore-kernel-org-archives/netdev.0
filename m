From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 11/32] rt2x00: Add more register defines
Date: Fri, 28 Apr 2006 00:03:02 +0200
Message-ID: <200604280003.03004.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1155481.YBtt4Xe03P";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751783AbWD0WB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:58 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:57 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1155481.YBtt4Xe03P
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

During the work on rt2x00 several new registers could be defined.
This will add all those new registers, and will in the next
couple of patches be used.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 21:36:19.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 21:43:27.000000000 +0200
@@ -43,6 +43,13 @@
 #define RF5222				0x0010
=20
 /*
+ * RT2560 version
+ */
+#define RT2560_VERSION_B		2
+#define RT2560_VERSION_C		3
+#define RT2560_VERSION_D		4
+
+/*
  * Control/Status Registers(CSR).
  * Some values are set in TU, whereas 1 TU =3D=3D 1024 us.
  */
@@ -558,15 +565,23 @@
  * Statistic Register.
  * CNT1: PLCP error count.
  * CNT2: Long error count.
=2D * CNT3: CCA false alarm count.
=2D * CNT4: Rx FIFO overflow count.
=2D * CNT5: Tx FIFO underrun count.
  */
 #define TIMECSR2			0x00a8
 #define CNT1				0x00ac
 #define CNT2				0x00b0
 #define TIMECSR3			0x00b4
+
+/*
+ * CNT3: CCA false alarm count.
+ */
 #define CNT3				0x00b8
+#define CNT3_FALSE_CCA			FIELD32(0x0000ffff)
+
+/*
+ * Statistic Register.
+ * CNT4: Rx FIFO overflow count.
+ * CNT5: Tx FIFO underrun count.
+ */
 #define CNT4				0x00bc
 #define CNT5				0x00c0
=20
@@ -840,6 +855,10 @@
  * BBPCSR1: BBP TX configuration.
  */
 #define BBPCSR1				0x015c
+#define BBPCSR1_CCK			FIELD32(0x00000003)
+#define BBPCSR1_CCK_FLIP		FIELD32(0x00000004)
+#define BBPCSR1_OFDM			FIELD32(0x00030000)
+#define BBPCSR1_OFDM_FLIP		FIELD32(0x00040000)
=20
 /*
  * Dual band configuration registers.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:42:29.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:43:27.000000000 +0200
@@ -160,10 +160,28 @@
 #define MAC_CSR19			0x0426
=20
 /*
=2D * LED control registers.
+ * MAC_CSR20: LED control register.
+ * ACTIVITY: 0: idle, 1: active.
+ * LINK: 0: linkoff, 1: linkup.
+ * ACTIVITY_POLARITY: 0: active low, 1: active high.
  */
 #define MAC_CSR20			0x0428
+#define MAC_CSR20_ACTIVITY		FIELD16(0x0001)
+#define MAC_CSR20_LINK			FIELD16(0x0002)
+#define MAC_CSR20_ACTIVITY_POLARITY	FIELD16(0x0004)
+
+/*
+ * MAC_CSR21: LED control register.
+ * ON_PERIOD: On period, default 70ms.
+ * OFF_PERIOD: Off period, default 30ms.
+ */
 #define MAC_CSR21			0x042a
+#define MAC_CSR21_ON_PERIOD		FIELD16(0x00ff)
+#define MAC_CSR21_OFF_PERIOD		FIELD16(0xff00)
+
+/*
+ * Collision window control register.
+ */
 #define MAC_CSR22			0x042c
=20
 /*
@@ -373,10 +391,18 @@
 /*
  * BBP pre-TX registers.
  * PHY_CSR5: BBP pre-TX CCK.
=2D * PHY_CSR6: BBP pre-TX OFDM.
  */
 #define PHY_CSR5			0x04ca
+#define PHY_CSR5_CCK			FIELD16(0x0003)
+#define PHY_CSR5_CCK_FLIP		FIELD16(0x0004)
+
+/*
+ * BBP pre-TX registers.
+ * PHY_CSR6: BBP pre-TX OFDM.
+ */
 #define PHY_CSR6			0x04cc
+#define PHY_CSR6_OFDM			FIELD16(0x0003)
+#define PHY_CSR6_OFDM_FLIP		FIELD16(0x0004)
=20
 /*
  * PHY_CSR7: BBP access register 0.
@@ -459,6 +485,12 @@
  * HW MAC address.
  */
 #define EEPROM_MAC_ADDR			0x0004
+#define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
=20
 /*
  * EEPROM antenna.

--nextPart1155481.YBtt4Xe03P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+WaqndE37Em0gRAstDAKCZjnIlApVbiONtOYujuhHj5eCthACeNdkF
PrwAw43Fk2BiYeKTAaQQZlw=
=mkZ1
-----END PGP SIGNATURE-----

--nextPart1155481.YBtt4Xe03P--
