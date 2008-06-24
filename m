From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 10/10] pxa: make littleton to use the new smc91x platform data
Date: Tue, 24 Jun 2008 17:47:47 +0800
Message-ID: <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:44710 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753456AbYFXJrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 05:47:41 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.miao@marvell.com>

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/littleton.c |    9 +++++++++
 drivers/net/smc91x.h          |    3 ++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-pxa/littleton.c b/arch/arm/mach-pxa/littleton.c
index 9a4f51d..dd759d0 100644
--- a/arch/arm/mach-pxa/littleton.c
+++ b/arch/arm/mach-pxa/littleton.c
@@ -20,6 +20,7 @@
 #include <linux/delay.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
+#include <linux/smc91x.h>
 
 #include <asm/types.h>
 #include <asm/setup.h>
@@ -106,11 +107,19 @@ static struct resource smc91x_resources[] = {
 	}
 };
 
+static struct smc91x_platdata littleton_smc91x_info = {
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT |
+		  SMC91X_NOWAIT | SMC91X_USE_DMA,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev		= {
+		.platform_data = &littleton_smc91x_info,
+	},
 };
 
 #if defined(CONFIG_FB_PXA) || defined(CONFIG_FB_PXA_MODULE)
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index d55739c..46ebac8 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -42,7 +42,8 @@
 
 #if defined(CONFIG_ARCH_LUBBOCK) ||\
     defined(CONFIG_MACH_MAINSTONE) ||\
-    defined(CONFIG_MACH_ZYLONITE)
+    defined(CONFIG_MACH_ZYLONITE) ||\
+    defined(CONFIG_MACH_LITTLETON)
 
 #include <asm/mach-types.h>
 
-- 
1.5.4.3

