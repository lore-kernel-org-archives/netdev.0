From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 18/26] rt2x00: Simplify MAC copying
Date: Sun, 3 Dec 2006 19:18:59 +0100
Message-ID: <200612031918.59614.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758834AbWLCSTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:25 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:24 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No set_field commands are required for the mac registers.
This was previously done for the byteordering.
But since the MAC is already read in the correct byteorder
this had never had to happen at all anyway.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:19:54.000000000 +0100
+++ wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:45:46.000000000 +0100
@@ -605,13 +605,11 @@
 {
 	u32 reg[2] = { 0, 0 };
 
-	rt2x00_set_field32(&reg[0], CSR3_BYTE0, ((u8*)addr)[0]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE1, ((u8*)addr)[1]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE2, ((u8*)addr)[2]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE3, ((u8*)addr)[3]);
-	rt2x00_set_field32(&reg[1], CSR4_BYTE4, ((u8*)addr)[4]);
-	rt2x00_set_field32(&reg[1], CSR4_BYTE5, ((u8*)addr)[5]);
-
+	/*
+	 * The MAC address is passed to us as an array of bytes,
+	 * that array is little endian, so no need for byte ordering.
+	 */
+	memcpy(&reg, addr, ETH_ALEN);
 	rt2x00_register_multiwrite(rt2x00dev, CSR3, &reg[0], sizeof(reg));
 }
 
diff -rU3 wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:21:13.000000000 +0100
+++ wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:46:09.000000000 +0100
@@ -679,13 +679,11 @@
 {
 	u32 reg[2] = { 0, 0 };
 
-	rt2x00_set_field32(&reg[0], CSR3_BYTE0, ((u8*)addr)[0]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE1, ((u8*)addr)[1]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE2, ((u8*)addr)[2]);
-	rt2x00_set_field32(&reg[0], CSR3_BYTE3, ((u8*)addr)[3]);
-	rt2x00_set_field32(&reg[1], CSR4_BYTE4, ((u8*)addr)[4]);
-	rt2x00_set_field32(&reg[1], CSR4_BYTE5, ((u8*)addr)[5]);
-
+	/*
+	 * The MAC address is passed to us as an array of bytes,
+	 * that array is little endian, so no need for byte ordering.
+	 */
+	memcpy(&reg, addr, ETH_ALEN);
 	rt2x00_register_multiwrite(rt2x00dev, CSR3, &reg[0], sizeof(reg));
 }
 
diff -rU3 wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:36:31.000000000 +0100
+++ wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:46:19.000000000 +0100
@@ -709,13 +709,11 @@
 {
 	u16 reg[3] = { 0, 0, 0 };
 
-	rt2x00_set_field16(&reg[0], MAC_CSR2_BYTE0, ((u8*)addr)[0]);
-	rt2x00_set_field16(&reg[0], MAC_CSR2_BYTE1, ((u8*)addr)[1]);
-	rt2x00_set_field16(&reg[1], MAC_CSR3_BYTE2, ((u8*)addr)[2]);
-	rt2x00_set_field16(&reg[1], MAC_CSR3_BYTE3, ((u8*)addr)[3]);
-	rt2x00_set_field16(&reg[2], MAC_CSR4_BYTE4, ((u8*)addr)[4]);
-	rt2x00_set_field16(&reg[2], MAC_CSR4_BYTE5, ((u8*)addr)[5]);
-
+	/*
+	 * The MAC address is passed to us as an array of bytes,
+	 * that array is little endian, so no need for byte ordering.
+	 */
+	memcpy(&reg, addr, ETH_ALEN);
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR2, &reg[0], sizeof(reg));
 }
 
diff -rU3 wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:22:40.000000000 +0100
+++ wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:46:31.000000000 +0100
@@ -910,14 +910,14 @@
 {
 	u32 reg[2] = { 0, 0 };
 
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE0, ((u8*)addr)[0]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE1, ((u8*)addr)[1]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE2, ((u8*)addr)[2]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE3, ((u8*)addr)[3]);
-	rt2x00_set_field32(&reg[1], MAC_CSR3_BYTE4, ((u8*)addr)[4]);
-	rt2x00_set_field32(&reg[1], MAC_CSR3_BYTE5, ((u8*)addr)[5]);
+	/*
+	 * The MAC address is passed to us as an array of bytes,
+	 * that array is little endian, so no need for byte ordering.
+	 * We only need to set the MAC_CSR3_UNICAST_TO_ME_MASK
+	 * at the correct offset.
+	 */
+	memcpy(&reg, addr, ETH_ALEN);
 	rt2x00_set_field32(&reg[1], MAC_CSR3_UNICAST_TO_ME_MASK, 0xff);
-
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR2, &reg[0], sizeof(reg));
 }
 
diff -rU3 wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-vendor/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:37:02.000000000 +0100
+++ wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:46:42.000000000 +0100
@@ -808,14 +808,14 @@
 {
 	u32 reg[2] = { 0, 0 };
 
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE0, ((u8*)addr)[0]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE1, ((u8*)addr)[1]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE2, ((u8*)addr)[2]);
-	rt2x00_set_field32(&reg[0], MAC_CSR2_BYTE3, ((u8*)addr)[3]);
-	rt2x00_set_field32(&reg[1], MAC_CSR3_BYTE4, ((u8*)addr)[4]);
-	rt2x00_set_field32(&reg[1], MAC_CSR3_BYTE5, ((u8*)addr)[5]);
+	/*
+	 * The MAC address is passed to us as an array of bytes,
+	 * that array is little endian, so no need for byte ordering.
+	 * We only need to set the MAC_CSR3_UNICAST_TO_ME_MASK
+	 * at the correct offset.
+	 */
+	memcpy(&reg, addr, ETH_ALEN);
 	rt2x00_set_field32(&reg[1], MAC_CSR3_UNICAST_TO_ME_MASK, 0xff);
-
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR2, &reg[0], sizeof(reg));
 }
 
