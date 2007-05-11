From: akpm@linux-foundation.org
Subject: [patch 7/8] Use menuconfig objects: tokenring
Date: Thu, 10 May 2007 22:53:49 -0700
Message-ID: <200705110553.l4B5rnJQ007867@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34141 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757692AbXEKFyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:54:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>

Use menuconfigs instead of menus, so the whole menu can be disabled at once
instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tokenring/Kconfig |   33 +++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff -puN drivers/net/tokenring/Kconfig~use-menuconfig-objects-toeknring drivers/net/tokenring/Kconfig
--- a/drivers/net/tokenring/Kconfig~use-menuconfig-objects-toeknring
+++ a/drivers/net/tokenring/Kconfig
@@ -2,12 +2,10 @@
 # Token Ring driver configuration
 #
 
-menu "Token Ring devices"
-	depends on NETDEVICES && !UML
-
 # So far, we only have PCI, ISA, and MCA token ring devices
-config TR
+menuconfig TR
 	bool "Token Ring driver support"
+	depends on NETDEVICES && !UML
 	depends on (PCI || ISA || MCA || CCW)
 	select LLC
 	help
@@ -20,9 +18,11 @@ config TR
 	  from <http://www.tldp.org/docs.html#howto>. Most people can
 	  say N here.
 
+if TR
+
 config IBMTR
 	tristate "IBM Tropic chipset based adapter support"
-	depends on TR && (ISA || MCA)
+	depends on ISA || MCA
 	---help---
 	  This is support for all IBM Token Ring cards that don't use DMA. If
 	  you have such a beast, say Y and read the Token-Ring mini-HOWTO,
@@ -36,7 +36,7 @@ config IBMTR
 
 config IBMOL
 	tristate "IBM Olympic chipset PCI adapter support"
-	depends on TR && PCI
+	depends on PCI
 	---help---
 	  This is support for all non-Lanstreamer IBM PCI Token Ring Cards.
 	  Specifically this is all IBM PCI, PCI Wake On Lan, PCI II, PCI II
@@ -54,7 +54,7 @@ config IBMOL
 
 config IBMLS
 	tristate "IBM Lanstreamer chipset PCI adapter support"
-	depends on TR && PCI && !64BIT
+	depends on PCI && !64BIT
 	help
 	  This is support for IBM Lanstreamer PCI Token Ring Cards.
 
@@ -66,7 +66,7 @@ config IBMLS
 
 config 3C359
 	tristate "3Com 3C359 Token Link Velocity XL adapter support"
-	depends on TR && PCI
+	depends on PCI
 	---help---
 	  This is support for the 3Com PCI Velocity XL cards, specifically
 	  the 3Com 3C359, please note this is not for the 3C339 cards, you
@@ -84,7 +84,7 @@ config 3C359
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on TR && (PCI || ISA && ISA_DMA_API || MCA)
+	depends on PCI || ISA && ISA_DMA_API || MCA
 	select FW_LOADER
 	---help---
 	  This driver provides generic support for token ring adapters
@@ -108,7 +108,7 @@ config TMS380TR
 
 config TMSPCI
 	tristate "Generic TMS380 PCI support"
-	depends on TR && TMS380TR && PCI
+	depends on TMS380TR && PCI
 	---help---
 	  This tms380 module supports generic TMS380-based PCI cards.
 
@@ -123,7 +123,7 @@ config TMSPCI
 
 config SKISA
 	tristate "SysKonnect TR4/16 ISA support"
-	depends on TR && TMS380TR && ISA
+	depends on TMS380TR && ISA
 	help
 	  This tms380 module supports SysKonnect TR4/16 ISA cards.
 
@@ -135,7 +135,7 @@ config SKISA
 
 config PROTEON
 	tristate "Proteon ISA support"
-	depends on TR && TMS380TR && ISA
+	depends on TMS380TR && ISA
 	help
 	  This tms380 module supports Proteon ISA cards.
 
@@ -148,7 +148,7 @@ config PROTEON
 
 config ABYSS
 	tristate "Madge Smart 16/4 PCI Mk2 support"
-	depends on TR && TMS380TR && PCI
+	depends on TMS380TR && PCI
 	help
 	  This tms380 module supports the Madge Smart 16/4 PCI Mk2
 	  cards (51-02).
@@ -158,7 +158,7 @@ config ABYSS
 
 config MADGEMC
 	tristate "Madge Smart 16/4 Ringnode MicroChannel"
-	depends on TR && TMS380TR && MCA
+	depends on TMS380TR && MCA
 	help
 	  This tms380 module supports the Madge Smart 16/4 MC16 and MC32
 	  MicroChannel adapters.
@@ -168,7 +168,7 @@ config MADGEMC
 
 config SMCTR
 	tristate "SMC ISA/MCA adapter support"
-	depends on TR && (ISA || MCA_LEGACY) && (BROKEN || !64BIT)
+	depends on (ISA || MCA_LEGACY) && (BROKEN || !64BIT)
 	---help---
 	  This is support for the ISA and MCA SMC Token Ring cards,
 	  specifically SMC TokenCard Elite (8115T) and SMC TokenCard Elite/A
@@ -182,5 +182,4 @@ config SMCTR
 	  To compile this driver as a module, choose M here: the module will be
 	  called smctr.
 
-endmenu
-
+endif # TR
_
