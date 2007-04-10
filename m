From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 21/30] Use menuconfig objects - PHY
Date: Tue, 10 Apr 2007 23:33:05 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704102331230.32056@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:54535 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbXDJVeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 17:34:22 -0400
In-Reply-To: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(No MAINTAINERS entry. MODULE_AUTHOR lines exist, but without addresses.)

Use menuconfigs instead of menus, so the whole menu can be disabled at        
once instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

Index: linux-2.6.21-rc5/drivers/net/phy/Kconfig
===================================================================
--- linux-2.6.21-rc5.orig/drivers/net/phy/Kconfig
+++ linux-2.6.21-rc5/drivers/net/phy/Kconfig
@@ -2,9 +2,7 @@
 # PHY Layer Configuration
 #
 
-menu "PHY device support"
-
-config PHYLIB
+menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on NET_ETHERNET && (BROKEN || !S390)
 	help
@@ -12,59 +10,52 @@ config PHYLIB
 	  devices.  This option provides infrastructure for
 	  managing PHY devices.
 
+if PHYLIB
+
 comment "MII PHY device drivers"
-	depends on PHYLIB
 
 config MARVELL_PHY
 	tristate "Drivers for Marvell PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently has a driver for the 88E1011S
 	
 config DAVICOM_PHY
 	tristate "Drivers for Davicom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports dm9161e and dm9131
 
 config QSEMI_PHY
 	tristate "Drivers for Quality Semiconductor PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the qs6612
 
 config LXT_PHY
 	tristate "Drivers for the Intel LXT PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the lxt970, lxt971
 
 config CICADA_PHY
 	tristate "Drivers for the Cicada PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the cis8204
+
 config VITESSE_PHY
         tristate "Drivers for the Vitesse PHYs"
-        depends on PHYLIB
         ---help---
           Currently supports the vsc8244
 
 config SMSC_PHY
 	tristate "Drivers for SMSC PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the LAN83C185 PHY
 
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
 
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
-	depends on PHYLIB
 	---help---
 	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
 	  but with the ability to manipulate the speed/link in software. The relevant MII
@@ -79,5 +70,4 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
-endmenu
-
+endif # PHYLIB
#<EOF>
