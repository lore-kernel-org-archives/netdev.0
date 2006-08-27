From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 10/10] rt2x00: Misc fixes
Date: Sun, 27 Aug 2006 17:39:16 +0200
Message-ID: <200608271739.16414.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42540 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932147AbWH0Pj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:29 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091663nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:28 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EEPROM_SIZE should be a value dividable by sizeof(u16)
CSR_REG_SIZE should be dividable by sizeof(u32)

In USB adapters the eeprom offset is in bytes and not words.

Short slot time is 9 instead of 7

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-27 17:05:50.000000000 +0200
@@ -44,7 +44,7 @@
 #define CSR_REG_BASE			0x0000
 #define CSR_REG_SIZE			0x014c
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * Control/Status Registers(CSR).
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-27 17:06:13.000000000 +0200
@@ -55,7 +55,7 @@
 #define CSR_REG_BASE			0x0000
 #define CSR_REG_SIZE			0x0174
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x01ff
+#define EEPROM_SIZE			0x0200
 
 /*
  * Control/Status Registers(CSR).
@@ -542,7 +542,7 @@
  */
 
 /*
- * PCISR: PCI control register.
+ * PCICSR: PCI control register.
  * BIG_ENDIAN: 1: big endian, 0: little endian.
  * RX_TRESHOLD: Rx threshold in dw to start pci access
  * 0: 16dw (default), 1: 8dw, 2: 4dw, 3: 32dw.
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 17:01:39.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 17:06:31.000000000 +0200
@@ -270,7 +270,7 @@
 	eeprom->magic = 0xbad;
 
 	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+		eeprom->offset, (void*)data, eeprom->len);
 
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-27 17:01:39.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-27 17:06:31.000000000 +0200
@@ -46,7 +46,7 @@
  * Register layout information.
  */
 #define CSR_REG_BASE			0x0400
-#define CSR_REG_SIZE			0x00ff
+#define CSR_REG_SIZE			0x0100
 #define EEPROM_BASE			0x0000
 #define EEPROM_SIZE			0x006a
 
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-27 15:57:39.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-27 17:07:00.000000000 +0200
@@ -117,7 +117,7 @@
 #define PREAMBLE		144
 #define SHORT_PREAMBLE		72
 #define SLOT_TIME		20
-#define SHORT_SLOT_TIME		7
+#define SHORT_SLOT_TIME		9
 
 /*
  * TX result flags.
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-27 17:07:13.000000000 +0200
@@ -48,7 +48,7 @@
 #define CSR_REG_BASE			0x3000
 #define CSR_REG_SIZE			0x04b0
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * PCI registers.
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 17:03:19.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 17:07:32.000000000 +0200
@@ -271,7 +271,7 @@
 	eeprom->magic = 0xbad;
 
 	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+		eeprom->offset, (void*)data, eeprom->len);
 
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rt2x00-txd/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-27 17:07:41.000000000 +0200
@@ -46,7 +46,7 @@
 #define CSR_REG_BASE			0x3000
 #define CSR_REG_SIZE			0x04b0
 #define EEPROM_BASE			0x0000
-#define EEPROM_SIZE			0x00ff
+#define EEPROM_SIZE			0x0100
 
 /*
  * USB registers.
