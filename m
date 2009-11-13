From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 6/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 12 Nov 2009 19:46:52 -0800
Message-ID: <200911130346.nAD3kqGt001069@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:12044 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbZKMDrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 22:47:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 6/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
Source is based against net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 Kconfig      |   15 +++++++++++++++
 Makefile     |    1 +
 bna/Makefile |   14 ++++++++++++++
 3 files changed, 30 insertions(+)

diff -ruP net-next-2.6-orig/drivers/net/Kconfig net-next-2.6-mod/drivers/net/Kconfig
--- net-next-2.6-orig/drivers/net/Kconfig	2009-10-31 00:44:29.000000000 -0700
+++ net-next-2.6-mod/drivers/net/Kconfig	2009-11-12 19:09:25.474471000 -0800
@@ -2757,6 +2757,21 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called qlge.
 
+config BNA
+        tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+        depends on PCI
+        ---help---
+          This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
+          cards.
+
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
diff -ruP net-next-2.6-orig/drivers/net/Makefile net-next-2.6-mod/drivers/net/Makefile
--- net-next-2.6-orig/drivers/net/Makefile	2009-10-31 00:44:29.000000000 -0700
+++ net-next-2.6-mod/drivers/net/Makefile	2009-11-12 19:09:25.480478000 -0800
@@ -31,6 +31,7 @@
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_BE2NET) += benet/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
+obj-$(CONFIG_BNA) += bna/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff -ruP net-next-2.6-orig/drivers/net/bna/Makefile net-next-2.6-mod/drivers/net/bna/Makefile
--- net-next-2.6-orig/drivers/net/bna/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6-mod/drivers/net/bna/Makefile	2009-11-12 19:09:25.502466000 -0800
@@ -0,0 +1,14 @@
+#
+# Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+# All rights reserved.
+#
+
+obj-$(CONFIG_BNA) += bna.o
+
+bna-objs := bnad.o bnad_ethtool.o bna_fn.o bna_if.o bna_queue.o
+bna-objs += bfad_fwimg.o bfa_csdebug.o bfa_sm.o bfa_ioc.o
+bna-objs += bfa_timer.o bfa_cee.o
+
+EXTRA_CFLAGS := -Idrivers/net/bna -Idrivers/net/bna/include/cee
+EXTRA_CFLAGS +=	-Idrivers/net/bna/include -Idrivers/net/bna/include/cs
+EXTRA_CFLAGS +=	-Idrivers/net/bna/include/cna/pstats
