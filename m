From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 5/10] rt2x00: Register initialization fixes
Date: Sun, 27 Aug 2006 17:39:14 +0200
Message-ID: <200608271739.14166.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46123 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932137AbWH0PjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:23 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091661nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various register initialization fixes to make the device work properly.
This will fix the RX/TX issue for rt61pci.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:11:40.000000000 +0200
+++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:17:02.000000000 +0200
@@ -1192,11 +1192,7 @@
 	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
 
 	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00217223));
-
-	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
-	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
+	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
 
 	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
 	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:12:03.000000000 +0200
+++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:17:56.000000000 +0200
@@ -1249,6 +1249,7 @@
 		return -EBUSY;
 
 	rt2x00_register_write(rt2x00dev, PWRCSR0, cpu_to_le32(0x3f3b3100));
+	rt2x00_register_write(rt2x00dev, PCICSR, cpu_to_le32(0x000003b8));
 
 	rt2x00_register_write(rt2x00dev, PSCSR0, cpu_to_le32(0x00020002));
 	rt2x00_register_write(rt2x00dev, PSCSR1, cpu_to_le32(0x00000002));
@@ -1272,12 +1273,11 @@
 	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
 
-	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
+	rt2x00_register_write(rt2x00dev, GPIOCSR, cpu_to_le32(0x0000ff00));
+	rt2x00_register_write(rt2x00dev, TESTCSR, cpu_to_le32(0x000000f0));
 
-	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
-	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
-	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
+	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
+	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
 
 	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
 	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:12:24.000000000 +0200
+++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:19:04.000000000 +0200
@@ -630,15 +630,9 @@
 static void rt2500usb_config_duration(struct rt2x00_dev *rt2x00dev,
 	int short_slot_time)
 {
-	u16 reg;
-
 	short_slot_time = short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME;
 
 	rt2x00_register_write(rt2x00dev, MAC_CSR10, (u16)short_slot_time);
-
-	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
-	rt2x00_set_field16_nb(&reg, TXRX_CSR1_TSF_OFFSET, IEEE80211_HEADER);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR1, reg);
 }
 
 static void rt2500usb_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
@@ -850,7 +844,7 @@
 
 	put_to_sleep = (state != STATE_AWAKE);
 
-	rt2x00_register_read(rt2x00dev, MAC_CSR17, &reg);
+	reg = 0;
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, state);
 	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, put_to_sleep);
@@ -872,7 +866,7 @@
 		if (bbp_state == state && rf_state == state)
 			return 0;
 		rt2x00_register_write(rt2x00dev, MAC_CSR17, reg);
-		msleep(10);
+		msleep(30);
 	}
 
 	NOTICE("Device failed to enter state %d, "
@@ -1098,7 +1092,7 @@
 	}
 	rt2x00_register_write(rt2x00dev, PHY_CSR2, reg);
 
-	rt2x00_register_write(rt2x00dev, MAC_CSR11, 0x0002);
+	rt2x00_register_write(rt2x00dev, MAC_CSR11, 0x0005);
 	rt2x00_register_write(rt2x00dev, MAC_CSR22, 0x0053);
 	rt2x00_register_write(rt2x00dev, MAC_CSR15, 0x01ee);
 	rt2x00_register_write(rt2x00dev, MAC_CSR16, 0x0000);
diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:12:45.000000000 +0200
+++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:20:46.000000000 +0200
@@ -1697,7 +1697,6 @@
 
 	rt2x00_register_write(rt2x00dev, MAC_CSR10, cpu_to_le32(0x00000718));
 
-	rt2x00_register_write(rt2x00dev, RX_CNTL_CSR, cpu_to_le32(0x00000001));
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, cpu_to_le32(0x025eb032));
 
 	rt2x00_register_write(rt2x00dev, TXRX_CSR1, cpu_to_le32(0x9eb39eb3));
@@ -1740,7 +1739,7 @@
 	rt2x00_register_write(rt2x00dev, PHY_CSR6, cpu_to_le32(0x00080606));
 	rt2x00_register_write(rt2x00dev, PHY_CSR7, cpu_to_le32(0x00000a08));
 
-	rt2x00_register_write(rt2x00dev, PCI_CFG_CSR, cpu_to_le32(0x3cca4808));
+	rt2x00_register_write(rt2x00dev, PCI_CFG_CSR, cpu_to_le32(0x28ca4404));
 
 	rt2x00_register_write(rt2x00dev, TEST_MODE_CSR,
 		cpu_to_le32(0x00000200));
@@ -1995,10 +1994,9 @@
 	/*
 	 * Enable interrupts.
 	 */
-	rt2x00_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_BEACON_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDONE, 0);
+	reg = 0;
+	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_ABORT_DONE, 1);
+	rt2x00_set_field32(&reg, INT_MASK_CSR_MITIGATION_PERIOD, 0xff);
 	rt2x00_register_write(rt2x00dev, INT_MASK_CSR, reg);
 
 	rt2x00_register_write(rt2x00dev, MCU_INT_MASK_CSR, 0x00000000);
@@ -2006,6 +2004,7 @@
 	/*
 	 * Enable RX.
 	 */
+	rt2x00_register_write(rt2x00dev, RX_CNTL_CSR, cpu_to_le32(0x00000001));
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
@@ -2061,10 +2060,8 @@
 	/*
 	 * Disable interrupts.
 	 */
-	rt2x00_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDONE,1);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_BEACON_DONE, 1);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDONE, 1);
+	reg = 0xffffffff;
+	rt2x00_set_field32(&reg, INT_MASK_CSR_ENABLE_MITIGATION, 0);
 	rt2x00_register_write(rt2x00dev, INT_MASK_CSR, reg);
 
 	rt2x00_register_write(rt2x00dev, MCU_INT_MASK_CSR, 0xffffffff);
