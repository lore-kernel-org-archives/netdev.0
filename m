From: akpm@linux-foundation.org
Subject: [patch 11/13] Use menuconfig objects II - netdev/wan
Date: Thu, 10 May 2007 22:52:59 -0700
Message-ID: <200705110552.l4B5qxBK007822@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de, khc@pm.waw.pl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:48172 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758979AbXEKGJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Change Kconfig objects from "menu, config" into "menuconfig" so
that the user can disable the whole feature without having to
enter the menu first.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/Kconfig |   34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff -puN drivers/net/wan/Kconfig~use-menuconfig-objects-ii-netdev-wan drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig~use-menuconfig-objects-ii-netdev-wan
+++ a/drivers/net/wan/Kconfig
@@ -2,10 +2,7 @@
 # wan devices configuration
 #
 
-menu "Wan interfaces"
-	depends on NETDEVICES
-
-config WAN
+menuconfig WAN
 	bool "Wan interfaces support"
 	---help---
 	  Wide Area Networks (WANs), such as X.25, Frame Relay and leased
@@ -23,10 +20,12 @@ config WAN
 
 	  If unsure, say N.
 
+if WAN
+
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on WAN && ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -38,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on WAN && ISA && m && ISA_DMA_API
+	depends on ISA && m && ISA_DMA_API
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
@@ -62,7 +61,7 @@ config COSA
 #
 config LANMEDIA
 	tristate "LanMedia Corp. SSI/V.35, T1/E1, HSSI, T3 boards"
-	depends on WAN && PCI
+	depends on PCI
 	---help---
 	  Driver for the following Lan Media family of serial boards:
 
@@ -89,7 +88,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on WAN && ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
@@ -99,7 +98,6 @@ config SEALEVEL_4021
 # Generic HDLC
 config HDLC
 	tristate "Generic HDLC layer"
-	depends on WAN
 	help
 	  Say Y to this option if your Linux box contains a WAN (Wide Area
 	  Network) card supported by this driver and you are planning to
@@ -167,7 +165,7 @@ config HDLC_X25
 	  If unsure, say N.
 
 comment "X.25/LAPB support is disabled"
-	depends on WAN && HDLC && (LAPB!=m || HDLC!=m) && LAPB!=y
+	depends on HDLC && (LAPB!=m || HDLC!=m) && LAPB!=y
 
 config PCI200SYN
 	tristate "Goramo PCI200SYN support"
@@ -230,10 +228,10 @@ config PC300_MLPPP
 	  Multilink PPP over the PC300 synchronous communication boards.
 
 comment "Cyclades-PC300 MLPPP support is disabled."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 comment "Refer to the file README.mlppp, provided by PC300 package."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 config PC300TOO
 	tristate "Cyclades PC300 RSV/X21 alternative support"
@@ -338,7 +336,6 @@ config DSCC4_PCI_RST
 
 config DLCI
 	tristate "Frame Relay DLCI support"
-	depends on WAN
 	---help---
 	  Support for the Frame Relay protocol.
 
@@ -385,7 +382,7 @@ config SDLA
 # Wan router core.
 config WAN_ROUTER_DRIVERS
 	tristate "WAN router drivers"
-	depends on WAN && WAN_ROUTER
+	depends on WAN_ROUTER
 	---help---
 	  Connect LAN to WAN via Linux box.
 
@@ -440,7 +437,7 @@ config CYCLOMX_X25
 # X.25 network drivers
 config LAPBETHER
 	tristate "LAPB over Ethernet driver (EXPERIMENTAL)"
-	depends on WAN && LAPB && X25
+	depends on LAPB && X25
 	---help---
 	  Driver for a pseudo device (typically called /dev/lapb0) which allows
 	  you to open an LAPB point-to-point connection to some other computer
@@ -456,7 +453,7 @@ config LAPBETHER
 
 config X25_ASY
 	tristate "X.25 async driver (EXPERIMENTAL)"
-	depends on WAN && LAPB && X25
+	depends on LAPB && X25
 	---help---
 	  Send and receive X.25 frames over regular asynchronous serial
 	  lines such as telephone lines equipped with ordinary modems.
@@ -471,7 +468,7 @@ config X25_ASY
 
 config SBNI
 	tristate "Granch SBNI12 Leased Line adapter support"
-	depends on WAN && X86
+	depends on X86
 	---help---
 	  Driver for ISA SBNI12-xx cards which are low cost alternatives to
 	  leased line modems.
@@ -497,5 +494,4 @@ config SBNI_MULTILINE
 
 	  If unsure, say N.
 
-endmenu
-
+endif # WAN
_
