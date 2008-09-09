From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 1/3] enic: add Makefile, patch Kconfig, MAINTAINERS, etc
Date: Mon, 8 Sep 2008 20:57:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809082045200.18196@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:7102 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753003AbYIID6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 23:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: add Makefile, patch Kconfig, MAINTAINERS, etc

Adds driver/net/enic/Makefile, add the enic (10G Ethernet) option to the 
net Kconfig.  Add PCI vendor ID for Cisco.  Updates MAINTAINERS to add an 
entry for the enic driver.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/Makefile linux-2.6.26.3-enic/drivers/net/enic/Makefile
--- linux-2.6.26.3/drivers/net/enic/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/Makefile	2008-08-22 13:41:41.000000000 -0700
@@ -0,0 +1,5 @@
+obj-$(CONFIG_ENIC) := enic.o
+
+enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
+	enic_res.o vnic_dev.o vnic_rq.o
+
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/Kconfig linux-2.6.26.3-enic/drivers/net/Kconfig
--- linux-2.6.26.3/drivers/net/Kconfig	2008-08-20 11:11:37.000000000 -0700
+++ linux-2.6.26.3-enic/drivers/net/Kconfig	2008-08-26 10:43:30.000000000 -0700
@@ -2527,6 +2527,13 @@ config MYRI10GE
  	  To compile this driver as a module, choose M here. The module
  	  will be called myri10ge.

+config ENIC
+	tristate "Cisco 10G Ethernet NIC"
+	depends on PCI && INET
+	select INET_LRO
+	help
+	  This enables the support for Cisco 10G Ethernet card.
+
  config NETXEN_NIC
  	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
  	depends on PCI
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/Makefile linux-2.6.26.3-enic/drivers/net/Makefile
--- linux-2.6.26.3/drivers/net/Makefile	2008-08-20 11:11:37.000000000 -0700
+++ linux-2.6.26.3-enic/drivers/net/Makefile	2008-08-22 13:59:05.000000000 -0700
@@ -18,6 +18,7 @@ obj-$(CONFIG_BONDING) += bonding/
  obj-$(CONFIG_ATL1) += atlx/
  obj-$(CONFIG_GIANFAR) += gianfar_driver.o
  obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_ENIC) += enic/

  gianfar_driver-objs := gianfar.o \
  		gianfar_ethtool.o \
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/include/linux/pci_ids.h linux-2.6.26.3-enic/include/linux/pci_ids.h
--- linux-2.6.26.3/include/linux/pci_ids.h	2008-08-20 11:11:37.000000000 -0700
+++ linux-2.6.26.3-enic/include/linux/pci_ids.h	2008-09-02 10:49:20.000000000 -0700
@@ -1410,6 +1410,8 @@
  #define PCI_DEVICE_ID_EICON_MAESTRAQ_U	0xe013
  #define PCI_DEVICE_ID_EICON_MAESTRAP	0xe014

+#define PCI_VENDOR_ID_CISCO		0x1137
+
  #define PCI_VENDOR_ID_ZIATECH		0x1138
  #define PCI_DEVICE_ID_ZIATECH_5550_HC	0x5550

diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/MAINTAINERS linux-2.6.26.3-enic/MAINTAINERS
--- linux-2.6.26.3/MAINTAINERS	2008-08-20 11:11:37.000000000 -0700
+++ linux-2.6.26.3-enic/MAINTAINERS	2008-08-22 14:08:29.000000000 -0700
@@ -1054,6 +1054,13 @@ L:	cbe-oss-dev@ozlabs.org
  W:	http://www.ibm.com/developerworks/power/cell/
  S:	Supported

+CISCO 10G ETHERNET DRIVER
+P:	Scott Feldman
+M:	scofeldm@cisco.com
+P:	Joe Eykholt
+M:	jeykholt@cisco.com
+S:	Supported
+
  CFAG12864B LCD DRIVER
  P:	Miguel Ojeda Sandonis
  M:	miguel.ojeda.sandonis@gmail.com
