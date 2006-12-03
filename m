From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 25/26] rt2x00: Compile fixes
Date: Sun, 3 Dec 2006 19:18:55 +0100
Message-ID: <200612031918.56119.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758793AbWLCSTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:13 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:12 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As usual, when I make a large patch series,
I overlook important bits...
This will fix all issues that have arisen from this
patch series.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:48:55.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:56:14.000000000 +0100
@@ -1959,6 +1959,7 @@
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00_desc_addr(entry);
+	rt2x00_desc_read(txd, 0, &word);
 
 	if (rt2x00_get_field32(word, TXD_W0_OWNER_NIC) ||
 	    rt2x00_get_field32(word, TXD_W0_VALID)) {
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:48:36.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:52:39.000000000 +0100
@@ -1746,6 +1746,7 @@
 	struct data_desc *txd;
 	struct urb *urb;
 	u32 word;
+	int tx_status;
 	int ack;
 	int rts;
 
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 15:08:28.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 15:53:13.000000000 +0100
@@ -270,11 +270,14 @@
 #define TXRX_CSR9			0x0452
 
 /*
- * Auto responder registers.
  * TXRX_CSR10: Auto responder control.
- * TXRX_CSR11: Auto responder basic rate.
  */
 #define TXRX_CSR10			0x0454
+#define TXRX_CSR10_AUTORESPOND_PREAMBLE FIELD16(0x0004)
+
+/*
+ * TXRX_CSR11: Auto responder basic rate.
+ */
 #define TXRX_CSR11			0x0456
 
 /*
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 15:44:04.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 15:56:43.000000000 +0100
@@ -174,6 +174,23 @@
 };
 
 /*
+ * Cipher types for hardware encryption
+ */
+enum cipher {
+	CIPHER_NONE = 0,
+	CIPHER_WEP64 = 1,
+	CIPHER_WEP128 = 2,
+	CIPHER_TKIP = 3,
+	CIPHER_AES = 4,
+/*
+ * The following fields were added by rt61pci and rt73usb.
+ */
+	CIPHER_CKIP64 = 5,
+	CIPHER_CKIP128 = 6,
+	CIPHER_TKIP_NO_MIC = 7,
+};
+
+/*
  * Macros for determining which is the lowest or highest bit
  * set in a 16 or 32 bit variable.
  */
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-12-03 15:53:59.000000000 +0100
@@ -37,11 +37,8 @@
 #define REGISTER_BUSY_DELAY	100
 
 /*
- * EEPROM operation defines.
+ * Link tuning at 1 second intervals
  */
-#define EEPROM_WIDTH_93C46	6
-#define EEPROM_WIDTH_93C66	8
-#define EEPROM_WRITE_OPCODE	0x05
-#define EEPROM_READ_OPCODE	0x06
+#define LINK_TUNE_INTERVAL	( 1 * HZ )
 
 #endif /* RT2X00PCI_H */
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	2006-12-03 14:30:31.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	2006-12-03 15:54:08.000000000 +0100
@@ -73,4 +73,9 @@
 #define USB_MODE_FIRMWARE	0x08	/* RT73USB */
 #define USB_MODE_WAKEUP		0x09	/* RT73USB */
 
+/*
+ * Link tuning at 1 second intervals
+ */
+#define LINK_TUNE_INTERVAL	( 1 * HZ )
+
 #endif /* RT2X00USB_H */
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:48:35.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:57:55.000000000 +0100
@@ -2281,8 +2281,7 @@
 	 * we must make sure the packet queue in the d80211 stack
 	 * is reenabled when the txdone handler has finished.
 	 */
-	entry = ring->entry;
-	if (!rt2x00_ring_full(ring))
+	if (!rt2x00_ring_full(entry->ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
@@ -2456,6 +2455,7 @@
 
 	entry = rt2x00_get_data_entry(ring);
 	txd = rt2x00_desc_addr(entry);
+	rt2x00_desc_read(txd, 0, &word);
 
 	if (rt2x00_get_field32(word, TXD_W0_OWNER_NIC) ||
 	    rt2x00_get_field32(word, TXD_W0_VALID)) {
@@ -3329,7 +3329,7 @@
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5325)) {
-		for (; i < EEPROM_TXPOWER_A_SIZE; i++) {
+		for (i = 0; i < EEPROM_TXPOWER_A_SIZE; i++) {
 			rt2x00_eeprom_read(rt2x00dev,
 				EEPROM_TXPOWER_A_START + i, &eeprom);
 
diff -rU3 wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:48:35.000000000 +0100
+++ wireless-dev-compile/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:57:59.000000000 +0100
@@ -2018,6 +2018,7 @@
 	struct data_desc *txd;
 	struct urb *urb;
 	u32 word;
+	int tx_status;
 	int ack;
 	int rts;
 
@@ -2974,7 +2975,7 @@
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5226)) {
-		for (; i < EEPROM_TXPOWER_A_SIZE; i++) {
+		for (i = 0; i < EEPROM_TXPOWER_A_SIZE; i++) {
 			rt2x00_eeprom_read(rt2x00dev,
 				EEPROM_TXPOWER_A_START + i, &eeprom);
 
