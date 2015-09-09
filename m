From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Wed, 9 Sep 2015 03:23:27 +0200
Message-ID: <55EF8A0F.7070106@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
 <55EF43E9.2040000@tul.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bubo.tul.cz ([147.230.16.1]:55850 "EHLO bubo.tul.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916AbbIIBTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 21:19:11 -0400
In-Reply-To: <55EF43E9.2040000@tul.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 8.9.2015 v 22:24 Petr Cvek napsal(a):
> 
> Did you defined resources somewhere? Actual resources are in "pxa_ir_resources" variable at:
> 
> 	http://lxr.free-electrons.com/source/arch/arm/mach-pxa/devices.c#L386
> 
> or this pdata should be moved into specific machine files?
> 

I tried to add following patch for new resources, but now it fails with:

[  141.534545] pxa2xx-ir pxa2xx-ir: can't request region for resource [mem 0x40700000-0x40700100]
[  141.534574] pxa2xx-ir pxa2xx-ir: resource stuart not defined
[  141.534656] pxa2xx-ir: probe of pxa2xx-ir failed with error -16

That's because STUART is allocated by normal UART driver at:

	http://lxr.free-electrons.com/source/arch/arm/mach-pxa/devices.c#L244

So somehow there must be configuration for STUART used with FICP and STUART alone (probably can be used for normal UART).


diff --git a/arch/arm/mach-pxa/devices.c b/arch/arm/mach-pxa/devices.c
index 3543466..316ffa3 100644
--- a/arch/arm/mach-pxa/devices.c
+++ b/arch/arm/mach-pxa/devices.c
@@ -394,6 +394,26 @@ static struct resource pxa_ir_resources[] = {
 		.end    = IRQ_ICP,
 		.flags  = IORESOURCE_IRQ,
 	},
+	[2] = {
+		.start  = 0x40800000,
+		.end    = 0x40800000 + 0x100,
+		.flags  = IORESOURCE_MEM,
+	},
+	[3] = {
+		.start  = 0x40700000,
+		.end    = 0x40700000 + 0x100,
+		.flags  = IORESOURCE_MEM,
+	},
+	[4] = {
+		.start  = 17,
+		.end    = 17,
+		.flags  = IORESOURCE_DMA,
+	},
+	[5] = {
+		.start  = 18,
+		.end    = 18,
+		.flags  = IORESOURCE_DMA,
+	},
 };
 
 struct platform_device pxa_device_ficp = {
-- 
1.7.12.1
