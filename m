From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 9/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5Idmb031904@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35855 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbZH2FYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:24:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 9/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/Makefile linux-2.6.30.5-mod/drivers/net/bna/Makefile
--- linux-2.6.30.5-orig/drivers/net/bna/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/Makefile	2009-08-28 21:15:55.977835000 -0700
@@ -0,0 +1,18 @@
+#
+#    Copyright (c) 2005-2008 Brocade Communications Systems, Inc.
+#    All rights reserved.
+#
+
+obj-$(CONFIG_BNA) += bna.o
+
+bna-objs := bnad.o bnad_ethtool.o bna_fn.o bna_if.o bna_queue.o \
+		bfad_fwimg.o bfa_csdebug.o bfa_sm.o \
+		bfa_ioc.o bfa_timer.o bfa_log.o bfa_log_module.o \
+		bfa_cee.o
+
+EXTRA_CFLAGS += -Idrivers/net/bna \
+		-Idrivers/net/bna/include \
+		-Idrivers/net/bna/include/cee \
+		-Idrivers/net/bna/include/pstats \
+		-Idrivers/net/bna/include/cs 
+
diff -ruP linux-2.6.30.5-orig/drivers/net/Kconfig linux-2.6.30.5-mod/drivers/net/Kconfig
--- linux-2.6.30.5-orig/drivers/net/Kconfig	2009-08-16 14:19:38.000000000 -0700
+++ linux-2.6.30.5-mod/drivers/net/Kconfig	2009-08-28 21:15:55.914848000 -0700
@@ -2684,6 +2684,21 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called qlge.
 
+config BNA
+	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+	depends on PCI
+	---help---
+	  This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet 
+	  cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called bna.
+
+	  For general information and support, go to the Brocade support
+	  website at:
+
+	  <http://support.brocade.com>
+
 source "drivers/net/sfc/Kconfig"
 
 source "drivers/net/benet/Kconfig"
diff -ruP linux-2.6.30.5-orig/drivers/net/Makefile linux-2.6.30.5-mod/drivers/net/Makefile
--- linux-2.6.30.5-orig/drivers/net/Makefile	2009-08-16 14:19:38.000000000 -0700
+++ linux-2.6.30.5-mod/drivers/net/Makefile	2009-08-28 21:15:55.935835000 -0700
@@ -24,6 +24,7 @@
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_BE2NET) += benet/
+obj-$(CONFIG_BNA) += bna/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
