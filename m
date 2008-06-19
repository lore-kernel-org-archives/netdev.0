From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 6/8]  pxa: make lubbock to use smc91x platform data
Date: Thu, 19 Jun 2008 19:08:58 +0800
Message-ID: <485A3E4A.6070706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:44343 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbYFSLJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:09:05 -0400
Received: by ti-out-0910.google.com with SMTP id b6so320079tic.23
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:09:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/lubbock.c |    8 ++++++++
 drivers/net/smc91x.h        |   19 +------------------
 2 files changed, 9 insertions(+), 18 deletions(-)

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
index 3ce1ca4..1d9b57f 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -40,24 +40,7 @@
  * Define your architecture specific bus configuration parameters here.
  */
 
-#if	defined(CONFIG_ARCH_LUBBOCK)
-
-/* We can only do 16-bit reads and writes in the static memory space. */
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-#define SMC_NOWAIT		1
-
-/* The first two address lines aren't connected... */
-#define SMC_IO_SHIFT		2
-
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-#define SMC_IRQ_FLAGS		(-1)	/* from resource */
-
-#elif defined(CONFIG_BLACKFIN)
+#if defined(CONFIG_BLACKFIN)
 
 #define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
-- 
1.5.4.3

