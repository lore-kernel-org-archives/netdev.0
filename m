From: akpm@linux-foundation.org
Subject: [patch 07/13] Use menuconfig objects: netdev
Date: Thu, 10 May 2007 22:52:56 -0700
Message-ID: <200705110552.l4B5qukd007810@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43572 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760067AbXEKFxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff -puN drivers/net/Kconfig~use-menuconfig-objects-netdev drivers/net/Kconfig
--- a/drivers/net/Kconfig~use-menuconfig-objects-netdev
+++ a/drivers/net/Kconfig
@@ -1942,8 +1942,12 @@ endmenu
 #	Gigabit Ethernet
 #
 
-menu "Ethernet (1000 Mbit)"
+menuconfig NETDEV_1000
+	bool "Ethernet (1000 Mbit)"
 	depends on !UML
+	default y
+
+if NETDEV_1000
 
 config ACENIC
 	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
@@ -2369,14 +2373,18 @@ config ATL1
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
 
-endmenu
+endif # NETDEV_1000
 
 #
 #	10 Gigabit Ethernet
 #
 
-menu "Ethernet (10000 Mbit)"
+menuconfig NETDEV_10000
+	bool "Ethernet (10000 Mbit)"
 	depends on !UML
+	default y
+
+if NETDEV_10000
 
 config CHELSIO_T1
         tristate "Chelsio 10Gb Ethernet support"
@@ -2551,7 +2559,7 @@ config MLX4_DEBUG
 	  debug_level module parameter (which can also be set after
 	  the driver is loaded through sysfs).
 
-endmenu
+endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
 
_
