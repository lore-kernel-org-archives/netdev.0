From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 3/4] spidernet: add support for Celleb
Date: Wed, 17 Jan 2007 19:08:45 +0900 (JST)
Message-ID: <200701171008.l0HA8j5s026642@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch adds or changes some HW specific settings for spider_net on
Celleb.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

--- org-linux-powerpc-git/drivers/net/Kconfig	2007-01-15 10:37:30.000000000 +0900
+++ linux-powerpc-git/drivers/net/Kconfig	2007-01-15 11:06:57.000000000 +0900
@@ -2256,7 +2256,7 @@
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && PPC_IBM_CELL_BLADE
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
 	select FW_LOADER
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
--- org-linux-powerpc-git/drivers/net/spider_net.h	2007-01-15 10:57:19.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.h	2007-01-15 11:06:57.000000000 +0900
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
@@ -183,7 +184,8 @@
 
 /* pause frames: automatic, no upper retransmission count */
 /* outside loopback mode: ETOMOD signal dont matter, not connected */
-#define SPIDER_NET_OPMODE_VALUE		0x00000063
+/* ETOMOD signal is brought to PHY reset. bit 2 must be 1 in Celleb */
+#define SPIDER_NET_OPMODE_VALUE		0x00000067
 /*#define SPIDER_NET_OPMODE_VALUE		0x001b0062*/
 #define SPIDER_NET_LENLMT_VALUE		0x00000908
 
--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-01-15 11:06:10.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-01-15 11:06:57.000000000 +0900
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
@@ -1630,6 +1631,10 @@
 
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
+
+	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
+		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
+
 }
 
 /**
