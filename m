From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [RFC/PATCH 2.6.20-rc6 3/4] spidernet: add support for Celleb
Date: Fri, 02 Feb 2007 19:31:56 +0900 (JST)
Message-ID: <200702021031.l12AVv4v020268@toshiba.co.jp>
References: <200702011204.30526.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim@jklewis.com, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:34488 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbXBBKdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 05:33:24 -0500
In-Reply-To: <200702011204.30526.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds or changes some HW specific settings for spider_net on
Celleb.

This patch is just for a test. Please try this, if you can.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

--- org-linux-powerpc-git/drivers/net/Kconfig	2007-02-02 14:34:19.000000000 +0900
+++ linux-powerpc-git/drivers/net/Kconfig	2007-02-02 14:32:18.000000000 +0900
@@ -2256,7 +2256,7 @@
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && PPC_IBM_CELL_BLADE
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
 	select FW_LOADER
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
--- org-linux-powerpc-git/drivers/net/spider_net.h	2007-02-02 14:29:13.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.h	2007-02-02 14:32:18.000000000 +0900
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -184,7 +185,8 @@
 
 /* pause frames: automatic, no upper retransmission count */
 /* outside loopback mode: ETOMOD signal dont matter, not connected */
-#define SPIDER_NET_OPMODE_VALUE		0x00000063
+/* ETOMOD signal is brought to PHY reset. bit 2 must be 1 in Celleb */
+#define SPIDER_NET_OPMODE_VALUE		0x00000067
 /*#define SPIDER_NET_OPMODE_VALUE		0x001b0062*/
 #define SPIDER_NET_LENLMT_VALUE		0x00000908
 
--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-02-02 14:31:39.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-02-02 14:32:18.000000000 +0900
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -1618,6 +1619,11 @@
 
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
+
+	/* trigger ETOMOD signal */
+	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
+		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
+
 }
 
 /**
