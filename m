From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH 2/4] CS89x0 : add CS89x0 platform device to the iMX21ADS board
Date: Tue,  3 Jan 2012 23:12:10 +0100
Message-ID: <1325628732-14535-2-git-send-email-jaccon.bastiaansen@gmail.com>
References: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, jaccon.bastiaansen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51206 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab2ACWMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:12:49 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so16247808eek.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 14:12:48 -0800 (PST)
In-Reply-To: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CS89x0 networking support to the iMX21ADS board by using the
platform driver support in the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 arch/arm/configs/imx_v4_v5_defconfig |    2 ++
 arch/arm/mach-imx/mach-mx21ads.c     |   21 +++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/configs/imx_v4_v5_defconfig
index 11a4192..fc0106f 100644
--- a/arch/arm/configs/imx_v4_v5_defconfig
+++ b/arch/arm/configs/imx_v4_v5_defconfig
@@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=y
 CONFIG_SMC91X=y
 CONFIG_DM9000=y
 CONFIG_SMC911X=y
+CONFIG_CS89x0=y
+CONFIG_CS89x0_PLATFORM=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT_MOUSEDEV is not set
diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/mach-mx21ads.c
index 25f8402..b26b49c 100644
--- a/arch/arm/mach-imx/mach-mx21ads.c
+++ b/arch/arm/mach-imx/mach-mx21ads.c
@@ -159,6 +159,26 @@ static struct platform_device mx21ads_nor_mtd_device = {
 	.resource = &mx21ads_flash_resource,
 };
 
+static struct resource mx21ads_cs8900_resources[] = {
+	{
+		.start = (u32)MX21ADS_CS8900A_IOBASE_REG,
+		.end = (u32)MX21ADS_CS8900A_IOBASE_REG + 0x200000 - 1,
+		.flags = IORESOURCE_MEM
+	},
+	{
+		.start = MX21ADS_CS8900A_IRQ,
+		.end = MX21ADS_CS8900A_IRQ,
+		.flags = IORESOURCE_IRQ
+	}
+};
+
+static struct platform_device mx21ads_cs8900_device = {
+	.name = "cs89x0",
+	.id = 0,
+	.num_resources = ARRAY_SIZE(mx21ads_cs8900_resources),
+	.resource = mx21ads_cs8900_resources
+};
+
 static const struct imxuart_platform_data uart_pdata_rts __initconst = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
@@ -275,6 +295,7 @@ static void __init mx21ads_map_io(void)
 
 static struct platform_device *platform_devices[] __initdata = {
 	&mx21ads_nor_mtd_device,
+	&mx21ads_cs8900_device
 };
 
 static void __init mx21ads_board_init(void)
-- 
1.7.1
