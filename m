From: akpm@linux-foundation.org
Subject: [patch 6/8] Use menuconfig objects: ARCNET
Date: Wed, 23 May 2007 14:35:56 -0700
Message-ID: <200705232135.l4NLZuhl000669@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:50205 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756363AbXEWVgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/arcnet/Kconfig |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff -puN drivers/net/arcnet/Kconfig~use-menuconfig-objects-arcnet drivers/net/arcnet/Kconfig
--- a/drivers/net/arcnet/Kconfig~use-menuconfig-objects-arcnet
+++ a/drivers/net/arcnet/Kconfig
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
_
