From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 20/30] Use menuconfig objects - ARCNET
Date: Tue, 10 Apr 2007 23:31:20 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704102329540.32056@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:53430 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918AbXDJVbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 17:31:36 -0400
In-Reply-To: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Wow, not a single MODULE_AUTHOR line in drivers/net/arcnet/ ...)

Use menuconfigs instead of menus, so the whole menu can be disabled at        
once instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

Index: linux-2.6.21-rc5/drivers/net/arcnet/Kconfig
===================================================================
--- linux-2.6.21-rc5.orig/drivers/net/arcnet/Kconfig
+++ linux-2.6.21-rc5/drivers/net/arcnet/Kconfig
@@ -2,10 +2,8 @@
 # Arcnet configuration
 #
 
-menu "ARCnet devices"
+menuconfig ARCNET
 	depends on NETDEVICES && (ISA || PCI)
-
-config ARCNET
 	tristate "ARCnet support"
 	---help---
 	  If you have a network card of this type, say Y and check out the
@@ -25,9 +23,10 @@ config ARCNET
 	  <file:Documentation/networking/net-modules.txt>.  The module will
 	  be called arcnet.
 
+if ARCNET
+
 config ARCNET_1201
 	tristate "Enable standard ARCNet packet format (RFC 1201)"
-	depends on ARCNET
 	help
 	  This allows you to use RFC1201 with your ARCnet card via the virtual
 	  arc0 device.  You need to say Y here to communicate with
@@ -38,7 +37,6 @@ config ARCNET_1201
 
 config ARCNET_1051
 	tristate "Enable old ARCNet packet format (RFC 1051)"
-	depends on ARCNET
 	---help---
 	  This allows you to use RFC1051 with your ARCnet card via the virtual
 	  arc0s device. You only need arc0s if you want to talk to ARCnet
@@ -53,7 +51,6 @@ config ARCNET_1051
 
 config ARCNET_RAW
 	tristate "Enable raw mode packet interface"
-	depends on ARCNET
 	help
 	  ARCnet "raw mode" packet encapsulation, no soft headers.  Unlikely
 	  to work unless talking to a copy of the same Linux arcnet driver,
@@ -61,7 +58,6 @@ config ARCNET_RAW
 
 config ARCNET_CAP
 	tristate "Enable CAP mode packet interface"
-	depends on ARCNET
 	help
 	  ARCnet "cap mode" packet encapsulation. Used to get the hardware
           acknowledge back to userspace. After the initial protocol byte every
@@ -80,7 +76,6 @@ config ARCNET_CAP
 
 config ARCNET_COM90xx
 	tristate "ARCnet COM90xx (normal) chipset driver"
-	depends on ARCNET
 	help
 	  This is the chipset driver for the standard COM90xx cards. If you
 	  have always used the old ARCnet driver without knowing what type of
@@ -92,7 +87,6 @@ config ARCNET_COM90xx
 
 config ARCNET_COM90xxIO
 	tristate "ARCnet COM90xx (IO mapped) chipset driver"
-	depends on ARCNET
 	---help---
 	  This is the chipset driver for the COM90xx cards, using them in
 	  IO-mapped mode instead of memory-mapped mode. This is slower than
@@ -105,7 +99,6 @@ config ARCNET_COM90xxIO
 
 config ARCNET_RIM_I
 	tristate "ARCnet COM90xx (RIM I) chipset driver"
-	depends on ARCNET
 	---help---
 	  This is yet another chipset driver for the COM90xx cards, but this
 	  time only using memory-mapped mode, and no IO ports at all. This
@@ -118,7 +111,6 @@ config ARCNET_RIM_I
 
 config ARCNET_COM20020
 	tristate "ARCnet COM20020 chipset driver"
-	depends on ARCNET
 	help
 	  This is the driver for the new COM20020 chipset. It supports such
 	  things as promiscuous mode, so packet sniffing is possible, and
@@ -136,5 +128,4 @@ config ARCNET_COM20020_PCI
 	tristate "Support for COM20020 on PCI"
 	depends on ARCNET_COM20020 && PCI
 
-endmenu
-
+endif # ARCNET
#<EOF>
