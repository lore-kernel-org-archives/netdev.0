From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 8/8] pxa: make littleton to use the smc91x platform data
Date: Thu, 19 Jun 2008 19:11:50 +0800
Message-ID: <485A3EF6.9030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:3208 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757087AbYFSLL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:11:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5103124rvb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:11:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/littleton.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-pxa/littleton.c b/arch/arm/mach-pxa/littleton.c
index 9a4f51d..7931e53 100644
--- a/arch/arm/mach-pxa/littleton.c
+++ b/arch/arm/mach-pxa/littleton.c
@@ -20,6 +20,7 @@
 #include <linux/delay.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
+#include <linux/smc91x.h>
 
 #include <asm/types.h>
 #include <asm/setup.h>
@@ -106,11 +107,18 @@ static struct resource smc91x_resources[] = {
 	}
 };
 
+static struct smc91x_platdata littleton_smc91x_info = {
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_NOWAIT,
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
-- 
1.5.4.3

