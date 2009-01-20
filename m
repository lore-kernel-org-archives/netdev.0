From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 4/6] arm: convert realview platform to use smsc911x
Date: Tue, 20 Jan 2009 13:28:32 +0000
Message-ID: <1232458114-10997-5-git-send-email-steve.glendinning@smsc.com>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
 <1232458114-10997-2-git-send-email-steve.glendinning@smsc.com>
 <1232458114-10997-3-git-send-email-steve.glendinning@smsc.com>
 <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:48219 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756056AbZATNbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 08:31:51 -0500
In-Reply-To: <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/arm/mach-realview/core.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

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

