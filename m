From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 02:08:21 +0200
Message-ID: <200708110208.21624.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41640
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757663AbXHKAI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:08:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the SSB dependency hell and introduces some
fake-options that only give some advice on what to select.

We live with these fake options only until menuconfig is able
to tell more about needed dependencies and how to resolve them.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

--

I think this should be merged into the ssb branch of
wireless-dev, unless you plan to maintain a seperate branch
for b44-ssb. But I think merging it with the ssb core is
probably OK.

Index: wireless-dev/drivers/net/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/Kconfig	2007-08-10 13:40:34.000000000 +0200
+++ wireless-dev/drivers/net/Kconfig	2007-08-10 13:42:18.000000000 +0200
@@ -1452,10 +1452,31 @@ config APRICOT
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called apricot.
 
+config B44_DEP_HACK
+	bool
+	depends on SSB && SSB_PCIHOST && SSB_DRIVER_PCICORE
+	default y
+
+config B44_ADVICE_HACK
+	bool "B44 for PCI not available. Read the help text of this option!"
+	depends on !B44_DEP_HACK
+	---help---
+	  The Broadcom 440x/47xx driver for PCI devices can not be enabled,
+	  because the required dependencies are not selected.
+
+	  In order to be able to select the Broadcom 440x/47xx PCI driver, you
+	  need to enable the following options first:
+
+	  CONFIG_SSB found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Sonics Silicon Backplane support
+	  CONFIG_SSB_PCIHOST found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Support for SSB on PCI-bus host
+	  CONFIG_SSB_DRIVER_PCICORE found in menu:
+	  Device Drivers/Sonics Silicon Backplane/SSB PCI core driver
+
 config B44
 	tristate "Broadcom 440x/47xx ethernet support"
-	depends on HAS_IOMEM
-	select SSB
+	depends on SSB
 	select MII
 	help
 	  If you have a network (Ethernet) controller of this type, say Y
@@ -1473,9 +1494,7 @@ config B44
 
 config B44_PCI
 	bool "Broadcom 440x PCI device support"
-	depends on B44 && NET_PCI
-	select SSB_PCIHOST
-	select SSB_DRIVER_PCICORE
+	depends on B44 && SSB_PCIHOST && SSB_DRIVER_PCICORE && NET_PCI
 	default y
 	help
 	  Support for Broadcom 440x PCI devices.
