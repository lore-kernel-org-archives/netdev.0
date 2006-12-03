From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 09/26] rt2x00: USB eeprom offset
Date: Sun, 3 Dec 2006 19:19:03 +0100
Message-ID: <200612031919.03472.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759969AbWLCSTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:32 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:32 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We work with the EEPROM by using the word number
as offset. Fix USB drivers to use the correct offset.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 12:51:02.000000000 +0100
+++ wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 13:00:52.000000000 +0100
@@ -497,13 +497,13 @@
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR_0		0x0004
+#define EEPROM_MAC_ADDR_0		0x0002
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
-#define EEPROM_MAC_ADDR1		0x0006
+#define EEPROM_MAC_ADDR1		0x0003
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
-#define EEPROM_MAC_ADDR_2		0x0008
+#define EEPROM_MAC_ADDR_2		0x0004
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
@@ -517,7 +517,7 @@
  * HARDWARE_RADIO: 1: Hardware controlled radio. Read GPIO0.
  * RF_TYPE: Rf_type of this adapter.
  */
-#define EEPROM_ANTENNA			0x0016
+#define EEPROM_ANTENNA			0x000b
 #define EEPROM_ANTENNA_NUM		FIELD16(0x0003)
 #define EEPROM_ANTENNA_TX_DEFAULT	FIELD16(0x000c)
 #define EEPROM_ANTENNA_RX_DEFAULT	FIELD16(0x0030)
@@ -532,7 +532,7 @@
  * DYN_BBP_TUNE: 0: enable, 1: disable.
  * CCK_TX_POWER: CCK TX power compensation.
  */
-#define EEPROM_NIC			0x0018
+#define EEPROM_NIC			0x000c
 #define EEPROM_NIC_CARDBUS_ACCEL	FIELD16(0x0001)
 #define EEPROM_NIC_DYN_BBP_TUNE		FIELD16(0x0002)
 #define EEPROM_NIC_CCK_TX_POWER		FIELD16(0x000c)
@@ -541,13 +541,13 @@
  * EEPROM geography.
  * GEO: Default geography setting for device.
  */
-#define EEPROM_GEOGRAPHY		0x001a
+#define EEPROM_GEOGRAPHY		0x000d
 #define EEPROM_GEOGRAPHY_GEO		FIELD16(0x0f00)
 
 /*
  * EEPROM BBP.
  */
-#define EEPROM_BBP_START		0x001c
+#define EEPROM_BBP_START		0x0076
 #define EEPROM_BBP_SIZE			16
 #define EEPROM_BBP_VALUE		FIELD16(0x00ff)
 #define EEPROM_BBP_REG_ID		FIELD16(0xff00)
@@ -555,7 +555,7 @@
 /*
  * EEPROM TXPOWER
  */
-#define EEPROM_TXPOWER_START		0x3c
+#define EEPROM_TXPOWER_START		0x001e
 #define EEPROM_TXPOWER_SIZE		7
 #define EEPROM_TXPOWER_1		FIELD16(0x00ff)
 #define EEPROM_TXPOWER_2		FIELD16(0xff00)
@@ -563,7 +563,7 @@
 /*
  * RSSI <-> dBm offset calibration
  */
-#define EEPROM_CALIBRATE_OFFSET		0x36
+#define EEPROM_CALIBRATE_OFFSET		0x0036
 #define EEPROM_CALIBRATE_OFFSET_RSSI	FIELD16(0x00ff)
 
 /*
diff -rU3 wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rssi/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 12:51:34.000000000 +0100
+++ wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 13:01:47.000000000 +0100
@@ -648,13 +648,13 @@
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR_0		0x0004
+#define EEPROM_MAC_ADDR_0		0x0002
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
-#define EEPROM_MAC_ADDR1		0x0006
+#define EEPROM_MAC_ADDR1		0x0003
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
-#define EEPROM_MAC_ADDR_2		0x0008
+#define EEPROM_MAC_ADDR_2		0x0004
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
@@ -668,7 +668,7 @@
  * HARDWARE_RADIO: 1: Hardware controlled radio. Read GPIO0.
  * RF_TYPE: Rf_type of this adapter.
  */
-#define EEPROM_ANTENNA			0x0020
+#define EEPROM_ANTENNA			0x0010
 #define EEPROM_ANTENNA_NUM		FIELD16(0x0003)
 #define EEPROM_ANTENNA_TX_DEFAULT	FIELD16(0x000c)
 #define EEPROM_ANTENNA_RX_DEFAULT	FIELD16(0x0030)
@@ -681,7 +681,7 @@
  * EEPROM NIC config.
  * EXTERNAL_LNA: External LNA.
  */
-#define EEPROM_NIC			0x0022
+#define EEPROM_NIC			0x0011
 #define EEPROM_NIC_EXTERNAL_LNA		FIELD16(0x0010)
 
 /*
@@ -689,14 +689,14 @@
  * GEO_A: Default geographical setting for 5GHz band
  * GEO: Default geographical setting.
  */
-#define EEPROM_GEOGRAPHY		0x0024
+#define EEPROM_GEOGRAPHY		0x0012
 #define EEPROM_GEOGRAPHY_GEO_A		FIELD16(0x00ff)
 #define EEPROM_GEOGRAPHY_GEO		FIELD16(0xff00)
 
 /*
  * EEPROM BBP.
  */
-#define EEPROM_BBP_START		0x0026
+#define EEPROM_BBP_START		0x0013
 #define EEPROM_BBP_SIZE			16
 #define EEPROM_BBP_VALUE		FIELD16(0x00ff)
 #define EEPROM_BBP_REG_ID		FIELD16(0xff00)
@@ -704,7 +704,7 @@
 /*
  * EEPROM TXPOWER 802.11G
  */
-#define EEPROM_TXPOWER_G_START		0x0046
+#define EEPROM_TXPOWER_G_START		0x0023
 #define EEPROM_TXPOWER_G_SIZE		7
 #define EEPROM_TXPOWER_G_1		FIELD16(0x00ff)
 #define EEPROM_TXPOWER_G_2		FIELD16(0xff00)
@@ -712,7 +712,7 @@
 /*
  * EEPROM Frequency
  */
-#define EEPROM_FREQ			0x005e
+#define EEPROM_FREQ			0x002f
 #define EEPROM_FREQ_OFFSET		FIELD16(0x00ff)
 #define EEPROM_FREQ_SEQ_MASK		FIELD16(0xff00)
 #define EEPROM_FREQ_SEQ			FIELD16(0x0300)
@@ -729,7 +729,7 @@
  * POLARITY_GPIO_4: Polarity GPIO4 setting.
  * LED_MODE: Led mode.
  */
-#define EEPROM_LED			0x0060
+#define EEPROM_LED			0x0030
 #define EEPROM_LED_POLARITY_RDY_G	FIELD16(0x0001)
 #define EEPROM_LED_POLARITY_RDY_A	FIELD16(0x0002)
 #define EEPROM_LED_POLARITY_ACT		FIELD16(0x0004)
@@ -743,7 +743,7 @@
 /*
  * EEPROM TXPOWER 802.11A
  */
-#define EEPROM_TXPOWER_A_START		0x0062
+#define EEPROM_TXPOWER_A_START		0x0031
 #define EEPROM_TXPOWER_A_SIZE		12
 #define EEPROM_TXPOWER_A_1		FIELD16(0x00ff)
 #define EEPROM_TXPOWER_A_2		FIELD16(0xff00)
