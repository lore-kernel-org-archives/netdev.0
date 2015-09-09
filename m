From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Wed, 09 Sep 2015 08:25:30 +0200
Message-ID: <87twr4un1h.fsf@belgarion.home>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
	<1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
	<55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Petr Cvek <petr.cvek@tul.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55EF8A0F.7070106@tul.cz> (Petr Cvek's message of "Wed, 9 Sep
	2015 03:23:27 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petr Cvek <petr.cvek@tul.cz> writes:

> Dne 8.9.2015 v 22:24 Petr Cvek napsal(a):
>> 
>> Did you defined resources somewhere? Actual resources are in
>> "pxa_ir_resources" variable at:
I have them in patch [1], which is exactly the patch you have made yourself.

> I tried to add following patch for new resources, but now it fails with:
>
> [  141.534545] pxa2xx-ir pxa2xx-ir: can't request region for resource [mem 0x40700000-0x40700100]
> [  141.534574] pxa2xx-ir pxa2xx-ir: resource stuart not defined
> [  141.534656] pxa2xx-ir: probe of pxa2xx-ir failed with error -16
>
> That's because STUART is allocated by normal UART driver at:
>
> 	http://lxr.free-electrons.com/source/arch/arm/mach-pxa/devices.c#L244
>
> So somehow there must be configuration for STUART used with FICP and STUART
> alone (probably can be used for normal UART).
That's because you have to remove from magician.c:
	pxa_set_stuart_info(NULL);

Cheers.

--
Robert

[1]
>From ea242c5b1c4dcdf2a99ea604ee542ded5e6384b9 Mon Sep 17 00:00:00 2001
From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 29 Aug 2015 00:37:51 +0200
Subject: [PATCH] ARM: pxa: add resources to pxaficp_ir

Add io memory and dma requestor lines to the irda pxa device. This is
part of the conversion of pxaficp_ir to dmaengine, and to shrink its
adherence to 'mach' includes.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 arch/arm/mach-pxa/devices.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/arm/mach-pxa/devices.c b/arch/arm/mach-pxa/devices.c
index e6ce669b54af..6d5ab8199536 100644
--- a/arch/arm/mach-pxa/devices.c
+++ b/arch/arm/mach-pxa/devices.c
@@ -395,6 +395,26 @@ static struct resource pxa_ir_resources[] = {
 		.end    = IRQ_ICP,
 		.flags  = IORESOURCE_IRQ,
 	},
+	[3] = {
+		.start  = 0x40800000,
+		.end	= 0x4080001b,
+		.flags  = IORESOURCE_MEM,
+	},
+	[4] = {
+		.start  = 0x40700000,
+		.end	= 0x40700023,
+		.flags  = IORESOURCE_MEM,
+	},
+	[5] = {
+		.start  = 17,
+		.end	= 17,
+		.flags  = IORESOURCE_DMA,
+	},
+	[6] = {
+		.start  = 18,
+		.end	= 18,
+		.flags  = IORESOURCE_DMA,
+	},
 };
 
 struct platform_device pxa_device_ficp = {
-- 
2.1.4
