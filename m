From: Michael Buesch <mb@bu3sch.de>
Subject: b44-ssb: Be more verbose in help texts
Date: Sun, 27 May 2007 17:12:20 +0200
Message-ID: <200705271712.21165.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56774
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257AbXE0PR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 11:17:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some people have difficulties in understanding that the
option "Broadcom 440x PCI device support" is for PCI devices,
so they disable it and complain that it doesn't work anymore.
Try to prevent that with this patch.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: bu3sch-wireless-dev/MAINTAINERS
===================================================================
--- bu3sch-wireless-dev.orig/MAINTAINERS	2007-05-27 16:53:29.000000000 +0200
+++ bu3sch-wireless-dev/MAINTAINERS	2007-05-27 16:54:57.000000000 +0200
@@ -921,6 +921,12 @@
 L:	netdev@vger.kernel.org
 S:	Supported
 
+BROADCOM B44 - SONICS SILICON BACKPLANE (SSB) BITS
+P:	Michael Buesch
+M:	mb@bu3sch.de
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
 P:	Michael Chan
 M:	mchan@broadcom.com
Index: bu3sch-wireless-dev/drivers/net/Kconfig
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/Kconfig	2007-05-27 16:44:39.000000000 +0200
+++ bu3sch-wireless-dev/drivers/net/Kconfig	2007-05-27 16:57:45.000000000 +0200
@@ -1387,28 +1387,35 @@
 	  called apricot.
 
 config B44
-	tristate "Broadcom 4400 ethernet support"
+	tristate "Broadcom 440x/47xx ethernet support"
 	select SSB
 	select MII
 	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
+	  If you have a network (Ethernet) controller of this type, say Y
+	  or M and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
+	  If you have a Broadcom 440x PCI device (and if you don't
+	  know, you _do_ have one) you must also select the options
+	  "EISA, VLB, PCI and on board controllers" above and
+	  "Broadcom 440x PCI device support" below.
+
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called b44.
 
 config B44_PCI
-	bool "Broadcom 4400 PCI device support"
+	bool "Broadcom 440x PCI device support"
 	depends on B44 && NET_PCI
 	select SSB_PCIHOST
 	select SSB_DRIVER_PCICORE
 	default y
 	help
-	  Support for b44 PCI devices.
+	  Support for Broadcom 440x PCI devices.
 
-	  Say Y
+	  Say Y, unless you know what you are doing.
+	  If you say N here I will _not_ listen to your
+	  bugreports!
 
 config FORCEDETH
 	tristate "nForce Ethernet support"

-- 
Greetings Michael.
