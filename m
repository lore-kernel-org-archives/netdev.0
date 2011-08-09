From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv3 3/9] macb: unify at91 and avr32 platform data
Date: Tue,  9 Aug 2011 10:16:45 +0100
Message-ID: <1312881411-2376-4-git-send-email-jamie@jamieiles.com>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Cc: plagnioj@jcrosoft.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54522 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1HIJRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 05:17:49 -0400
Received: by mail-wy0-f174.google.com with SMTP id 24so212672wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 02:17:48 -0700 (PDT)
In-Reply-To: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both at91 and avr32 defines its own platform data structure for
the macb driver and both share common structures though at91
includes a currently unused phy_irq_pin.  Create a common
macb_platform_data for macb that both at91 and avr32 can use.  In
future we can use this to support other architectures that use the
same IP block with the macb driver.

v2: rename eth_platform_data to macb_platform_data and allow at91_ether
to share the platform data with macb.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 arch/arm/mach-at91/at91cap9_devices.c       |    6 +++---
 arch/arm/mach-at91/at91rm9200_devices.c     |    6 +++---
 arch/arm/mach-at91/at91sam9260_devices.c    |    6 +++---
 arch/arm/mach-at91/at91sam9263_devices.c    |    6 +++---
 arch/arm/mach-at91/at91sam9g45_devices.c    |    6 +++---
 arch/arm/mach-at91/board-1arm.c             |    2 +-
 arch/arm/mach-at91/board-afeb-9260v1.c      |    2 +-
 arch/arm/mach-at91/board-cam60.c            |    2 +-
 arch/arm/mach-at91/board-cap9adk.c          |    2 +-
 arch/arm/mach-at91/board-carmeva.c          |    2 +-
 arch/arm/mach-at91/board-cpu9krea.c         |    2 +-
 arch/arm/mach-at91/board-cpuat91.c          |    2 +-
 arch/arm/mach-at91/board-csb337.c           |    2 +-
 arch/arm/mach-at91/board-csb637.c           |    2 +-
 arch/arm/mach-at91/board-eb9200.c           |    2 +-
 arch/arm/mach-at91/board-ecbat91.c          |    2 +-
 arch/arm/mach-at91/board-eco920.c           |    2 +-
 arch/arm/mach-at91/board-foxg20.c           |    2 +-
 arch/arm/mach-at91/board-gsia18s.c          |    2 +-
 arch/arm/mach-at91/board-kafa.c             |    2 +-
 arch/arm/mach-at91/board-kb9202.c           |    2 +-
 arch/arm/mach-at91/board-neocore926.c       |    2 +-
 arch/arm/mach-at91/board-pcontrol-g20.c     |    2 +-
 arch/arm/mach-at91/board-picotux200.c       |    2 +-
 arch/arm/mach-at91/board-qil-a9260.c        |    2 +-
 arch/arm/mach-at91/board-rm9200dk.c         |    2 +-
 arch/arm/mach-at91/board-rm9200ek.c         |    2 +-
 arch/arm/mach-at91/board-sam9-l9260.c       |    2 +-
 arch/arm/mach-at91/board-sam9260ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9263ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9g20ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9m10g45ek.c     |    2 +-
 arch/arm/mach-at91/board-snapper9260.c      |    2 +-
 arch/arm/mach-at91/board-stamp9g20.c        |    2 +-
 arch/arm/mach-at91/board-usb-a9260.c        |    2 +-
 arch/arm/mach-at91/board-usb-a9263.c        |    2 +-
 arch/arm/mach-at91/board-yl-9200.c          |    2 +-
 arch/arm/mach-at91/include/mach/board.h     |   14 ++------------
 arch/avr32/boards/atngw100/setup.c          |    2 +-
 arch/avr32/boards/atstk1000/atstk1002.c     |    2 +-
 arch/avr32/boards/favr-32/setup.c           |    2 +-
 arch/avr32/boards/hammerhead/setup.c        |    2 +-
 arch/avr32/boards/merisc/setup.c            |    2 +-
 arch/avr32/boards/mimc200/setup.c           |    2 +-
 arch/avr32/mach-at32ap/at32ap700x.c         |    8 ++++----
 arch/avr32/mach-at32ap/include/mach/board.h |    7 ++-----
 drivers/net/arm/at91_ether.c                |    3 ++-
 drivers/net/arm/at91_ether.h                |    4 +++-
 drivers/net/macb.c                          |   10 ++++------
 include/linux/platform_data/macb.h          |   17 +++++++++++++++++
 50 files changed, 87 insertions(+), 82 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

diff --git a/arch/arm/mach-at91/at91cap9_devices.c b/arch/arm/mach-at91/at91cap9_devices.c
index dba0d8d..0113526 100644
--- a/arch/arm/mach-at91/at91cap9_devices.c
+++ b/arch/arm/mach-at91/at91cap9_devices.c
@@ -194,7 +194,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -221,7 +221,7 @@ static struct platform_device at91cap9_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -258,7 +258,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91cap9_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91rm9200_devices.c b/arch/arm/mach-at91/at91rm9200_devices.c
index 7227755..adbd46c 100644
--- a/arch/arm/mach-at91/at91rm9200_devices.c
+++ b/arch/arm/mach-at91/at91rm9200_devices.c
@@ -127,7 +127,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_ARM_AT91_ETHER) || defined(CONFIG_ARM_AT91_ETHER_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -154,7 +154,7 @@ static struct platform_device at91rm9200_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -191,7 +191,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91rm9200_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9260_devices.c b/arch/arm/mach-at91/at91sam9260_devices.c
index 39f81f4..81bcd1e 100644
--- a/arch/arm/mach-at91/at91sam9260_devices.c
+++ b/arch/arm/mach-at91/at91sam9260_devices.c
@@ -128,7 +128,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -155,7 +155,7 @@ static struct platform_device at91sam9260_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -192,7 +192,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9260_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
index a050f41..0aa907c 100644
--- a/arch/arm/mach-at91/at91sam9263_devices.c
+++ b/arch/arm/mach-at91/at91sam9263_devices.c
@@ -138,7 +138,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -165,7 +165,7 @@ static struct platform_device at91sam9263_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -202,7 +202,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9263_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9g45_devices.c b/arch/arm/mach-at91/at91sam9g45_devices.c
index 600bffb..fbcebad 100644
--- a/arch/arm/mach-at91/at91sam9g45_devices.c
+++ b/arch/arm/mach-at91/at91sam9g45_devices.c
@@ -278,7 +278,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -305,7 +305,7 @@ static struct platform_device at91sam9g45_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -342,7 +342,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9g45_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/board-1arm.c b/arch/arm/mach-at91/board-1arm.c
index 5aa5885..ce2c5e1 100644
--- a/arch/arm/mach-at91/board-1arm.c
+++ b/arch/arm/mach-at91/board-1arm.c
@@ -63,7 +63,7 @@ static void __init onearm_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata onearm_eth_data = {
+static struct macb_platform_data __initdata onearm_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-afeb-9260v1.c b/arch/arm/mach-at91/board-afeb-9260v1.c
index b0c796d..79dbaaa 100644
--- a/arch/arm/mach-at91/board-afeb-9260v1.c
+++ b/arch/arm/mach-at91/board-afeb-9260v1.c
@@ -103,7 +103,7 @@ static struct spi_board_info afeb9260_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata afeb9260_macb_data = {
+static struct macb_platform_data __initdata afeb9260_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA9,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-cam60.c b/arch/arm/mach-at91/board-cam60.c
index d1abd58..e6779d6 100644
--- a/arch/arm/mach-at91/board-cam60.c
+++ b/arch/arm/mach-at91/board-cam60.c
@@ -115,7 +115,7 @@ static struct spi_board_info cam60_spi_devices[] __initdata = {
 /*
  * MACB Ethernet device
  */
-static struct __initdata at91_eth_data cam60_macb_data = {
+static struct __initdata macb_platform_data cam60_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PB5,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-cap9adk.c b/arch/arm/mach-at91/board-cap9adk.c
index 679b0b7..6597a0a 100644
--- a/arch/arm/mach-at91/board-cap9adk.c
+++ b/arch/arm/mach-at91/board-cap9adk.c
@@ -153,7 +153,7 @@ static struct at91_mmc_data __initdata cap9adk_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cap9adk_macb_data = {
+static struct macb_platform_data __initdata cap9adk_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-carmeva.c b/arch/arm/mach-at91/board-carmeva.c
index c578c5d..b41499d 100644
--- a/arch/arm/mach-at91/board-carmeva.c
+++ b/arch/arm/mach-at91/board-carmeva.c
@@ -57,7 +57,7 @@ static void __init carmeva_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata carmeva_eth_data = {
+static struct macb_platform_data __initdata carmeva_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-cpu9krea.c b/arch/arm/mach-at91/board-cpu9krea.c
index f4da8a1..fdd0302 100644
--- a/arch/arm/mach-at91/board-cpu9krea.c
+++ b/arch/arm/mach-at91/board-cpu9krea.c
@@ -99,7 +99,7 @@ static struct at91_udc_data __initdata cpu9krea_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cpu9krea_macb_data = {
+static struct macb_platform_data __initdata cpu9krea_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-cpuat91.c b/arch/arm/mach-at91/board-cpuat91.c
index 2d919f5..ef02489 100644
--- a/arch/arm/mach-at91/board-cpuat91.c
+++ b/arch/arm/mach-at91/board-cpuat91.c
@@ -82,7 +82,7 @@ static void __init cpuat91_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata cpuat91_eth_data = {
+static struct macb_platform_data __initdata cpuat91_eth_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-csb337.c b/arch/arm/mach-at91/board-csb337.c
index 17654d5..1c31952 100644
--- a/arch/arm/mach-at91/board-csb337.c
+++ b/arch/arm/mach-at91/board-csb337.c
@@ -58,7 +58,7 @@ static void __init csb337_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata csb337_eth_data = {
+static struct macb_platform_data __initdata csb337_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-csb637.c b/arch/arm/mach-at91/board-csb637.c
index 72b5567..68a2c4e 100644
--- a/arch/arm/mach-at91/board-csb637.c
+++ b/arch/arm/mach-at91/board-csb637.c
@@ -52,7 +52,7 @@ static void __init csb637_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata csb637_eth_data = {
+static struct macb_platform_data __initdata csb637_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC0,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eb9200.c b/arch/arm/mach-at91/board-eb9200.c
index 01170a2..8430736 100644
--- a/arch/arm/mach-at91/board-eb9200.c
+++ b/arch/arm/mach-at91/board-eb9200.c
@@ -60,7 +60,7 @@ static void __init eb9200_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata eb9200_eth_data = {
+static struct macb_platform_data __initdata eb9200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-ecbat91.c b/arch/arm/mach-at91/board-ecbat91.c
index 7c0313c..41a833a 100644
--- a/arch/arm/mach-at91/board-ecbat91.c
+++ b/arch/arm/mach-at91/board-ecbat91.c
@@ -64,7 +64,7 @@ static void __init ecb_at91init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata ecb_at91eth_data = {
+static struct macb_platform_data __initdata ecb_at91eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eco920.c b/arch/arm/mach-at91/board-eco920.c
index 8252c72..8e75867 100644
--- a/arch/arm/mach-at91/board-eco920.c
+++ b/arch/arm/mach-at91/board-eco920.c
@@ -47,7 +47,7 @@ static void __init eco920_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata eco920_eth_data = {
+static struct macb_platform_data __initdata eco920_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-foxg20.c b/arch/arm/mach-at91/board-foxg20.c
index f27d1a7..de8e096 100644
--- a/arch/arm/mach-at91/board-foxg20.c
+++ b/arch/arm/mach-at91/board-foxg20.c
@@ -135,7 +135,7 @@ static struct spi_board_info foxg20_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata foxg20_macb_data = {
+static struct macb_platform_data __initdata foxg20_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-gsia18s.c b/arch/arm/mach-at91/board-gsia18s.c
index 2e95949..51c82f1 100644
--- a/arch/arm/mach-at91/board-gsia18s.c
+++ b/arch/arm/mach-at91/board-gsia18s.c
@@ -93,7 +93,7 @@ static struct at91_udc_data __initdata udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-kafa.c b/arch/arm/mach-at91/board-kafa.c
index 4a17089..a39b85a 100644
--- a/arch/arm/mach-at91/board-kafa.c
+++ b/arch/arm/mach-at91/board-kafa.c
@@ -61,7 +61,7 @@ static void __init kafa_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata kafa_eth_data = {
+static struct macb_platform_data __initdata kafa_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-kb9202.c b/arch/arm/mach-at91/board-kb9202.c
index 9dc8d49..1f39c11 100644
--- a/arch/arm/mach-at91/board-kb9202.c
+++ b/arch/arm/mach-at91/board-kb9202.c
@@ -69,7 +69,7 @@ static void __init kb9202_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata kb9202_eth_data = {
+static struct macb_platform_data __initdata kb9202_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PB29,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-neocore926.c b/arch/arm/mach-at91/board-neocore926.c
index 9bc6ab3..220bba4 100644
--- a/arch/arm/mach-at91/board-neocore926.c
+++ b/arch/arm/mach-at91/board-neocore926.c
@@ -155,7 +155,7 @@ static struct at91_mmc_data __initdata neocore926_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata neocore926_macb_data = {
+static struct macb_platform_data __initdata neocore926_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-pcontrol-g20.c b/arch/arm/mach-at91/board-pcontrol-g20.c
index 49e3f69..c545a3e 100644
--- a/arch/arm/mach-at91/board-pcontrol-g20.c
+++ b/arch/arm/mach-at91/board-pcontrol-g20.c
@@ -122,7 +122,7 @@ static struct at91_udc_data __initdata pcontrol_g20_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-picotux200.c b/arch/arm/mach-at91/board-picotux200.c
index b7b8390..49f852e 100644
--- a/arch/arm/mach-at91/board-picotux200.c
+++ b/arch/arm/mach-at91/board-picotux200.c
@@ -60,7 +60,7 @@ static void __init picotux200_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata picotux200_eth_data = {
+static struct macb_platform_data __initdata picotux200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-qil-a9260.c b/arch/arm/mach-at91/board-qil-a9260.c
index 81f9110..c5accca 100644
--- a/arch/arm/mach-at91/board-qil-a9260.c
+++ b/arch/arm/mach-at91/board-qil-a9260.c
@@ -104,7 +104,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200dk.c b/arch/arm/mach-at91/board-rm9200dk.c
index 6f08faa..a9ba24a 100644
--- a/arch/arm/mach-at91/board-rm9200dk.c
+++ b/arch/arm/mach-at91/board-rm9200dk.c
@@ -65,7 +65,7 @@ static void __init dk_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata dk_eth_data = {
+static struct macb_platform_data __initdata dk_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200ek.c b/arch/arm/mach-at91/board-rm9200ek.c
index 85bcccd..743139e 100644
--- a/arch/arm/mach-at91/board-rm9200ek.c
+++ b/arch/arm/mach-at91/board-rm9200ek.c
@@ -65,7 +65,7 @@ static void __init ek_init_early(void)
 	at91_set_serial_console(0);
 }
 
-static struct at91_eth_data __initdata ek_eth_data = {
+static struct macb_platform_data __initdata ek_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9-l9260.c b/arch/arm/mach-at91/board-sam9-l9260.c
index 4d3a02f..e519b74 100644
--- a/arch/arm/mach-at91/board-sam9-l9260.c
+++ b/arch/arm/mach-at91/board-sam9-l9260.c
@@ -109,7 +109,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-sam9260ek.c b/arch/arm/mach-at91/board-sam9260ek.c
index 8a50c3e..ca78ecb 100644
--- a/arch/arm/mach-at91/board-sam9260ek.c
+++ b/arch/arm/mach-at91/board-sam9260ek.c
@@ -151,7 +151,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9263ek.c b/arch/arm/mach-at91/board-sam9263ek.c
index ea8f185..e804953 100644
--- a/arch/arm/mach-at91/board-sam9263ek.c
+++ b/arch/arm/mach-at91/board-sam9263ek.c
@@ -158,7 +158,7 @@ static struct at91_mmc_data __initdata ek_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9g20ek.c b/arch/arm/mach-at91/board-sam9g20ek.c
index 817f59d..28f0f81 100644
--- a/arch/arm/mach-at91/board-sam9g20ek.c
+++ b/arch/arm/mach-at91/board-sam9g20ek.c
@@ -123,7 +123,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9m10g45ek.c b/arch/arm/mach-at91/board-sam9m10g45ek.c
index ad234cc..62bedc0 100644
--- a/arch/arm/mach-at91/board-sam9m10g45ek.c
+++ b/arch/arm/mach-at91/board-sam9m10g45ek.c
@@ -115,7 +115,7 @@ static struct mci_platform_data __initdata mci1_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PD5,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-snapper9260.c b/arch/arm/mach-at91/board-snapper9260.c
index c73d25e..49321cf 100644
--- a/arch/arm/mach-at91/board-snapper9260.c
+++ b/arch/arm/mach-at91/board-snapper9260.c
@@ -65,7 +65,7 @@ static struct at91_udc_data __initdata snapper9260_udc_data = {
 	.vbus_polled		= 1,
 };
 
-static struct at91_eth_data snapper9260_macb_data = {
+static struct macb_platform_data snapper9260_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-stamp9g20.c b/arch/arm/mach-at91/board-stamp9g20.c
index 936e5fd..7c06c07 100644
--- a/arch/arm/mach-at91/board-stamp9g20.c
+++ b/arch/arm/mach-at91/board-stamp9g20.c
@@ -157,7 +157,7 @@ static struct at91_udc_data __initdata stamp9g20evb_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9260.c b/arch/arm/mach-at91/board-usb-a9260.c
index 8c4c1a0..1d5752a 100644
--- a/arch/arm/mach-at91/board-usb-a9260.c
+++ b/arch/arm/mach-at91/board-usb-a9260.c
@@ -78,7 +78,7 @@ static struct at91_udc_data __initdata ek_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9263.c b/arch/arm/mach-at91/board-usb-a9263.c
index 25e7937..9f42127 100644
--- a/arch/arm/mach-at91/board-usb-a9263.c
+++ b/arch/arm/mach-at91/board-usb-a9263.c
@@ -91,7 +91,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-yl-9200.c b/arch/arm/mach-at91/board-yl-9200.c
index 95edcbd..1ebd286 100644
--- a/arch/arm/mach-at91/board-yl-9200.c
+++ b/arch/arm/mach-at91/board-yl-9200.c
@@ -110,7 +110,7 @@ static struct gpio_led yl9200_leds[] = {
 /*
  * Ethernet
  */
-static struct at91_eth_data __initdata yl9200_eth_data = {
+static struct macb_platform_data __initdata yl9200_eth_data = {
 	.phy_irq_pin		= AT91_PIN_PB28,
 	.is_rmii		= 1,
 };
diff --git a/arch/arm/mach-at91/include/mach/board.h b/arch/arm/mach-at91/include/mach/board.h
index ed544a0..00e08b1 100644
--- a/arch/arm/mach-at91/include/mach/board.h
+++ b/arch/arm/mach-at91/include/mach/board.h
@@ -40,6 +40,7 @@
 #include <linux/atmel-mci.h>
 #include <sound/atmel-ac97c.h>
 #include <linux/serial.h>
+#include <linux/platform_data/macb.h>
 
  /* USB Device */
 struct at91_udc_data {
@@ -81,18 +82,7 @@ extern void __init at91_add_device_mmc(short mmc_id, struct at91_mmc_data *data)
   /* atmel-mci platform config */
 extern void __init at91_add_device_mci(short mmc_id, struct mci_platform_data *data);
 
- /* Ethernet (EMAC & MACB) */
-struct at91_eth_data {
-	u32		phy_mask;
-	u8		phy_irq_pin;	/* PHY IRQ */
-	u8		is_rmii;	/* using RMII interface? */
-};
-extern void __init at91_add_device_eth(struct at91_eth_data *data);
-
-#if defined(CONFIG_ARCH_AT91SAM9260) || defined(CONFIG_ARCH_AT91SAM9263) || defined(CONFIG_ARCH_AT91SAM9G20) || defined(CONFIG_ARCH_AT91CAP9) \
-	|| defined(CONFIG_ARCH_AT91SAM9G45)
-#define eth_platform_data	at91_eth_data
-#endif
+extern void __init at91_add_device_eth(struct macb_platform_data *data);
 
  /* USB Host */
 struct at91_usbh_data {
diff --git a/arch/avr32/boards/atngw100/setup.c b/arch/avr32/boards/atngw100/setup.c
index fafed4c..defbafd 100644
--- a/arch/avr32/boards/atngw100/setup.c
+++ b/arch/avr32/boards/atngw100/setup.c
@@ -113,7 +113,7 @@ struct eth_addr {
 	u8 addr[6];
 };
 static struct eth_addr __initdata hw_addr[2];
-static struct eth_platform_data __initdata eth_data[2];
+static struct macb_platform_data __initdata eth_data[2];
 
 static struct spi_board_info spi0_board_info[] __initdata = {
 	{
diff --git a/arch/avr32/boards/atstk1000/atstk1002.c b/arch/avr32/boards/atstk1000/atstk1002.c
index 6ce30fb..47906ba 100644
--- a/arch/avr32/boards/atstk1000/atstk1002.c
+++ b/arch/avr32/boards/atstk1000/atstk1002.c
@@ -110,7 +110,7 @@ struct eth_addr {
 };
 
 static struct eth_addr __initdata hw_addr[2];
-static struct eth_platform_data __initdata eth_data[2] = {
+static struct macb_platform_data __initdata eth_data[2] = {
 	{
 		/*
 		 * The MDIO pullups on STK1000 are a bit too weak for
diff --git a/arch/avr32/boards/favr-32/setup.c b/arch/avr32/boards/favr-32/setup.c
index 86fab77..27bd6fb 100644
--- a/arch/avr32/boards/favr-32/setup.c
+++ b/arch/avr32/boards/favr-32/setup.c
@@ -50,7 +50,7 @@ struct eth_addr {
 	u8 addr[6];
 };
 static struct eth_addr __initdata hw_addr[1];
-static struct eth_platform_data __initdata eth_data[1] = {
+static struct macb_platform_data __initdata eth_data[1] = {
 	{
 		.phy_mask	= ~(1U << 1),
 	},
diff --git a/arch/avr32/boards/hammerhead/setup.c b/arch/avr32/boards/hammerhead/setup.c
index da14fbd..9d1efd1 100644
--- a/arch/avr32/boards/hammerhead/setup.c
+++ b/arch/avr32/boards/hammerhead/setup.c
@@ -102,7 +102,7 @@ struct eth_addr {
 };
 
 static struct eth_addr __initdata hw_addr[1];
-static struct eth_platform_data __initdata eth_data[1];
+static struct macb_platform_data __initdata eth_data[1];
 
 /*
  * The next two functions should go away as the boot loader is
diff --git a/arch/avr32/boards/merisc/setup.c b/arch/avr32/boards/merisc/setup.c
index e61bc94..ed137e3 100644
--- a/arch/avr32/boards/merisc/setup.c
+++ b/arch/avr32/boards/merisc/setup.c
@@ -52,7 +52,7 @@ struct eth_addr {
 };
 
 static struct eth_addr __initdata hw_addr[2];
-static struct eth_platform_data __initdata eth_data[2];
+static struct macb_platform_data __initdata eth_data[2];
 
 static int ads7846_get_pendown_state_PB26(void)
 {
diff --git a/arch/avr32/boards/mimc200/setup.c b/arch/avr32/boards/mimc200/setup.c
index c4da5cb..05358aa 100644
--- a/arch/avr32/boards/mimc200/setup.c
+++ b/arch/avr32/boards/mimc200/setup.c
@@ -86,7 +86,7 @@ struct eth_addr {
 	u8 addr[6];
 };
 static struct eth_addr __initdata hw_addr[2];
-static struct eth_platform_data __initdata eth_data[2];
+static struct macb_platform_data __initdata eth_data[2];
 
 static struct spi_eeprom eeprom_25lc010 = {
 		.name = "25lc010",
diff --git a/arch/avr32/mach-at32ap/at32ap700x.c b/arch/avr32/mach-at32ap/at32ap700x.c
index 7fbf0dc..402a7bb 100644
--- a/arch/avr32/mach-at32ap/at32ap700x.c
+++ b/arch/avr32/mach-at32ap/at32ap700x.c
@@ -1067,7 +1067,7 @@ void __init at32_setup_serial_console(unsigned int usart_id)
  * -------------------------------------------------------------------- */
 
 #ifdef CONFIG_CPU_AT32AP7000
-static struct eth_platform_data macb0_data;
+static struct macb_platform_data macb0_data;
 static struct resource macb0_resource[] = {
 	PBMEM(0xfff01800),
 	IRQ(25),
@@ -1076,7 +1076,7 @@ DEFINE_DEV_DATA(macb, 0);
 DEV_CLK(hclk, macb0, hsb, 8);
 DEV_CLK(pclk, macb0, pbb, 6);
 
-static struct eth_platform_data macb1_data;
+static struct macb_platform_data macb1_data;
 static struct resource macb1_resource[] = {
 	PBMEM(0xfff01c00),
 	IRQ(26),
@@ -1086,7 +1086,7 @@ DEV_CLK(hclk, macb1, hsb, 9);
 DEV_CLK(pclk, macb1, pbb, 7);
 
 struct platform_device *__init
-at32_add_device_eth(unsigned int id, struct eth_platform_data *data)
+at32_add_device_eth(unsigned int id, struct macb_platform_data *data)
 {
 	struct platform_device *pdev;
 	u32 pin_mask;
@@ -1163,7 +1163,7 @@ at32_add_device_eth(unsigned int id, struct eth_platform_data *data)
 		return NULL;
 	}
 
-	memcpy(pdev->dev.platform_data, data, sizeof(struct eth_platform_data));
+	memcpy(pdev->dev.platform_data, data, sizeof(struct macb_platform_data));
 	platform_device_register(pdev);
 
 	return pdev;
diff --git a/arch/avr32/mach-at32ap/include/mach/board.h b/arch/avr32/mach-at32ap/include/mach/board.h
index 679458d..c8aa8b5 100644
--- a/arch/avr32/mach-at32ap/include/mach/board.h
+++ b/arch/avr32/mach-at32ap/include/mach/board.h
@@ -6,6 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/serial.h>
+#include <linux/platform_data/macb.h>
 
 #define GPIO_PIN_NONE	(-1)
 
@@ -42,12 +43,8 @@ struct atmel_uart_data {
 void at32_map_usart(unsigned int hw_id, unsigned int line, int flags);
 struct platform_device *at32_add_device_usart(unsigned int id);
 
-struct eth_platform_data {
-	u32	phy_mask;
-	u8	is_rmii;
-};
 struct platform_device *
-at32_add_device_eth(unsigned int id, struct eth_platform_data *data);
+at32_add_device_eth(unsigned int id, struct macb_platform_data *data);
 
 struct spi_board_info;
 struct platform_device *
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 29dc435..7e8e8ca 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -26,6 +26,7 @@
 #include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/ethtool.h>
+#include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
 #include <linux/gfp.h>
@@ -984,7 +985,7 @@ static const struct net_device_ops at91ether_netdev_ops = {
 static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_address,
 			struct platform_device *pdev, struct clk *ether_clk)
 {
-	struct at91_eth_data *board_data = pdev->dev.platform_data;
+	struct macb_platform_data *board_data = pdev->dev.platform_data;
 	struct net_device *dev;
 	struct at91_private *lp;
 	unsigned int val;
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/arm/at91_ether.h
index 353f4da..3725fbb0 100644
--- a/drivers/net/arm/at91_ether.h
+++ b/drivers/net/arm/at91_ether.h
@@ -85,7 +85,9 @@ struct recv_desc_bufs
 struct at91_private
 {
 	struct mii_if_info mii;			/* ethtool support */
-	struct at91_eth_data board_data;	/* board-specific configuration */
+	struct macb_platform_data board_data;	/* board-specific
+						 * configuration (shared with
+						 * macb for common data */
 	struct clk *ether_clk;			/* clock */
 
 	/* PHY */
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 6e57567..3e48918 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -19,12 +19,10 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/dma-mapping.h>
+#include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
 
-#include <mach/board.h>
-#include <mach/cpu.h>
-
 #include "macb.h"
 
 #define RX_BUFFER_SIZE		128
@@ -191,7 +189,7 @@ static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev;
-	struct eth_platform_data *pdata;
+	struct macb_platform_data *pdata;
 	int ret;
 
 	phydev = phy_find_first(bp->mii_bus);
@@ -228,7 +226,7 @@ static int macb_mii_probe(struct net_device *dev)
 
 static int macb_mii_init(struct macb *bp)
 {
-	struct eth_platform_data *pdata;
+	struct macb_platform_data *pdata;
 	int err = -ENXIO, i;
 
 	/* Enable management port */
@@ -1119,7 +1117,7 @@ static const struct net_device_ops macb_netdev_ops = {
 
 static int __init macb_probe(struct platform_device *pdev)
 {
-	struct eth_platform_data *pdata;
+	struct macb_platform_data *pdata;
 	struct resource *regs;
 	struct net_device *dev;
 	struct macb *bp;
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
new file mode 100644
index 0000000..e7c748f
--- /dev/null
+++ b/include/linux/platform_data/macb.h
@@ -0,0 +1,17 @@
+/*
+ * Copyright (C) 2004-2006 Atmel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __MACB_PDATA_H__
+#define __MACB_PDATA_H__
+
+struct macb_platform_data {
+	u32		phy_mask;
+	u8		phy_irq_pin;	/* PHY IRQ */
+	u8		is_rmii;	/* using RMII interface? */
+};
+
+#endif /* __MACB_PDATA_H__ */
-- 
1.7.4.1

