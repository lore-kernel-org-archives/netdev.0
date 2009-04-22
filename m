From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 2/2] mx1ads: Add cs89x0 network support
Date: Wed, 22 Apr 2009 09:59:32 +0200
Message-ID: <1240387172-21818-3-git-send-email-s.hauer@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
 <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Cc: Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60502 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbZDVIAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 04:00:16 -0400
In-Reply-To: <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 arch/arm/mach-mx1/mx1ads.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-mx1/mx1ads.c b/arch/arm/mach-mx1/mx1ads.c
index e54057f..6d23fcc 100644
--- a/arch/arm/mach-mx1/mx1ads.c
+++ b/arch/arm/mach-mx1/mx1ads.c
@@ -155,6 +155,24 @@ static struct i2c_board_info mx1ads_i2c_devices[] = {
 	},
 };
 
+static struct resource cs89x0_resources[] = {
+	{
+		.start  = IMX_CS4_PHYS + 0x300,
+		.end    = IMX_CS4_PHYS + 0x300 + 15,
+		.flags  = IORESOURCE_MEM,
+	}, {
+		.start  = IRQ_GPIOC(17),
+		.end    = IRQ_GPIOC(17),
+		.flags  = IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device cs89x0_device = {
+	.name           = "cirrus-cs89x0",
+	.num_resources  = ARRAY_SIZE(cs89x0_resources),
+	.resource       = cs89x0_resources,
+};
+
 /*
  * Board init
  */
@@ -172,6 +190,8 @@ static void __init mx1ads_init(void)
 				ARRAY_SIZE(mx1ads_i2c_devices));
 
 	mxc_register_device(&imx_i2c_device, &mx1ads_i2c_data);
+
+	platform_device_register(&cs89x0_device);
 }
 
 static void __init mx1ads_timer_init(void)
-- 
1.6.2.1

