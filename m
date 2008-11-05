From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 4/6] smsc911x: convert ap325rxa platform to use smsc911x
Date: Wed,  5 Nov 2008 10:35:40 +0000
Message-ID: <1225881342-3485-5-git-send-email-steve.glendinning@smsc.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-4-git-send-email-steve.glendinning@smsc.com>
Cc: catalin.marinas@arm.com, Bahadir.Balban@arm.com,
	dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:57504 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754315AbYKEKfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:35:50 -0500
In-Reply-To: <1225881342-3485-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/sh/boards/board-ap325rxa.c    |   24 +++++++++++++-----------
 arch/sh/configs/ap325rxa_defconfig |   21 +++++++++++++++++++--
 2 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/arch/sh/boards/board-ap325rxa.c b/arch/sh/boards/board-ap325rxa.c
index 8881a64..fe5d8c9 100644
--- a/arch/sh/boards/board-ap325rxa.c
+++ b/arch/sh/boards/board-ap325rxa.c
@@ -18,7 +18,7 @@
 #include <linux/mtd/sh_flctl.h>
 #include <linux/delay.h>
 #include <linux/i2c.h>
-#include <linux/smc911x.h>
+#include <linux/smsc911x.h>
 #include <linux/gpio.h>
 #include <media/soc_camera_platform.h>
 #include <media/sh_mobile_ceu.h>
@@ -27,12 +27,14 @@
 #include <asm/clock.h>
 #include <cpu/sh7723.h>
 
-static struct smc911x_platdata smc911x_info = {
-	.flags = SMC911X_USE_32BIT,
-	.irq_flags = IRQF_TRIGGER_LOW,
+static struct smsc911x_platform_config smsc911x_config = {
+	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags = SMSC911X_USE_32BIT,
+	.phy_interface = PHY_INTERFACE_MODE_MII,
 };
 
-static struct resource smc9118_resources[] = {
+static struct resource smsc9118_resources[] = {
 	[0] = {
 		.start	= 0xb6080000,
 		.end	= 0xb60fffff,
@@ -45,13 +47,13 @@ static struct resource smc9118_resources[] = {
 	}
 };
 
-static struct platform_device smc9118_device = {
-	.name		= "smc911x",
+static struct platform_device smsc9118_device = {
+	.name		= "smsc911x",
 	.id		= -1,
-	.num_resources	= ARRAY_SIZE(smc9118_resources),
-	.resource	= smc9118_resources,
+	.num_resources	= ARRAY_SIZE(smsc9118_resources),
+	.resource	= smsc9118_resources,
 	.dev		= {
-		.platform_data = &smc911x_info,
+		.platform_data = &smsc911x_config,
 	},
 };
 
@@ -311,7 +313,7 @@ static struct platform_device ceu_device = {
 };
 
 static struct platform_device *ap325rxa_devices[] __initdata = {
-	&smc9118_device,
+	&smsc9118_device,
 	&ap325rxa_nor_flash_device,
 	&lcdc_device,
 	&ceu_device,
diff --git a/arch/sh/configs/ap325rxa_defconfig b/arch/sh/configs/ap325rxa_defconfig
index 874dd97..9317e81 100644
--- a/arch/sh/configs/ap325rxa_defconfig
+++ b/arch/sh/configs/ap325rxa_defconfig
@@ -541,13 +541,30 @@ CONFIG_NETDEVICES=y
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
 # CONFIG_VETH is not set
-# CONFIG_PHYLIB is not set
+CONFIG_PHYLIB=y
+
+#
+# MII PHY device drivers
+#
+# CONFIG_MARVELL_PHY is not set
+# CONFIG_DAVICOM_PHY is not set
+# CONFIG_QSEMI_PHY is not set
+# CONFIG_LXT_PHY is not set
+# CONFIG_CICADA_PHY is not set
+# CONFIG_VITESSE_PHY is not set
+CONFIG_SMSC_PHY=y
+# CONFIG_BROADCOM_PHY is not set
+# CONFIG_ICPLUS_PHY is not set
+# CONFIG_REALTEK_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
 # CONFIG_AX88796 is not set
 # CONFIG_STNIC is not set
 # CONFIG_SMC91X is not set
-CONFIG_SMC911X=y
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
-- 
1.5.6.5

