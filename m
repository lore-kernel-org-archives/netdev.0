From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 6/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 9 Feb 2010 22:29:15 -0800
Message-ID: <201002100629.o1A6TFJt026443@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: adapter_linux_open_src_team@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:53613 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab0BJGeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 01:34:37 -0500
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

diff -ruP net-next-2.6.33-rc5-orig/drivers/net/Kconfig net-next-2.6.33-rc5-mod/drivers/net/Kconfig
--- net-next-2.6.33-rc5-orig/drivers/net/Kconfig	2010-02-05 20:04:14.000000000 -0800
+++ net-next-2.6.33-rc5-mod/drivers/net/Kconfig	2010-02-09 22:16:39.218095000 -0800
@@ -2792,6 +2792,21 @@
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
diff -ruP net-next-2.6.33-rc5-orig/drivers/net/Makefile net-next-2.6.33-rc5-mod/drivers/net/Makefile
--- net-next-2.6.33-rc5-orig/drivers/net/Makefile	2010-02-05 20:04:14.000000000 -0800
+++ net-next-2.6.33-rc5-mod/drivers/net/Makefile	2010-02-09 22:16:39.223093000 -0800
@@ -32,6 +32,7 @@
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_BE2NET) += benet/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
+obj-$(CONFIG_BNA) += bna/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff -ruP net-next-2.6.33-rc5-orig/drivers/net/bna/Makefile net-next-2.6.33-rc5-mod/drivers/net/bna/Makefile
--- net-next-2.6.33-rc5-orig/drivers/net/bna/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.33-rc5-mod/drivers/net/bna/Makefile	2010-02-09 22:16:39.250092000 -0800
@@ -0,0 +1,14 @@
+#
+# Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+# All rights reserved.
+#
+
+obj-$(CONFIG_BNA) += bna.o
+
+bna-objs := bnad.o bnad_ethtool.o bna_fn.o bna_if.o bna_queue.o
+bna-objs += bfad_fwimg.o bfa_csdebug.o bfa_sm.o bfa_ioc.o bfa_ioc_ct.o
+bna-objs += bfa_cee.o
+
+EXTRA_CFLAGS := -Idrivers/net/bna -Idrivers/net/bna/include/cee
+EXTRA_CFLAGS +=	-Idrivers/net/bna/include -Idrivers/net/bna/include/cs
+EXTRA_CFLAGS +=	-Idrivers/net/bna/include/cna/pstats
