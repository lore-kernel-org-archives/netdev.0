From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 4/5] arm: convert realview platform to use smsc911x
Date: Thu, 15 Jan 2009 09:08:01 +0000
Message-ID: <1232010482-3744-5-git-send-email-steve.glendinning@smsc.com>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
 <1232010482-3744-2-git-send-email-steve.glendinning@smsc.com>
 <1232010482-3744-3-git-send-email-steve.glendinning@smsc.com>
 <1232010482-3744-4-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:49036 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755321AbZAOJHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:07:21 -0500
In-Reply-To: <1232010482-3744-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/arm/configs/realview-smp_defconfig |   24 ++++++++++++++++++++++--
 arch/arm/configs/realview_defconfig     |   24 ++++++++++++++++++++++--
 arch/arm/mach-realview/core.c           |   17 +++++++++--------
 3 files changed, 53 insertions(+), 12 deletions(-)

diff --git a/arch/arm/configs/realview-smp_defconfig b/arch/arm/configs/realview-smp_defconfig
index cd29824..21db4b3 100644
--- a/arch/arm/configs/realview-smp_defconfig
+++ b/arch/arm/configs/realview-smp_defconfig
@@ -496,13 +496,33 @@ CONFIG_NETDEVICES=y
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
-CONFIG_SMC911X=y
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
diff --git a/arch/arm/configs/realview_defconfig b/arch/arm/configs/realview_defconfig
index 7e253f5..9a75c30 100644
--- a/arch/arm/configs/realview_defconfig
+++ b/arch/arm/configs/realview_defconfig
@@ -490,13 +490,33 @@ CONFIG_NETDEVICES=y
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
-CONFIG_SMC911X=y
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index bd2aa4f..820ec25 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -28,7 +28,7 @@
 #include <linux/clocksource.h>
 #include <linux/clockchips.h>
 #include <linux/io.h>
-#include <linux/smc911x.h>
+#include <linux/smsc911x.h>
 
 #include <asm/clkdev.h>
 #include <asm/system.h>
@@ -127,14 +127,15 @@ int realview_flash_register(struct resource *res, u32 num)
 	return platform_device_register(&realview_flash_device);
 }
 
-static struct smc911x_platdata realview_smc911x_platdata = {
-	.flags		= SMC911X_USE_32BIT,
-	.irq_flags	= IRQF_SHARED,
-	.irq_polarity	= 1,
+static struct smsc911x_platform_config smsc911x_config = {
+	.flags		= SMSC911X_USE_32BIT,
+	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.phy_interface	= PHY_INTERFACE_MODE_MII,
 };
 
 static struct platform_device realview_eth_device = {
-	.name		= "smc911x",
+	.name		= "smsc911x",
 	.id		= 0,
 	.num_resources	= 2,
 };
@@ -144,8 +145,8 @@ int realview_eth_register(const char *name, struct resource *res)
 	if (name)
 		realview_eth_device.name = name;
 	realview_eth_device.resource = res;
-	if (strcmp(realview_eth_device.name, "smc911x") == 0)
-		realview_eth_device.dev.platform_data = &realview_smc911x_platdata;
+	if (strcmp(realview_eth_device.name, "smsc911x") == 0)
+		realview_eth_device.dev.platform_data = &smsc911x_config;
 
 	return platform_device_register(&realview_eth_device);
 }
-- 
1.6.0.6

