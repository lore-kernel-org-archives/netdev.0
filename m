From: Jie Yang <Jie.Yang@Atheros.com>
Subject: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 26 Jun 2008 13:37:23 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jeff@garzik.org" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:60191 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753235AbYFZFhZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 01:37:25 -0400
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

Full patch for the Atheros L1E Gigabit Ethernet driver.
Supportring AR8121, AR8113 and AR8114

Signed-off-by: Jie Yang <jie.yang @atheros.com>
---
diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/atl1e/Makefile linux-2.6.25.3.atheros/drivers/net/atl1e/Makefile
--- linux-2.6.25.3.orig/drivers/net/atl1e/Makefile      1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.25.3.atheros/drivers/net/atl1e/Makefile   2008-06-20 11:22:34.000000000 +0800
@@ -0,0 +1,2 @@
+obj-$(CONFIG_ATL1E)    += atl1e.o
+atl1e-y                        += atl1e_main.o atl1e_hw.o atl1e_ethtool.o atl1e_param.o
diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/Kconfig linux-2.6.25.3.atheros/drivers/net/Kconfig
--- linux-2.6.25.3.orig/drivers/net/Kconfig     2008-05-10 12:48:50.000000000 +0800
+++ linux-2.6.25.3.atheros/drivers/net/Kconfig  2008-06-19 18:17:42.000000000 +0800
@@ -2445,6 +2445,32 @@ config ATL1
          To compile this driver as a module, choose M here.  The module
          will be called atl1.

+config ATL1E
+       tristate "Atheros L1e Gigabit Ethernet support (EXPERIMENTAL)"
+       depends on PCI && EXPERIMENTAL
+       select CRC32
+       select MII
+       help
+         This driver supports the Atheros L1E gigabit ethernet adapter.
+
+         To compile this driver as a module, choose M here.  The module
+         will be called atl1e.
+
+config ATL1E_NAPI
+       bool "Use Rx Polling (NAPI)"
+       depends on ATL1E
+       help
+         NAPI is a new driver API designed to reduce CPU and interrupt load
+         when the driver is receiving lots of packets from the card. It is
+         still somewhat experimental and thus not yet enabled by default.
+
+         If your estimated Rx load is 10kpps or more, or if the card will be
+         deployed on potentially unfriendly networks (e.g. in a firewall),
+         then say Y here.
+
+         If in doubt, say N.
+
+
 endif # NETDEV_1000

 #
diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/Makefile linux-2.6.25.3.atheros/drivers/net/Makefile
--- linux-2.6.25.3.orig/drivers/net/Makefile    2008-05-10 12:48:50.000000000 +0800
+++ linux-2.6.25.3.atheros/drivers/net/Makefile 2008-06-20 09:48:38.000000000 +0800
@@ -16,6 +16,7 @@ obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atl1/
+obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o

diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/include/linux/pci_ids.h linux-2.6.25.3.atheros/include/linux/pci_ids.h
--- linux-2.6.25.3.orig/include/linux/pci_ids.h 2008-05-10 12:48:50.000000000 +0800
+++ linux-2.6.25.3.atheros/include/linux/pci_ids.h      2008-06-20 09:43:40.000000000 +0800
@@ -2175,6 +2175,7 @@

 #define PCI_VENDOR_ID_ATTANSIC         0x1969
 #define PCI_DEVICE_ID_ATTANSIC_L1      0x1048
+#define PCI_DEVICE_ID_ATTANSIC_L1E     0x1026

 #define PCI_VENDOR_ID_JMICRON          0x197B
 #define PCI_DEVICE_ID_JMICRON_JMB360   0x2360
