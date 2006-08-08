From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 6/6] rt2x00 - misc fixes
Date: Tue, 8 Aug 2006 15:46:57 +0200
Message-ID: <200608081546.58011.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:39914 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964888AbWHHNr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:29 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175918nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:28 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small misc fixes,
- remove unwanted whitespaces
- limit lines to 80 characters
- byteordering fix
- comment fix

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 15:10:31.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 15:26:03.000000000 +0200
@@ -2315,7 +2315,7 @@
 	} else {
 		rt2500pci_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.running_phymode);
-	
+
 		rt2500pci_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.running_channel_val,
 			rt2x00dev->scan->conf.running_channel,
@@ -2842,7 +2842,7 @@
 		};
 
 		struct ieee80211_channel *chan = channels + 14;
-	
+
 		for (i = 0; i < ARRAY_SIZE(vals); i++)
 			(chan++)->val = cpu_to_le32(vals[i]);
 	}
diff -rU3 wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 15:12:02.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 15:27:05.000000000 +0200
@@ -170,7 +170,8 @@
 	*value = 0xff;
 }
 
-static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev, const u32 value)
+static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
+	const u32 value)
 {
 	u16 reg;
 	unsigned int i;
@@ -1481,7 +1482,7 @@
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	if ((ieee80211hdr->seq_ctrl & IEEE80211_SCTL_FRAG) == 0)
+	if ((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) == 0)
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 0);
@@ -2031,7 +2032,7 @@
 	if (rt2x00dev->scan->state == IEEE80211_SCAN_START) {
 		rt2500usb_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.scan_phymode);
-	
+
 		rt2500usb_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.scan_channel_val,
 			rt2x00dev->scan->conf.scan_channel,
@@ -2040,7 +2041,7 @@
 	} else {
 		rt2500usb_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.running_phymode);
-	
+
 		rt2500usb_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.running_channel_val,
 			rt2x00dev->scan->conf.running_channel,
diff -rU3 wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 15:12:43.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 15:27:30.000000000 +0200
@@ -794,7 +794,7 @@
 	 * Device structure.
 	 * The structure stored in here depends on the
 	 * system bus (PCI or USB).
-	 * When accessing this variable, the rt2x00{pci,usb}_dev
+	 * When accessing this variable, the rt2x00dev_{pci,usb}
 	 * macro's should be used for correct typecasting.
 	 */
 	void *dev;
diff -rU3 wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 15:14:45.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 15:28:30.000000000 +0200
@@ -3459,7 +3459,6 @@
 	hw->modes[0].num_channels = 14;
 	hw->modes[0].num_rates = 12;
 
-
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
diff -rU3 wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 15:19:04.000000000 +0200
+++ wireless-dev-rt2x00-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 15:28:35.000000000 +0200
@@ -2124,6 +2124,7 @@
 static int rt73usb_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
 	rt73usb_disable_radio(rt2x00dev);
 	return rt73usb_enable_radio(rt2x00dev);
 }
@@ -2967,7 +2968,6 @@
 	hw->modes[0].num_channels = 14;
 	hw->modes[0].num_rates = 12;
 
-
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
