From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 23/30] Use menuconfig objects - netdev
Date: Tue, 10 Apr 2007 23:36:53 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704102335020.32056@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:56165 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504AbXDJVjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 17:39:15 -0400
In-Reply-To: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use menuconfigs instead of menus, so the whole menu can be disabled at        
once instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

Index: linux-2.6.21-rc5/drivers/net/Kconfig
===================================================================
--- linux-2.6.21-rc5.orig/drivers/net/Kconfig
+++ linux-2.6.21-rc5/drivers/net/Kconfig
@@ -1897,8 +1897,12 @@ endmenu
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
@@ -2327,14 +2331,18 @@ config ATL1
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
@@ -2493,7 +2501,7 @@ config PASEMI_MAC
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
 
-endmenu
+endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
 
#<EOF>
