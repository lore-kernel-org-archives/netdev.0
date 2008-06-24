From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 07/10] pxa: make lubbock to use new smc91x platform data
Date: Tue, 24 Jun 2008 17:47:44 +0800
Message-ID: <1214300867-15495-8-git-send-email-eric.y.miao@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:44706 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753076AbYFXJrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 05:47:40 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.miao@marvell.com>

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/lubbock.c |    8 ++++++++
 drivers/net/smc91x.h        |    3 +--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-pxa/lubbock.c b/arch/arm/mach-pxa/lubbock.c
index 429e197..423c883 100644
--- a/arch/arm/mach-pxa/lubbock.c
+++ b/arch/arm/mach-pxa/lubbock.c
@@ -21,6 +21,7 @@
 #include <linux/interrupt.h>
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
+#include <linux/smc91x.h>
 
 #include <linux/spi/spi.h>
 #include <linux/spi/ads7846.h>
@@ -335,11 +336,18 @@ static struct resource smc91x_resources[] = {
 	},
 };
 
+static struct smc91x_platdata lubbock_smc91x_info = {
+	.flags	= SMC91X_USE_16BIT | SMC91X_NOWAIT | SMC91X_IO_SHIFT_2,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= -1,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev		= {
+		.platform_data = &lubbock_smc91x_info,
+	},
 };
 
 static struct resource flash_resources[] = {
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 208dfc8..95ee9ed 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -48,8 +48,7 @@
 #define SMC_CAN_USE_32BIT	0
 #define SMC_NOWAIT		1
 
-/* The first two address lines aren't connected... */
-#define SMC_IO_SHIFT		2
+#define SMC_IO_SHIFT		smc_io_shift
 
 #define SMC_inw(a, r)		readw((a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
-- 
1.5.4.3

