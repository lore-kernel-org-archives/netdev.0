From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 6/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 3 Aug 2010 22:45:36 -0700
Message-ID: <201008040545.o745jaqv030177@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ddutt@brocade.com>, <huangj@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54854 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753983Ab0HDFpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 01:45:39 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o745jdNq009201
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 22:45:39 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.82])
	by mx0b-000f0801.pphosted.com with ESMTP id qf0f1021k-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 22:45:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 6/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
Source is based against net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/Kconfig      |   14 ++++++++++++++
 drivers/net/Makefile     |    1 +
 drivers/net/bna/Makefile |   11 +++++++++++
 include/linux/pci_ids.h  |    3 +++
 4 files changed, 29 insertions(+)

diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/Makefile net-next-2.6.35-rc1-mod/drivers/net/bna/Makefile
--- net-next-2.6.35-rc1-orig/drivers/net/bna/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/Makefile	2010-08-02 17:26:50.137486000 -0700
@@ -0,0 +1,11 @@
+#
+# Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+# All rights reserved.
+#
+
+obj-$(CONFIG_BNA) += bna.o
+
+bna-objs := bnad.o bnad_ethtool.o bna_ctrl.o bna_txrx.o
+bna-objs += bfa_ioc.o bfa_ioc_ct.o bfa_cee.o cna_fwimg.o
+
+EXTRA_CFLAGS := -Idrivers/net/bna
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/Kconfig net-next-2.6.35-rc1-mod/drivers/net/Kconfig
--- net-next-2.6.35-rc1-orig/drivers/net/Kconfig	2010-07-22 19:10:00.000000000 -0700
+++ net-next-2.6.35-rc1-mod/drivers/net/Kconfig	2010-08-02 17:26:50.047478000 -0700
@@ -2859,6 +2859,20 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called qlge.
 
+config BNA
+        tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+        depends on PCI
+        ---help---
+          This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
+          cards.
+          To compile this driver as a module, choose M here: the module
+          will be called bna.
+
+          For general information and support, go to the Brocade support
+          website at:
+
+          <http://support.brocade.com>
+
 source "drivers/net/sfc/Kconfig"
 
 source "drivers/net/benet/Kconfig"
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/Makefile net-next-2.6.35-rc1-mod/drivers/net/Makefile
--- net-next-2.6.35-rc1-orig/drivers/net/Makefile	2010-07-22 19:10:00.000000000 -0700
+++ net-next-2.6.35-rc1-mod/drivers/net/Makefile	2010-08-02 17:26:50.067481000 -0700
@@ -34,6 +34,7 @@
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_BE2NET) += benet/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
+obj-$(CONFIG_BNA) += bna/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff -ruP net-next-2.6.35-rc1-orig/include/linux/pci_ids.h net-next-2.6.35-rc1-mod/include/linux/pci_ids.h
--- net-next-2.6.35-rc1-orig/include/linux/pci_ids.h	2010-07-22 19:10:10.000000000 -0700
+++ net-next-2.6.35-rc1-mod/include/linux/pci_ids.h	2010-08-02 17:26:50.117478000 -0700
@@ -2188,6 +2188,9 @@
 #define PCI_VENDOR_ID_ARIMA		0x161f
 
 #define PCI_VENDOR_ID_BROCADE		0x1657
+#define PCI_DEVICE_ID_BROCADE_CT	0x0014
+#define PCI_DEVICE_ID_BROCADE_FC_8G1P	0x0017
+#define PCI_DEVICE_ID_BROCADE_CT_FC	0x0021
 
 #define PCI_VENDOR_ID_SIBYTE		0x166d
 #define PCI_DEVICE_ID_BCM1250_PCI	0x0001
