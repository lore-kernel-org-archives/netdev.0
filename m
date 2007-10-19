From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/8] [MV643XX_ETH] Split off mv643xx_eth platform device data
Date: Fri, 19 Oct 2007 04:09:53 +0200
Message-ID: <20071019020953.GC16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43982 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbXJSCJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:09:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv643xx ethernet silicon block is also found in a couple of other
Marvell chips.  As a first step towards splitting off the mv643xx_eth
bits from the rest of the mv643xx bits, this patch splits the mv643xx
ethernet platform device data struct in linux/mv643xx.h off into
linux/mv643xx_eth.h, and includes the latter from the former.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/include/linux/mv643xx.h
===================================================================
--- linux-2.6.orig/include/linux/mv643xx.h
+++ linux-2.6/include/linux/mv643xx.h
@@ -14,6 +14,7 @@
 #define __ASM_MV643XX_H
 
 #include <asm/types.h>
+#include <linux/mv643xx_eth.h>
 
 /****************************************/
 /* Processor Address Space              */
@@ -658,9 +659,6 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV643XX_ETH_SHARED_REGS                                     0x2000
-#define MV643XX_ETH_SHARED_REGS_SIZE                                0x2000
-
 #define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
 #define MV643XX_ETH_SMI_REG                                         0x2004
 #define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
@@ -1280,28 +1278,6 @@ struct mv64xxx_i2c_pdata {
 
 #define MV643XX_ETH_DESC_SIZE				64
 
-#define MV643XX_ETH_SHARED_NAME	"mv643xx_eth_shared"
-#define MV643XX_ETH_NAME	"mv643xx_eth"
-
-struct mv643xx_eth_platform_data {
-	int		port_number;
-	u16		force_phy_addr;	/* force override if phy_addr == 0 */
-	u16		phy_addr;
-
-	/* If speed is 0, then speed and duplex are autonegotiated. */
-	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
-	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
-
-	/* non-zero values of the following fields override defaults */
-	u32		tx_queue_size;
-	u32		rx_queue_size;
-	u32		tx_sram_addr;
-	u32		tx_sram_size;
-	u32		rx_sram_addr;
-	u32		rx_sram_size;
-	u8		mac_addr[6];	/* mac address if non-zero*/
-};
-
 /* Watchdog Platform Device, Driver Data */
 #define	MV64x60_WDT_NAME			"mv64x60_wdt"
 
Index: linux-2.6/include/linux/mv643xx_eth.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/mv643xx_eth.h
@@ -0,0 +1,31 @@
+/*
+ * MV-643XX ethernet platform device data definition file.
+ */
+#ifndef __LINUX_MV643XX_ETH_H
+#define __LINUX_MV643XX_ETH_H
+
+#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
+#define MV643XX_ETH_NAME		"mv643xx_eth"
+#define MV643XX_ETH_SHARED_REGS		0x2000
+#define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
+
+struct mv643xx_eth_platform_data {
+	int		port_number;
+	u16		force_phy_addr;	/* force override if phy_addr == 0 */
+	u16		phy_addr;
+
+	/* If speed is 0, then speed and duplex are autonegotiated. */
+	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
+	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
+
+	/* non-zero values of the following fields override defaults */
+	u32		tx_queue_size;
+	u32		rx_queue_size;
+	u32		tx_sram_addr;
+	u32		tx_sram_size;
+	u32		rx_sram_addr;
+	u32		rx_sram_size;
+	u8		mac_addr[6];	/* mac address if non-zero*/
+};
+
+#endif /* __LINUX_MV643XX_ETH_H */
