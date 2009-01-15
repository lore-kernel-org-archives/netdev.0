From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 3/5] arm: convert pcm037 platform to use smsc911x
Date: Thu, 15 Jan 2009 09:08:00 +0000
Message-ID: <1232010482-3744-4-git-send-email-steve.glendinning@smsc.com>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
 <1232010482-3744-2-git-send-email-steve.glendinning@smsc.com>
 <1232010482-3744-3-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:49031 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755389AbZAOJHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:07:21 -0500
In-Reply-To: <1232010482-3744-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/arm/configs/pcm037_defconfig |   23 ++++++++++++++++++++++-
 arch/arm/mach-mx3/pcm037.c        |   22 ++++++++++++----------
 2 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/arch/arm/configs/pcm037_defconfig b/arch/arm/configs/pcm037_defconfig
index 6274745..6e37c77 100644
--- a/arch/arm/configs/pcm037_defconfig
+++ b/arch/arm/configs/pcm037_defconfig
@@ -465,12 +465,33 @@ CONFIG_NETDEVICES=y
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
+# CONFIG_NATIONAL_PHY is not set
+# CONFIG_STE10XP is not set
+# CONFIG_LSI_ET1011C_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
 # CONFIG_AX88796 is not set
 CONFIG_SMC91X=y
 # CONFIG_DM9000 is not set
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
diff --git a/arch/arm/mach-mx3/pcm037.c b/arch/arm/mach-mx3/pcm037.c
index 8cea825..64a34f6 100644
--- a/arch/arm/mach-mx3/pcm037.c
+++ b/arch/arm/mach-mx3/pcm037.c
@@ -24,7 +24,7 @@
 #include <linux/mtd/plat-ram.h>
 #include <linux/memory.h>
 #include <linux/gpio.h>
-#include <linux/smc911x.h>
+#include <linux/smsc911x.h>
 #include <linux/interrupt.h>
 
 #include <mach/hardware.h>
@@ -64,7 +64,7 @@ static struct imxuart_platform_data uart_pdata = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
 
-static struct resource smc911x_resources[] = {
+static struct resource smsc911x_resources[] = {
 	[0] = {
 		.start		= CS1_BASE_ADDR + 0x300,
 		.end		= CS1_BASE_ADDR + 0x300 + SZ_64K - 1,
@@ -73,22 +73,24 @@ static struct resource smc911x_resources[] = {
 	[1] = {
 		.start		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
 		.end		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
-		.flags		= IORESOURCE_IRQ,
+		.flags		= IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
 	},
 };
 
-static struct smc911x_platdata smc911x_info = {
-	.flags		= SMC911X_USE_32BIT,
-	.irq_flags	= IRQF_SHARED | IRQF_TRIGGER_LOW,
+static struct smsc911x_platform_config smsc911x_info = {
+	.flags		= SMSC911X_USE_32BIT,
+	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.phy_interface	= PHY_INTERFACE_MODE_MII,
 };
 
 static struct platform_device pcm037_eth = {
-	.name		= "smc911x",
+	.name		= "smsc911x",
 	.id		= -1,
-	.num_resources	= ARRAY_SIZE(smc911x_resources),
-	.resource	= smc911x_resources,
+	.num_resources	= ARRAY_SIZE(smsc911x_resources),
+	.resource	= smsc911x_resources,
 	.dev		= {
-		.platform_data = &smc911x_info,
+		.platform_data = &smsc911x_info,
 	},
 };
 
-- 
1.6.0.6

