From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 3/9] macb: unify at91 and avr32 platform data
Date: Tue,  8 Nov 2011 14:13:27 +0000
Message-ID: <1320761613-18641-4-git-send-email-jamie@jamieiles.com>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63521 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377Ab1KHONt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:13:49 -0500
Received: by mail-wy0-f174.google.com with SMTP id 15so512103wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:13:48 -0800 (PST)
In-Reply-To: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
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
 arch/arm/mach-at91/board-rsi-ews.c          |    2 +-
 arch/arm/mach-at91/board-sam9-l9260.c       |    2 +-
 arch/arm/mach-at91/board-sam9260ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9263ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9g20ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9m10g45ek.c     |    2 +-
 arch/arm/mach-at91/board-snapper9260.c      |    2 +-
 arch/arm/mach-at91/board-stamp9g20.c        |    2 +-
 arch/arm/mach-at91/board-usb-a926x.c        |    2 +-
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
 drivers/net/ethernet/cadence/at91_ether.c   |    3 ++-
 drivers/net/ethernet/cadence/at91_ether.h   |    4 +++-
 drivers/net/ethernet/cadence/macb.c         |   10 ++++------
 include/linux/platform_data/macb.h          |   17 +++++++++++++++++
 50 files changed, 87 insertions(+), 82 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

diff --git a/arch/arm/mach-at91/at91cap9_devices.c b/arch/arm/mach-at91/at91cap9_devices.c
index a4401d6..6be35a7 100644
--- a/arch/arm/mach-at91/at91cap9_devices.c
+++ b/arch/arm/mach-at91/at91cap9_devices.c
@@ -200,7 +200,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -227,7 +227,7 @@ static struct platform_device at91cap9_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -264,7 +264,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91cap9_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91rm9200_devices.c b/arch/arm/mach-at91/at91rm9200_devices.c
index 01d8bbd..17b7b0e 100644
--- a/arch/arm/mach-at91/at91rm9200_devices.c
+++ b/arch/arm/mach-at91/at91rm9200_devices.c
@@ -135,7 +135,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_ARM_AT91_ETHER) || defined(CONFIG_ARM_AT91_ETHER_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -162,7 +162,7 @@ static struct platform_device at91rm9200_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -199,7 +199,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91rm9200_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9260_devices.c b/arch/arm/mach-at91/at91sam9260_devices.c
index 24b6f8c..5773eb5 100644
--- a/arch/arm/mach-at91/at91sam9260_devices.c
+++ b/arch/arm/mach-at91/at91sam9260_devices.c
@@ -136,7 +136,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -163,7 +163,7 @@ static struct platform_device at91sam9260_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -200,7 +200,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9260_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
index 3faa1fd..820b15f 100644
--- a/arch/arm/mach-at91/at91sam9263_devices.c
+++ b/arch/arm/mach-at91/at91sam9263_devices.c
@@ -144,7 +144,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -171,7 +171,7 @@ static struct platform_device at91sam9263_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -208,7 +208,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9263_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9g45_devices.c b/arch/arm/mach-at91/at91sam9g45_devices.c
index 000b5e1..109e5ca 100644
--- a/arch/arm/mach-at91/at91sam9g45_devices.c
+++ b/arch/arm/mach-at91/at91sam9g45_devices.c
@@ -284,7 +284,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -311,7 +311,7 @@ static struct platform_device at91sam9g45_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -348,7 +348,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9g45_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/board-1arm.c b/arch/arm/mach-at91/board-1arm.c
index 367d5cd..a60d98d 100644
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
index 4282d96..17fc779 100644
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
index f90cfb3..2037d2c4 100644
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
index 5dffd3b..af5520c 100644
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
index 774c87f..529b356 100644
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
index fc885a4..04d2b9b 100644
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
index d35e65b..7a4c82e 100644
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
index c393666..b004b20 100644
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
index 586100e..e966de5 100644
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
index 45db7a3..3788fa5 100644
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
index 2f9c16d2..af7622e 100644
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
index 3bae73e..9628a3d 100644
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
index e61351f..5ba5244 100644
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
index ef816c1..56e7aee 100644
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
index 0a8fe6a..dc18759 100644
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
index 07421bd..5444d6a 100644
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
index 80a8c9c..022d0ce 100644
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
index 99fd7f8..ed27586 100644
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
diff --git a/arch/arm/mach-at91/board-rsi-ews.c b/arch/arm/mach-at91/board-rsi-ews.c
index e927df0..ed3b21f 100644
--- a/arch/arm/mach-at91/board-rsi-ews.c
+++ b/arch/arm/mach-at91/board-rsi-ews.c
@@ -60,7 +60,7 @@ static void __init rsi_ews_init_early(void)
 /*
  * Ethernet
  */
-static struct at91_eth_data rsi_ews_eth_data __initdata = {
+static struct macb_platform_data rsi_ews_eth_data __initdata = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9-l9260.c b/arch/arm/mach-at91/board-sam9-l9260.c
index 072d53a..3e4b50e 100644
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
index 4f10181..13478e1 100644
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
index bccdcf2..fcf194e 100644
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
index 64fc75c..78d27cc 100644
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
index 92de912..4e1ee9d 100644
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
index 0df01c6..fbec934 100644
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
diff --git a/arch/arm/mach-at91/board-usb-a926x.c b/arch/arm/mach-at91/board-usb-a926x.c
index 0a20bab..3d84233 100644
--- a/arch/arm/mach-at91/board-usb-a926x.c
+++ b/arch/arm/mach-at91/board-usb-a926x.c
@@ -146,7 +146,7 @@ static void __init ek_add_device_spi(void)
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-yl-9200.c b/arch/arm/mach-at91/board-yl-9200.c
index 649b052..009a151 100644
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
index eac92e9..e209a29 100644
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
index 1f17bde..7c756fb 100644
--- a/arch/avr32/boards/atngw100/setup.c
+++ b/arch/avr32/boards/atngw100/setup.c
@@ -109,7 +109,7 @@ struct eth_addr {
 	u8 addr[6];
 };
 static struct eth_addr __initdata hw_addr[2];
-static struct eth_platform_data __initdata eth_data[2];
+static struct macb_platform_data __initdata eth_data[2];
 
 static struct spi_board_info spi0_board_info[] __initdata = {
 	{
diff --git a/arch/avr32/boards/atstk1000/atstk1002.c b/arch/avr32/boards/atstk1000/atstk1002.c
index 4643ff5..c56ddac 100644
--- a/arch/avr32/boards/atstk1000/atstk1002.c
+++ b/arch/avr32/boards/atstk1000/atstk1002.c
@@ -105,7 +105,7 @@ struct eth_addr {
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
index 5d7ffca..67b111c 100644
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
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 56624d3..dfeb46c 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
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
diff --git a/drivers/net/ethernet/cadence/at91_ether.h b/drivers/net/ethernet/cadence/at91_ether.h
index 353f4da..3725fbb0 100644
--- a/drivers/net/ethernet/cadence/at91_ether.h
+++ b/drivers/net/ethernet/cadence/at91_ether.h
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
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index b0fa478..d97d9ce 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
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
