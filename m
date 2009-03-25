From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 10/10] Neterion: New driver: Kconfig and Makefile
Date: 25 Mar 2009 00:13:48 -0800
Message-ID: <1237968828.1655.280.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:43837 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714AbZCYH3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Kconfig and Makefile related changes for vxge driver.
- Changes from previous submission -
 - Incorporated the following review comments as per Bill Flink:
        - Add dependancy on INET along with PCI
        - Remove dependancy on INET_LRO and add GRO support.
 - Made this patch as last patch as per Ben Hutchings comments.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch_9/drivers/net/Kconfig patch_10/drivers/net/Kconfig
--- patch_9/drivers/net/Kconfig	2009-03-23 09:48:47.000000000 -0700
+++ patch_10/drivers/net/Kconfig	2009-03-23 09:40:29.000000000 -0700
@@ -2531,6 +2531,23 @@ config S2IO
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/s2io.txt>.
 
+config VXGE
+	tristate "Neterion X3100 Series 10GbE PCIe Server Adapter"
+	depends on PCI && INET
+	---help---
+	   This driver supports Neterion Inc's X3100 Series 10 GbE PCIe
+	   I/O Virtualized Server Adapter.
+	   More specific information on configuring the driver is in
+	   <file:Documentation/networking/vxge.txt>.
+
+config VXGE_DEBUG_TRACE_ALL
+	bool "Enabling All Debug trace statments in driver"
+	default n
+	depends on VXGE
+	---help---
+	  Say Y here if you want to enabling all the debug trace statements in
+	  driver. By  default only few debug trace statements are enabled.
+
 config MYRI10GE
 	tristate "Myricom Myri-10G Ethernet support"
 	depends on PCI && INET
diff -Nurp patch_9/drivers/net/Makefile patch_10/drivers/net/Makefile
--- patch_9/drivers/net/Makefile	2009-03-23 09:17:41.000000000 -0700
+++ patch_10/drivers/net/Makefile	2009-03-23 09:17:41.000000000 -0700
@@ -219,6 +219,7 @@ obj-$(CONFIG_R8169) += r8169.o
 obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
+obj-$(CONFIG_VXGE) += vxge/
 obj-$(CONFIG_MYRI10GE) += myri10ge/
 obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
diff -Nurp patch_9/drivers/net/vxge/Makefile patch_10/drivers/net/vxge/Makefile
--- patch_9/drivers/net/vxge/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ patch_10/drivers/net/vxge/Makefile	2009-03-23 09:17:41.000000000 -0700
@@ -0,0 +1,7 @@
+#
+# Makefile for Neterion Inc's X3100 Series 10 GbE PCIe # I/O
+# Virtualized Server Adapter linux driver
+
+obj-$(CONFIG_VXGE) += vxge.o
+
+vxge-objs := vxge-config.o vxge-traffic.o vxge-ethtool.o vxge-main.o



