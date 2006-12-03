From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 19/26] rt2x00: Fix channel_change_time calculation
Date: Sun, 3 Dec 2006 19:18:58 +0100
Message-ID: <200612031918.59151.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:57689 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758830AbWLCSTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:24 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144364nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:23 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly initialize the channel_change_time.
Make sure that channel is reset afterwards,
otherwise the channel is not correctly initialized
and rx/tx will fail.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:45:46.000000000 +0100
+++ wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 14:52:04.000000000 +0100
@@ -1124,6 +1124,19 @@
 	unsigned long jiffies_end;
 
 	/*
+	 * Only initialize the channel_change_time
+	 * if it has not been set previously.
+	 */
+	if (rt2x00dev->hw->channel_change_time)
+		return 0;
+
+	/*
+	 * Invalidate the rx_params.channel value to make sure
+	 * the config channel will be correctly executed.
+	 */
+	rt2x00dev->rx_params.channel = 0;
+
+	/*
 	 * Determine channel_change_time
 	 * by measuring the time it takes
 	 * to switch the channel.
@@ -1171,10 +1184,11 @@
 	}
 
 	/*
-	 * Determine channel change time.
+	 * Reset the channel_change_time value
+	 * to make sure it will be correctly initialized
+	 * after the radio has been enabled.
 	 */
-	if (rt2400pci_init_channel_time(rt2x00dev))
-		goto exit_fail;
+	rt2x00dev->hw->channel_change_time = 0;
 
 	/*
 	 * Register interrupt handler.
diff -rU3 wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:46:09.000000000 +0100
+++ wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 14:52:32.000000000 +0100
@@ -1248,6 +1248,19 @@
 	unsigned long jiffies_end;
 
 	/*
+	 * Only initialize the channel_change_time
+	 * if it has not been set previously.
+	 */
+	if (rt2x00dev->hw->channel_change_time)
+		return 0;
+
+	/*
+	 * Invalidate the rx_params.channel value to make sure
+	 * the config channel will be correctly executed.
+	 */
+	rt2x00dev->rx_params.channel = 0;
+
+	/*
 	 * Determine channel_change_time
 	 * by measuring the time it takes
 	 * to switch the channel.
@@ -1296,10 +1309,11 @@
 	}
 
 	/*
-	 * Determine channel change time.
+	 * Reset the channel_change_time value
+	 * to make sure it will be correctly initialized
+	 * after the radio has been enabled.
 	 */
-	if (rt2500pci_init_channel_time(rt2x00dev))
-		goto exit_fail;
+	rt2x00dev->hw->channel_change_time = 0;
 
 	/*
 	 * Register interrupt handler.
diff -rU3 wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:46:19.000000000 +0100
+++ wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 14:52:36.000000000 +0100
@@ -1214,6 +1214,19 @@
 	unsigned long jiffies_end;
 
 	/*
+	 * Only initialize the channel_change_time
+	 * if it has not been set previously.
+	 */
+	if (rt2x00dev->hw->channel_change_time)
+		return 0;
+
+	/*
+	 * Invalidate the rx_params.channel value to make sure
+	 * the config channel will be correctly executed.
+	 */
+	rt2x00dev->rx_params.channel = 0;
+
+	/*
 	 * Determine channel_change_time
 	 * by measuring the time it takes
 	 * to switch the channel.
@@ -1262,10 +1275,11 @@
 	}
 
 	/*
-	 * Determine channel change time.
+	 * Reset the channel_change_time value
+	 * to make sure it will be correctly initialized
+	 * after the radio has been enabled.
 	 */
-	if (rt2500usb_init_channel_time(rt2x00dev))
-		goto exit_fail;
+	rt2x00dev->hw->channel_change_time = 0;
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED);
 
diff -rU3 wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:46:31.000000000 +0100
+++ wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 14:52:40.000000000 +0100
@@ -1681,6 +1681,19 @@
 	unsigned long jiffies_end;
 
 	/*
+	 * Only initialize the channel_change_time
+	 * if it has not been set previously.
+	 */
+	if (rt2x00dev->hw->channel_change_time)
+		return 0;
+
+	/*
+	 * Invalidate the rx_params.channel value to make sure
+	 * the config channel will be correctly executed.
+	 */
+	rt2x00dev->rx_params.channel = 0;
+
+	/*
 	 * Determine channel_change_time
 	 * by measuring the time it takes
 	 * to switch the channel.
@@ -1736,10 +1749,11 @@
 	}
 
 	/*
-	 * Determine channel change time.
+	 * Reset the channel_change_time value
+	 * to make sure it will be correctly initialized
+	 * after the radio has been enabled.
 	 */
-	if (rt61pci_init_channel_time(rt2x00dev))
-		goto exit_fail;
+	rt2x00dev->hw->channel_change_time = 0;
 
 	/*
 	 * Register interrupt handler.
diff -rU3 wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:46:42.000000000 +0100
+++ wireless-dev-channel/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:52:44.000000000 +0100
@@ -1463,6 +1463,19 @@
 	unsigned long jiffies_end;
 
 	/*
+	 * Only initialize the channel_change_time
+	 * if it has not been set previously.
+	 */
+	if (rt2x00dev->hw->channel_change_time)
+		return 0;
+
+	/*
+	 * Invalidate the rx_params.channel value to make sure
+	 * the config channel will be correctly executed.
+	 */
+	rt2x00dev->rx_params.channel = 0;
+
+	/*
 	 * Determine channel_change_time
 	 * by measuring the time it takes
 	 * to switch the channel.
@@ -1518,10 +1531,11 @@
 	}
 
 	/*
-	 * Determine channel change time.
+	 * Reset the channel_change_time value
+	 * to make sure it will be correctly initialized
+	 * after the radio has been enabled.
 	 */
-	if (rt73usb_init_channel_time(rt2x00dev))
-		goto exit_fail;
+	rt2x00dev->hw->channel_change_time = 0;
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED);
 
