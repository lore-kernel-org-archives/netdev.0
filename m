From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 20/26] rt2x00: Call activity_led()
Date: Sun, 3 Dec 2006 19:18:58 +0100
Message-ID: <200612031918.58679.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758818AbWLCSTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:22 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:22 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Call activity_led() function after each rxdone run
to make the led blink.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:52:04.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:09:41.000000000 +0100
@@ -1597,6 +1597,11 @@
 		rt2x00_desc_write(rxd, 0, word0);
 		rt2x00_ring_index_inc(ring);
 	}
+
+	/*
+	 * Update LED.
+	 */
+	rt2400pci_activity_led(rt2x00dev, 0);
 }
 
 static void rt2400pci_txdone(void *data)
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 13:04:38.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 15:08:03.000000000 +0100
@@ -943,6 +943,14 @@
 static int rt2400pci_tx_last_beacon(struct ieee80211_hw *hw);
 
 /*
+ * LED control functions.
+ */
+static void rt2400pci_enable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2400pci_disable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2400pci_activity_led(struct rt2x00_dev *rt2x00dev,
+	char activity);
+
+/*
  * Radio control functions.
  */
 static int rt2400pci_enable_radio(struct rt2x00_dev *rt2x00dev);
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:52:32.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:09:55.000000000 +0100
@@ -1760,6 +1760,11 @@
 		rt2x00_desc_write(rxd, 0, word0);
 		rt2x00_ring_index_inc(ring);
 	}
+
+	/*
+	 * Update LED.
+	 */
+	rt2500pci_activity_led(rt2x00dev, 0);
 }
 
 static void rt2500pci_txdone(void *data)
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-03 13:04:44.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-03 15:08:18.000000000 +0100
@@ -1210,6 +1210,14 @@
 static int rt2500pci_tx_last_beacon(struct ieee80211_hw *hw);
 
 /*
+ * LED control functions.
+ */
+static void rt2500pci_enable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2500pci_disable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2500pci_activity_led(struct rt2x00_dev *rt2x00dev,
+	char activity);
+
+/*
  * Radio control functions.
  */
 static int rt2500pci_enable_radio(struct rt2x00_dev *rt2x00dev);
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:52:36.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:10:04.000000000 +0100
@@ -1737,6 +1737,11 @@
 
 		rt2x00_ring_index_inc(ring);
 	}
+
+	/*
+	 * Update LED.
+	 */
+	rt2500usb_activity_led(rt2x00dev, 0);
 }
 
 static void rt2500usb_txdone(void *data)
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 13:04:50.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 15:08:28.000000000 +0100
@@ -712,6 +712,14 @@
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
 
 /*
+ * LED control functions.
+ */
+static void rt2500usb_enable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2500usb_disable_led(struct rt2x00_dev *rt2x00dev);
+static void rt2500usb_activity_led(struct rt2x00_dev *rt2x00dev,
+	char activity);
+
+/*
  * Radio control functions.
  */
 static int rt2500usb_enable_radio(struct rt2x00_dev *rt2x00dev);
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:52:40.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:10:28.000000000 +0100
@@ -940,7 +940,6 @@
 	if (!rssi)
 		goto exit;
 
-
 	/*
 	 * Update LED.
 	 */
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 14:01:38.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 15:08:39.000000000 +0100
@@ -1375,6 +1375,13 @@
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
 
 /*
+ * LED control functions.
+ */
+static void rt61pci_enable_led(struct rt2x00_dev *rt2x00dev);
+static void rt61pci_disable_led(struct rt2x00_dev *rt2x00dev);
+static void rt61pci_activity_led(struct rt2x00_dev *rt2x00dev, char rssi);
+
+/*
  * Radio control functions.
  */
 static int rt61pci_enable_radio(struct rt2x00_dev *rt2x00dev);
diff -rU3 wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 14:01:58.000000000 +0100
+++ wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 15:08:49.000000000 +0100
@@ -957,6 +957,13 @@
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
 
 /*
+ * LED control functions.
+ */
+static void rt73usb_enable_led(struct rt2x00_dev *rt2x00dev);
+static void rt73usb_disable_led(struct rt2x00_dev *rt2x00dev);
+static void rt73usb_activity_led(struct rt2x00_dev *rt2x00dev, char rssi);
+
+/*
  * Radio control functions.
  */
 static int rt73usb_enable_radio(struct rt2x00_dev *rt2x00dev);
