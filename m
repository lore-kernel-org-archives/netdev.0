From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/8] [MV643XX_ETH] Enable use on Orion platforms
Date: Fri, 19 Oct 2007 04:11:03 +0200
Message-ID: <20071019021103.GF16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:44004 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762752AbXJSCLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:11:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow Orion ARM platforms to use the mv643xx_eth driver.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -2392,13 +2392,16 @@ config UGETH_TX_ON_DEMAND
 	depends on UCC_GETH
 
 config MV643XX_ETH
-	tristate "MV-643XX Ethernet support"
-	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32)
+	tristate "Marvell Discovery (643XX) and Orion ethernet support"
+	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || ARCH_ORION
 	select MII
 	help
-	  This driver supports the gigabit Ethernet on the Marvell MV643XX
-	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
-	  Pegasos II, amongst other PPC and MIPS boards.
+	  This driver supports the gigabit ethernet MACs in the
+	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
+	  in the Marvell Orion ARM SoC family.
+
+	  Some boards that use the Discovery chipset are the Momenco
+	  Ocelot C and Jaguar ATX and Pegasos II.
 
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
Index: linux-2.6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6/drivers/net/mv643xx_eth.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/mv643xx_eth.c - Driver for MV643XX ethernet ports
+ * Driver for Marvell Discovery (MV643XX) and Marvell Orion ethernet ports
  * Copyright (C) 2002 Matthew Dharm <mdharm@momenco.com>
  *
  * Based on the 64360 driver from:
