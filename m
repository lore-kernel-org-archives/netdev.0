From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/2] blackfin: ezbrd: Remove non-functional DSA/KSZ8893M code
Date: Tue, 19 Sep 2017 18:03:46 -0700
Message-ID: <20170920010346.16871-3-f.fainelli@gmail.com>
References: <20170920010346.16871-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, realmz6@gmail.com,
        adi-buildroot-devel@lists.sourceforge.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36724 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdITBD4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:03:56 -0400
Received: by mail-qt0-f194.google.com with SMTP id t46so843709qtj.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 18:03:56 -0700 (PDT)
In-Reply-To: <20170920010346.16871-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no in tree driver for the KSZ8893M switch driver, so just get rid of
the code in that board file.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/blackfin/mach-bf518/boards/ezbrd.c | 47 ---------------------------------
 1 file changed, 47 deletions(-)

diff --git a/arch/blackfin/mach-bf518/boards/ezbrd.c b/arch/blackfin/mach-bf518/boards/ezbrd.c
index d022112927c2..c51d1b810ac3 100644
--- a/arch/blackfin/mach-bf518/boards/ezbrd.c
+++ b/arch/blackfin/mach-bf518/boards/ezbrd.c
@@ -25,7 +25,6 @@
 #include <asm/dpmc.h>
 #include <asm/bfin_sdh.h>
 #include <linux/spi/ad7877.h>
-#include <net/dsa.h>
 
 /*
  * Name the Board for the /proc/cpuinfo
@@ -105,11 +104,7 @@ static const unsigned short bfin_mac_peripherals[] = {
 
 static struct bfin_phydev_platform_data bfin_phydev_data[] = {
 	{
-#if IS_ENABLED(CONFIG_NET_DSA_KSZ8893M)
-		.addr = 3,
-#else
 		.addr = 1,
-#endif
 		.irq = IRQ_MAC_PHYINT,
 	},
 };
@@ -119,9 +114,6 @@ static struct bfin_mii_bus_platform_data bfin_mii_bus_data = {
 	.phydev_data = bfin_phydev_data,
 	.phy_mode = PHY_INTERFACE_MODE_MII,
 	.mac_peripherals = bfin_mac_peripherals,
-#if IS_ENABLED(CONFIG_NET_DSA_KSZ8893M)
-	.phy_mask = 0xfff7, /* Only probe the port phy connect to the on chip MAC */
-#endif
 	.vlan1_mask = 1,
 	.vlan2_mask = 2,
 };
@@ -140,29 +132,6 @@ static struct platform_device bfin_mac_device = {
 	}
 };
 
-#if IS_ENABLED(CONFIG_NET_DSA_KSZ8893M)
-static struct dsa_chip_data ksz8893m_switch_chip_data = {
-	.mii_bus = &bfin_mii_bus.dev,
-	.port_names = {
-		NULL,
-		"eth%d",
-		"eth%d",
-		"cpu",
-	},
-};
-static struct dsa_platform_data ksz8893m_switch_data = {
-	.nr_chips = 1,
-	.netdev = &bfin_mac_device.dev,
-	.chip = &ksz8893m_switch_chip_data,
-};
-
-static struct platform_device ksz8893m_switch_device = {
-	.name		= "dsa",
-	.id		= 0,
-	.num_resources	= 0,
-	.dev.platform_data = &ksz8893m_switch_data,
-};
-#endif
 #endif
 
 #if IS_ENABLED(CONFIG_MTD_M25P80)
@@ -228,19 +197,6 @@ static struct spi_board_info bfin_spi_board_info[] __initdata = {
 	},
 #endif
 
-#if IS_ENABLED(CONFIG_BFIN_MAC)
-#if IS_ENABLED(CONFIG_NET_DSA_KSZ8893M)
-	{
-		.modalias = "ksz8893m",
-		.max_speed_hz = 5000000,
-		.bus_num = 0,
-		.chip_select = 1,
-		.platform_data = NULL,
-		.mode = SPI_MODE_3,
-	},
-#endif
-#endif
-
 #if IS_ENABLED(CONFIG_MMC_SPI)
 	{
 		.modalias = "mmc_spi",
@@ -714,9 +670,6 @@ static struct platform_device *stamp_devices[] __initdata = {
 #if IS_ENABLED(CONFIG_BFIN_MAC)
 	&bfin_mii_bus,
 	&bfin_mac_device,
-#if IS_ENABLED(CONFIG_NET_DSA_KSZ8893M)
-	&ksz8893m_switch_device,
-#endif
 #endif
 
 #if IS_ENABLED(CONFIG_SPI_BFIN5XX)
-- 
2.11.0
