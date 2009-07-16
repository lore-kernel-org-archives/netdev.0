From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] Add mac resource support for w90p910
Date: Thu, 16 Jul 2009 20:49:38 +0800
Message-ID: <4A5F21E2.90307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Russell King <linux@arm.linux.org.uk>,
	"Er
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:4962 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbZGPMtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 08:49:46 -0400
Received: by rv-out-0506.google.com with SMTP id f6so23895rvb.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 05:49:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Russell,

This is a mac resource define for my MAC driver for w90p910 platform.

thanks!

Add mac resource support for w90p910 mac driver

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>
---
 arch/arm/mach-w90x900/mach-w90p910evb.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-w90x900/mach-w90p910evb.c b/arch/arm/mach-w90x900/mach-w90p910evb.c
index 7a62bd3..06e1155 100644
--- a/arch/arm/mach-w90x900/mach-w90p910evb.c
+++ b/arch/arm/mach-w90x900/mach-w90p910evb.c
@@ -228,6 +228,33 @@ struct platform_device w90x900_device_usbgadget = {
 };
 EXPORT_SYMBOL(w90x900_device_usbgadget);
 
+/* EMC Device */
+
+static struct resource w90x900_emc_resource[] = {
+	[0] = {
+		.start = W90X900_PA_EMC,
+		.end   = W90X900_PA_EMC + W90X900_SZ_EMC - 1,
+		.flags = IORESOURCE_MEM,
+	},
+	[1] = {
+		.start = IRQ_EMCTX,
+		.end   = IRQ_EMCTX,
+		.flags = IORESOURCE_IRQ,
+	},
+	[2] = {
+		.start = IRQ_EMCRX,
+		.end   = IRQ_EMCRX,
+		.flags = IORESOURCE_IRQ,
+	}
+};
+
+struct platform_device w90p910_device_emc = {
+	.name		= "w90p910-emc",
+	.id		= -1,
+	.num_resources	= ARRAY_SIZE(w90x900_emc_resource),
+	.resource	= w90x900_emc_resource,
+};
+
 static struct map_desc w90p910_iodesc[] __initdata = {
 };
 
@@ -242,6 +269,7 @@ static struct platform_device *w90p910evb_dev[] __initdata = {
 	&w90x900_device_rtc,
 	&w90x900_device_kpi,
 	&w90x900_device_usbgadget,
+	&w90p910_device_emc,
 };
 
 static void __init w90p910evb_map_io(void)
-- 
1.5.6.3
