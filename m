From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 6/10] rt2x00: Respect return values
Date: Sun, 27 Aug 2006 17:39:14 +0200
Message-ID: <200608271739.14627.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42540 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932142AbWH0PjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:24 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091663nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:23 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Respect the return values given from various functions.
The return code should be handed upstream and not
replaced by some other (possibly wrong) error code.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:17:02.000000000 +0200
+++ wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:29:05.000000000 +0200
@@ -2937,6 +2937,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -2948,8 +2949,9 @@
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2400pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2400pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -2973,6 +2975,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -2989,9 +2992,10 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2400pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt2400pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
diff -rU3 wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:17:56.000000000 +0200
+++ wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:29:08.000000000 +0200
@@ -3222,6 +3222,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3233,8 +3234,9 @@
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2500pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2500pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3258,6 +3260,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3274,9 +3277,10 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt2500pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
diff -rU3 wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:19:04.000000000 +0200
+++ wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:28:23.000000000 +0200
@@ -2839,6 +2839,7 @@
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -2850,8 +2851,9 @@
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt2500usb_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt2500usb_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -2875,6 +2877,7 @@
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -2886,9 +2889,10 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt2500usb_alloc_dev(usb_intf, net_dev)) {
+	status = rt2500usb_alloc_dev(usb_intf, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
diff -rU3 wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:20:46.000000000 +0200
+++ wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:29:03.000000000 +0200
@@ -3739,6 +3739,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3750,8 +3751,9 @@
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt61pci_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt61pci_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3775,6 +3777,7 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3791,9 +3794,10 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt61pci_alloc_dev(pci_dev, net_dev)) {
+	status = rt61pci_alloc_dev(pci_dev, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
diff -rU3 wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:13:06.000000000 +0200
+++ wireless-dev-rt2x00-return/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:29:43.000000000 +0200
@@ -3204,6 +3204,7 @@
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Going to sleep.\n");
 
@@ -3215,8 +3216,9 @@
 	/*
 	 * Set device mode to sleep for power management.
 	 */
-	if (rt73usb_set_state(rt2x00dev, STATE_SLEEP))
-		return -EBUSY;
+	status = rt73usb_set_state(rt2x00dev, STATE_SLEEP);
+	if (status)
+		return status;
 
 	/*
 	 * Uninitialize device.
@@ -3240,6 +3242,7 @@
 {
 	struct net_device *net_dev = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	int status;
 
 	NOTICE("Waking up.\n");
 
@@ -3251,9 +3254,10 @@
 	/*
 	 * Initialize hardware.
 	 */
-	if (rt73usb_alloc_dev(usb_intf, net_dev)) {
+	status = rt73usb_alloc_dev(usb_intf, net_dev);
+	if (status) {
 		ERROR("Failed to allocate device.\n");
-		return -ENOMEM;
+		return status;
 	}
 
 	/*
