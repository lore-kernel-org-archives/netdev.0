From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 7/10] rt2x00: Add ieee80211_netif_oper() calls
Date: Sun, 27 Aug 2006 17:39:14 +0200
Message-ID: <200608271739.15085.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46123 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932143AbWH0PjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:25 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091661nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:24 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ieee80211_netif_oper() calls on the correct places
for better flow control.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:29:05.000000000 +0200
+++ wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:32:51.000000000 +0200
@@ -1465,17 +1465,22 @@
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2400pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -2893,6 +2898,8 @@
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -2917,6 +2924,8 @@
 
 	rt2400pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2400pci_uninitialize(rt2x00dev);
 
 	rt2400pci_free_dev(net_dev);
@@ -2945,6 +2954,7 @@
 	 * Disable the radio.
 	 */
 	rt2400pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3001,7 +3011,13 @@
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2400pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2400pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:29:08.000000000 +0200
+++ wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:34:16.000000000 +0200
@@ -1589,17 +1589,22 @@
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2500pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -3178,6 +3183,8 @@
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3202,6 +3209,8 @@
 
 	rt2500pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2500pci_uninitialize(rt2x00dev);
 
 	rt2500pci_free_dev(net_dev);
@@ -3230,6 +3239,7 @@
 	 * Disable the radio.
 	 */
 	rt2500pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3286,7 +3296,13 @@
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2500pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2500pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:28:23.000000000 +0200
+++ wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:35:43.000000000 +0200
@@ -1335,12 +1335,15 @@
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2500usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev =
+		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	u16 reg;
 	unsigned int i;
@@ -1348,6 +1351,9 @@
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -2802,6 +2808,8 @@
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -2820,6 +2828,8 @@
 
 	rt2500usb_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt2500usb_uninitialize(rt2x00dev);
 
 	rt2500usb_free_dev(net_dev);
@@ -2847,6 +2857,7 @@
 	 * Disable the radio.
 	 */
 	rt2500usb_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -2898,7 +2909,13 @@
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt2500usb_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt2500usb_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:37:11.000000000 +0200
+++ wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:38:04.000000000 +0200
@@ -2017,17 +2017,22 @@
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt61pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -3695,6 +3700,8 @@
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3719,6 +3726,8 @@
 
 	rt61pci_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt61pci_uninitialize(rt2x00dev);
 
 	rt61pci_free_dev(net_dev);
@@ -3747,6 +3756,7 @@
 	 * Disable the radio.
 	 */
 	rt61pci_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3803,7 +3813,13 @@
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt61pci_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt61pci_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
+	return 0;
 }
 #endif /* CONFIG_PM */
 
diff -rU3 wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:29:43.000000000 +0200
+++ wireless-dev-rt2x00-netif/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:40:05.000000000 +0200
@@ -1600,12 +1600,15 @@
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
 	ieee80211_start_queues(net_dev);
+	ieee80211_netif_oper(net_dev, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt73usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
+	struct net_device *net_dev =
+		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	struct data_ring *ring;
 	u32 reg;
 	unsigned int i;
@@ -1613,6 +1616,9 @@
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
+	ieee80211_netif_oper(net_dev, NETIF_STOP);
+	ieee80211_stop_queues(net_dev);
+
 	/*
 	 * Disable LED
 	 */
@@ -3168,6 +3174,8 @@
 		goto exit_free_device;
 	}
 
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+
 	return 0;
 
 exit_free_device:
@@ -3186,6 +3194,8 @@
 
 	rt73usb_disable_radio(rt2x00dev);
 
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+
 	rt73usb_uninitialize(rt2x00dev);
 
 	rt73usb_free_dev(net_dev);
@@ -3212,6 +3222,7 @@
 	 * Disable the radio.
 	 */
 	rt73usb_disable_radio(rt2x00dev);
+	ieee80211_netif_oper(net_dev, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -3263,7 +3274,12 @@
 	/*
 	 * Set device mode to awake for power management.
 	 */
-	return rt73usb_set_state(rt2x00dev, STATE_AWAKE);
+	status = rt73usb_set_state(rt2x00dev, STATE_AWAKE);
+	if (status)
+		return status;
+
+	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	return 0;
 }
 #endif /* CONFIG_PM */
 
