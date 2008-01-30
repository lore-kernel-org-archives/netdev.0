From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 5/8] [Blackfin] EMAC driver: ADSP-BF52x arch/mach support
Date: Wed, 30 Jan 2008 16:52:25 +0800
Message-ID: <1201683148-23931-6-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:46159 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbYA3Iwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:39 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/Kconfig    |    9 +++++----
 drivers/net/bfin_mac.c |    6 +++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5a2d1dd..ca2552b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -814,8 +814,8 @@ config ULTRA32
 	  will be called smc-ultra32.
 
 config BFIN_MAC
-	tristate "Blackfin 536/537 on-chip mac support"
-	depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
+	tristate "Blackfin 527/536/537 on-chip mac support"
+	depends on NET_ETHERNET && (BF527 || BF537 || BF536) && (!BF537_PORT_H)
 	select CRC32
 	select MII
 	select PHYLIB
@@ -828,7 +828,7 @@ config BFIN_MAC
 
 config BFIN_MAC_USE_L1
 	bool "Use L1 memory for rx/tx packets"
-	depends on BFIN_MAC && BF537
+	depends on BFIN_MAC && (BF527 || BF537)
 	default y
 	help
 	  To get maximum network performance, you should use L1 memory as rx/tx buffers.
@@ -855,7 +855,8 @@ config BFIN_RX_DESC_NUM
 config BFIN_MAC_RMII
 	bool "RMII PHY Interface (EXPERIMENTAL)"
 	depends on BFIN_MAC && EXPERIMENTAL
-	default n
+	default y if BFIN527_EZKIT
+	default n if BFIN537_STAMP
 	help
 	  Use Reduced PHY MII Interface
 
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index ed935e1..e9bd059 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -42,7 +42,7 @@
 #define DRV_NAME	"bfin_mac"
 #define DRV_VERSION	"1.1"
 #define DRV_AUTHOR	"Bryan Wu, Luke Yang"
-#define DRV_DESC	"Blackfin BF53[67] on-chip Ethernet MAC driver"
+#define DRV_DESC	"Blackfin BF53[67] BF527 on-chip Ethernet MAC driver"
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_LICENSE("GPL");
@@ -752,7 +752,7 @@ static void bf537mac_enable(void)
 
 #if defined(CONFIG_BFIN_MAC_RMII)
 	opmode |= RMII; /* For Now only 100MBit are supported */
-#ifdef CONFIG_BF_REV_0_2
+#if (defined(CONFIG_BF537) || defined(CONFIG_BF536)) && CONFIG_BF_REV_0_2
 	opmode |= TE;
 #endif
 #endif
@@ -994,7 +994,7 @@ static int __init bf537mac_probe(struct net_device *dev)
 	/* register irq handler */
 	if (request_irq
 	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
-	     "BFIN537_MAC_RX", dev)) {
+	     "EMAC_RX", dev)) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Unable to attach BlackFin MAC RX interrupt\n");
 		return -EBUSY;
-- 
1.5.3.4
