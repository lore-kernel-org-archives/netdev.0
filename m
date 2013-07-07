From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Fix Kconfig for some corner cases
Date: Sat,  6 Jul 2013 21:47:24 -0500
Message-ID: <1373165244-9536-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:37632 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3GGCrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jul 2013 22:47:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang Wu reported the following errors in the build of rtlwifi with
a random configuration:

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux master
head:   bcd7351e83728859833e3c5b8aae9a2816914e4b
commit: 06e7cda3ce30dadc3454539127b4cfc3888c349e rtlwifi: Rework Kconfig
date:   5 months ago
config: i386-randconfig-s05-0703

   drivers/built-in.o: In function `rtl_usb_cleanup':
   usb.c:(.text+0x114895): undefined reference to `usb_kill_anchored_urbs'
   usb.c:(.text+0x114964): undefined reference to `usb_kill_anchored_urbs'
   usb.c:(.text+0x11497c): undefined reference to `usb_kill_anchored_urbs'
   drivers/built-in.o: In function `_usb_writeN_sync':
   usb.c:(.text+0x114c9e): undefined reference to `usb_control_msg'
   drivers/built-in.o: In function `rtl_usb_disconnect':
   (.text+0x114d9c): undefined reference to `usb_put_dev'
   drivers/built-in.o: In function `rtl_usb_start':
   usb.c:(.text+0x114fb0): undefined reference to `usb_alloc_urb'
   usb.c:(.text+0x115049): undefined reference to `usb_free_urb'
--snip--

Although I could not duplicate this result on my machine, it seemed likely
that it was due to the unusual configuration where rtlwifi was being built,
but none of its dependent drivers were selected.

The fix is to select rtlwifi only when it is needed. While making this
change, I simplified the configuration so that variable RTLWIFI is never seen
by the user. In addition, now that the rtlwifi family has six members, I
added a menu so that these drivers no longer appear in the long list of
wireless drivers, but in a separate panel.

Cc: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Tested-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/Kconfig | 57 +++++++++++++++++++++---------------
 1 file changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 7253de3..7552841 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -1,27 +1,18 @@
-config RTLWIFI
-	tristate "Realtek wireless card support"
-	depends on MAC80211
-	select FW_LOADER
+menuconfig RTL_CARDS
+	tristate "Realtek rtlwifi family of devices"
+	depends on MAC80211 && (PCI || USB)
 	---help---
-	  This is common code for RTL8192CE/RTL8192CU/RTL8192SE/RTL8723AE
-	  drivers.  This module does nothing by itself - the various front-end
-	  drivers need to be enabled to support any desired devices.
+	  This option will enable support for the Realtek mac80211-based
+	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192de,
+	  rtl8723eu, and rtl8188eu share some common code.
 
-	  If you choose to build as a module, it'll be called rtlwifi.
-
-config RTLWIFI_DEBUG
-	bool "Debugging output for rtlwifi driver family"
-	depends on RTLWIFI
-	default y
-	---help---
-	To use the module option that sets the dynamic-debugging level for,
-	the front-end driver, this parameter must be "Y". For memory-limited
-	systems, choose "N". If in doubt, choose "Y".
+if RTL_CARDS
 
 config RTL8192CE
 	tristate "Realtek RTL8192CE/RTL8188CE Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
 	select RTL8192C_COMMON
+	select RTLWIFI
 	---help---
 	This is the driver for Realtek RTL8192CE/RTL8188CE 802.11n PCIe
 	wireless network adapters.
@@ -30,7 +21,8 @@ config RTL8192CE
 
 config RTL8192SE
 	tristate "Realtek RTL8192SE/RTL8191SE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
 	---help---
 	This is the driver for Realtek RTL8192SE/RTL8191SE 802.11n PCIe
 	wireless network adapters.
@@ -39,7 +31,8 @@ config RTL8192SE
 
 config RTL8192DE
 	tristate "Realtek RTL8192DE/RTL8188DE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
 	---help---
 	This is the driver for Realtek RTL8192DE/RTL8188DE 802.11n PCIe
 	wireless network adapters.
@@ -48,7 +40,8 @@ config RTL8192DE
 
 config RTL8723AE
 	tristate "Realtek RTL8723AE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
 	---help---
 	This is the driver for Realtek RTL8723AE 802.11n PCIe
 	wireless network adapters.
@@ -57,7 +50,8 @@ config RTL8723AE
 
 config RTL8188EE
 	tristate "Realtek RTL8188EE Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
 	---help---
 	This is the driver for Realtek RTL8188EE 802.11n PCIe
 	wireless network adapters.
@@ -66,7 +60,8 @@ config RTL8188EE
 
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
-	depends on RTLWIFI && USB
+	depends on USB
+	select RTLWIFI
 	select RTL8192C_COMMON
 	---help---
 	This is the driver for Realtek RTL8192CU/RTL8188CU 802.11n USB
@@ -74,7 +69,22 @@ config RTL8192CU
 
 	If you choose to build it as a module, it will be called rtl8192cu
 
+config RTLWIFI
+	tristate
+	select FW_LOADER
+
+config RTLWIFI_DEBUG
+	bool "Debugging output for rtlwifi driver family"
+	depends on RTLWIFI
+	default y
+	---help---
+	To use the module option that sets the dynamic-debugging level for,
+	the front-end driver, this parameter must be "Y". For memory-limited
+	systems, choose "N". If in doubt, choose "Y".
+
 config RTL8192C_COMMON
 	tristate
 	depends on RTL8192CE || RTL8192CU
 	default m
+
+endif
-- 
1.8.1.4
