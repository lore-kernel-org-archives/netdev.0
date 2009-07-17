From: Wan ZongShun <mcuos.com@gmail.com>
Subject: Re: [PATCH] Add mac resource support for w90p910
Date: Fri, 17 Jul 2009 10:01:46 +0800
Message-ID: <4A5FDB8A.10807@gmail.com>
References: <4A5F21E2.90307@gmail.com> <5d5443650907160609j742c407dpffaf818e5552a7e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Russell King <linux@arm.linux.org.uk>,
	"Eric.miao" <eric.y.miao@gmail.com>
To: Trilok Soni <soni.trilok@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:37163 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933610AbZGQCB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 22:01:56 -0400
Received: by wf-out-1314.google.com with SMTP id 26so148692wfd.4
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 19:01:56 -0700 (PDT)
In-Reply-To: <5d5443650907160609j742c407dpffaf818e5552a7e1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Trilok,

Thanks for your reviewing, I fixed up and resubmitted this patch.

patch text:

Add mac resource support for w90p910 mac driver

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>
---
 arch/arm/mach-w90x900/mach-w90p910evb.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-w90x900/mach-w90p910evb.c b/arch/arm/mach-w90x900/mach-w90p910evb.c
index 7a62bd3..3becabb 100644
--- a/arch/arm/mach-w90x900/mach-w90p910evb.c
+++ b/arch/arm/mach-w90x900/mach-w90p910evb.c
@@ -228,6 +228,33 @@ struct platform_device w90x900_device_usbgadget = {
 };
 EXPORT_SYMBOL(w90x900_device_usbgadget);
 
+/* USB mac device */
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
+static struct platform_device w90p910_device_emc = {
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


> Hi Wan,
> 
> On Thu, Jul 16, 2009 at 6:19 PM, Wan ZongShun<mcuos.com@gmail.com> wrote:
>> +
>> +struct platform_device w90p910_device_emc = {
> 
> static?
> 

