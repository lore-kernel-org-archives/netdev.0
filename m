From: Michael Buesch <mb@bu3sch.de>
Subject: b44: Fix Kconfig dependencies by using select
Date: Wed, 15 Aug 2007 15:46:10 +0200
Message-ID: <200708151546.10771.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40617
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762448AbXHONqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 09:46:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev-new/drivers/net/Kconfig
===================================================================
--- wireless-dev-new.orig/drivers/net/Kconfig	2007-08-11 00:49:28.000000000 +0200
+++ wireless-dev-new/drivers/net/Kconfig	2007-08-15 15:29:36.000000000 +0200
@@ -1454,7 +1454,7 @@ config APRICOT
 
 config B44
 	tristate "Broadcom 440x/47xx ethernet support"
-	depends on HAS_IOMEM
+	depends on SSB_POSSIBLE
 	select SSB
 	select MII
 	help
@@ -1462,27 +1462,28 @@ config B44
 	  or M and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you have a Broadcom 440x PCI device (and if you don't
-	  know, you _do_ have one) you must also select the options
-	  "EISA, VLB, PCI and on board controllers" above and
-	  "Broadcom 440x PCI device support" below.
-
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called b44.
 
-config B44_PCI
-	bool "Broadcom 440x PCI device support"
-	depends on B44 && NET_PCI
+# Auto-select SSB PCI-HOST support, if possible
+config B44_PCI_AUTOSELECT
+	bool
+	depends on B44 && SSB_PCIHOST_POSSIBLE
 	select SSB_PCIHOST
+	default y
+
+# Auto-select SSB PCICORE driver, if possible
+config B44_PCICORE_AUTOSELECT
+	bool
+	depends on B44 && SSB_DRIVER_PCICORE_POSSIBLE
 	select SSB_DRIVER_PCICORE
 	default y
-	help
-	  Support for Broadcom 440x PCI devices.
 
-	  Say Y, unless you know what you are doing.
-	  If you say N here I will _not_ listen to your
-	  bugreports!
+config B44_PCI
+	bool
+	depends on B44_PCI_AUTOSELECT && B44_PCICORE_AUTOSELECT
+	default y
 
 config FORCEDETH
 	tristate "nForce Ethernet support"
