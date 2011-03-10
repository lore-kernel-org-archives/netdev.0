From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 1/8] macb: unify at91 and avr32 platform data
Date: Thu, 10 Mar 2011 10:10:36 +0000
Message-ID: <1299751843-9743-2-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44704 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab1CJKKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:10:51 -0500
Received: by wya21 with SMTP id 21so1289486wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:10:50 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both at91 and avr32 defines its own platform data structure for
the macb driver and both share common structures though at91
includes a currently unused phy_irq_pin.  Create a common
eth_platform_data for macb that both at91 and avr32 can use.  In
future we can use this to support other architectures that use the
same IP block with the macb driver.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 arch/arm/mach-at91/at572d940hf_devices.c    |    6 +++---
 arch/arm/mach-at91/at91cap9_devices.c       |    6 +++---
 arch/arm/mach-at91/at91rm9200_devices.c     |    6 +++---
 arch/arm/mach-at91/at91sam9260_devices.c    |    6 +++---
 arch/arm/mach-at91/at91sam9263_devices.c    |    6 +++---
 arch/arm/mach-at91/at91sam9g45_devices.c    |    6 +++---
 arch/arm/mach-at91/board-1arm.c             |    2 +-
 arch/arm/mach-at91/board-afeb-9260v1.c      |    2 +-
 arch/arm/mach-at91/board-at572d940hf_ek.c   |    2 +-
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
 arch/avr32/mach-at32ap/include/mach/board.h |    5 +----
 drivers/net/macb.c                          |    4 +---
 include/linux/platform_data/macb.h          |   10 ++++++++++
 43 files changed, 65 insertions(+), 70 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

diff --git a/arch/arm/mach-at91/at572d940hf_devices.c b/arch/arm/mach-at91/at572d940hf_devices.c
index 0fc20a2..6e1b9a3 100644
--- a/arch/arm/mach-at91/at572d940hf_devices.c
+++ b/arch/arm/mach-at91/at572d940hf_devices.c
@@ -140,7 +140,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -167,7 +167,7 @@ static struct platform_device at572d940hf_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -196,7 +196,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at572d940hf_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91cap9_devices.c b/arch/arm/mach-at91/at91cap9_devices.c
index d1f775e..e041743 100644
--- a/arch/arm/mach-at91/at91cap9_devices.c
+++ b/arch/arm/mach-at91/at91cap9_devices.c
@@ -198,7 +198,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -225,7 +225,7 @@ static struct platform_device at91cap9_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -262,7 +262,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91cap9_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91rm9200_devices.c b/arch/arm/mach-at91/at91rm9200_devices.c
index 7b53922..5f873d5 100644
--- a/arch/arm/mach-at91/at91rm9200_devices.c
+++ b/arch/arm/mach-at91/at91rm9200_devices.c
@@ -127,7 +127,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_ARM_AT91_ETHER) || defined(CONFIG_ARM_AT91_ETHER_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -154,7 +154,7 @@ static struct platform_device at91rm9200_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -191,7 +191,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91rm9200_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9260_devices.c b/arch/arm/mach-at91/at91sam9260_devices.c
index 07eb7b0..e172b46 100644
--- a/arch/arm/mach-at91/at91sam9260_devices.c
+++ b/arch/arm/mach-at91/at91sam9260_devices.c
@@ -128,7 +128,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -155,7 +155,7 @@ static struct platform_device at91sam9260_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -192,7 +192,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9260_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
index fb5c23a..416613c 100644
--- a/arch/arm/mach-at91/at91sam9263_devices.c
+++ b/arch/arm/mach-at91/at91sam9263_devices.c
@@ -138,7 +138,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -165,7 +165,7 @@ static struct platform_device at91sam9263_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -202,7 +202,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9263_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91sam9g45_devices.c b/arch/arm/mach-at91/at91sam9g45_devices.c
index 1e8f275..0867343 100644
--- a/arch/arm/mach-at91/at91sam9g45_devices.c
+++ b/arch/arm/mach-at91/at91sam9g45_devices.c
@@ -283,7 +283,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct eth_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -310,7 +310,7 @@ static struct platform_device at91sam9g45_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct eth_platform_data *data)
 {
 	if (!data)
 		return;
@@ -347,7 +347,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9g45_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct eth_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/board-1arm.c b/arch/arm/mach-at91/board-1arm.c
index 8a3fc84..1961d1e 100644
--- a/arch/arm/mach-at91/board-1arm.c
+++ b/arch/arm/mach-at91/board-1arm.c
@@ -64,7 +64,7 @@ static void __init onearm_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata onearm_eth_data = {
+static struct eth_platform_data __initdata onearm_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-afeb-9260v1.c b/arch/arm/mach-at91/board-afeb-9260v1.c
index cba7f77..8943ff3 100644
--- a/arch/arm/mach-at91/board-afeb-9260v1.c
+++ b/arch/arm/mach-at91/board-afeb-9260v1.c
@@ -109,7 +109,7 @@ static struct spi_board_info afeb9260_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata afeb9260_macb_data = {
+static struct eth_platform_data __initdata afeb9260_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA9,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-at572d940hf_ek.c b/arch/arm/mach-at91/board-at572d940hf_ek.c
index 3929f1c..a17d8e7 100644
--- a/arch/arm/mach-at91/board-at572d940hf_ek.c
+++ b/arch/arm/mach-at91/board-at572d940hf_ek.c
@@ -104,7 +104,7 @@ static struct at91_mmc_data __initdata eb_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata eb_eth_data = {
+static struct eth_platform_data __initdata eb_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PB25,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-cam60.c b/arch/arm/mach-at91/board-cam60.c
index b54e3e6..8cc6bfc 100644
--- a/arch/arm/mach-at91/board-cam60.c
+++ b/arch/arm/mach-at91/board-cam60.c
@@ -121,7 +121,7 @@ static struct spi_board_info cam60_spi_devices[] __initdata = {
 /*
  * MACB Ethernet device
  */
-static struct __initdata at91_eth_data cam60_macb_data = {
+static struct __initdata eth_platform_data cam60_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PB5,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-cap9adk.c b/arch/arm/mach-at91/board-cap9adk.c
index e727444..8f9bc88 100644
--- a/arch/arm/mach-at91/board-cap9adk.c
+++ b/arch/arm/mach-at91/board-cap9adk.c
@@ -158,7 +158,7 @@ static struct at91_mmc_data __initdata cap9adk_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cap9adk_macb_data = {
+static struct eth_platform_data __initdata cap9adk_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-carmeva.c b/arch/arm/mach-at91/board-carmeva.c
index 2e74a19..dbc9061 100644
--- a/arch/arm/mach-at91/board-carmeva.c
+++ b/arch/arm/mach-at91/board-carmeva.c
@@ -62,7 +62,7 @@ static void __init carmeva_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata carmeva_eth_data = {
+static struct eth_platform_data __initdata carmeva_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-cpu9krea.c b/arch/arm/mach-at91/board-cpu9krea.c
index 3838594..a7d0843 100644
--- a/arch/arm/mach-at91/board-cpu9krea.c
+++ b/arch/arm/mach-at91/board-cpu9krea.c
@@ -104,7 +104,7 @@ static struct at91_udc_data __initdata cpu9krea_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cpu9krea_macb_data = {
+static struct eth_platform_data __initdata cpu9krea_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-cpuat91.c b/arch/arm/mach-at91/board-cpuat91.c
index 2f4dd8c..52909f0 100644
--- a/arch/arm/mach-at91/board-cpuat91.c
+++ b/arch/arm/mach-at91/board-cpuat91.c
@@ -83,7 +83,7 @@ static void __init cpuat91_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata cpuat91_eth_data = {
+static struct eth_platform_data __initdata cpuat91_eth_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-csb337.c b/arch/arm/mach-at91/board-csb337.c
index 464839d..7e062fa 100644
--- a/arch/arm/mach-at91/board-csb337.c
+++ b/arch/arm/mach-at91/board-csb337.c
@@ -63,7 +63,7 @@ static void __init csb337_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata csb337_eth_data = {
+static struct eth_platform_data __initdata csb337_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-csb637.c b/arch/arm/mach-at91/board-csb637.c
index 431688c..fb8456e 100644
--- a/arch/arm/mach-at91/board-csb637.c
+++ b/arch/arm/mach-at91/board-csb637.c
@@ -57,7 +57,7 @@ static void __init csb637_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata csb637_eth_data = {
+static struct eth_platform_data __initdata csb637_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC0,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eb9200.c b/arch/arm/mach-at91/board-eb9200.c
index 6cf6566..ac71845 100644
--- a/arch/arm/mach-at91/board-eb9200.c
+++ b/arch/arm/mach-at91/board-eb9200.c
@@ -65,7 +65,7 @@ static void __init eb9200_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata eb9200_eth_data = {
+static struct eth_platform_data __initdata eb9200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-ecbat91.c b/arch/arm/mach-at91/board-ecbat91.c
index de2fd04..aa8fb2a 100644
--- a/arch/arm/mach-at91/board-ecbat91.c
+++ b/arch/arm/mach-at91/board-ecbat91.c
@@ -65,7 +65,7 @@ static void __init ecb_at91init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata ecb_at91eth_data = {
+static struct eth_platform_data __initdata ecb_at91eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eco920.c b/arch/arm/mach-at91/board-eco920.c
index a158a0c..a1e9173 100644
--- a/arch/arm/mach-at91/board-eco920.c
+++ b/arch/arm/mach-at91/board-eco920.c
@@ -47,7 +47,7 @@ static void __init eco920_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata eco920_eth_data = {
+static struct eth_platform_data __initdata eco920_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-foxg20.c b/arch/arm/mach-at91/board-foxg20.c
index dfc7dfe..b7630b9 100644
--- a/arch/arm/mach-at91/board-foxg20.c
+++ b/arch/arm/mach-at91/board-foxg20.c
@@ -141,7 +141,7 @@ static struct spi_board_info foxg20_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata foxg20_macb_data = {
+static struct eth_platform_data __initdata foxg20_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-gsia18s.c b/arch/arm/mach-at91/board-gsia18s.c
index bc28136..0405b17 100644
--- a/arch/arm/mach-at91/board-gsia18s.c
+++ b/arch/arm/mach-at91/board-gsia18s.c
@@ -98,7 +98,7 @@ static struct at91_udc_data __initdata udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct eth_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-kafa.c b/arch/arm/mach-at91/board-kafa.c
index d2e1f4e..f45fc82 100644
--- a/arch/arm/mach-at91/board-kafa.c
+++ b/arch/arm/mach-at91/board-kafa.c
@@ -62,7 +62,7 @@ static void __init kafa_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata kafa_eth_data = {
+static struct eth_platform_data __initdata kafa_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-kb9202.c b/arch/arm/mach-at91/board-kb9202.c
index a13d206..88a40c2 100644
--- a/arch/arm/mach-at91/board-kb9202.c
+++ b/arch/arm/mach-at91/board-kb9202.c
@@ -71,7 +71,7 @@ static void __init kb9202_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata kb9202_eth_data = {
+static struct eth_platform_data __initdata kb9202_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PB29,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-neocore926.c b/arch/arm/mach-at91/board-neocore926.c
index fe5f1d4..97890d8 100644
--- a/arch/arm/mach-at91/board-neocore926.c
+++ b/arch/arm/mach-at91/board-neocore926.c
@@ -161,7 +161,7 @@ static struct at91_mmc_data __initdata neocore926_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata neocore926_macb_data = {
+static struct eth_platform_data __initdata neocore926_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-pcontrol-g20.c b/arch/arm/mach-at91/board-pcontrol-g20.c
index feb6578..03e8286 100644
--- a/arch/arm/mach-at91/board-pcontrol-g20.c
+++ b/arch/arm/mach-at91/board-pcontrol-g20.c
@@ -129,7 +129,7 @@ static struct at91_udc_data __initdata pcontrol_g20_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct eth_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-picotux200.c b/arch/arm/mach-at91/board-picotux200.c
index 55dad3a..3f3cd9c 100644
--- a/arch/arm/mach-at91/board-picotux200.c
+++ b/arch/arm/mach-at91/board-picotux200.c
@@ -65,7 +65,7 @@ static void __init picotux200_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata picotux200_eth_data = {
+static struct eth_platform_data __initdata picotux200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-qil-a9260.c b/arch/arm/mach-at91/board-qil-a9260.c
index 69d15a8..165e43e 100644
--- a/arch/arm/mach-at91/board-qil-a9260.c
+++ b/arch/arm/mach-at91/board-qil-a9260.c
@@ -110,7 +110,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200dk.c b/arch/arm/mach-at91/board-rm9200dk.c
index 4c1047c..c31cdda 100644
--- a/arch/arm/mach-at91/board-rm9200dk.c
+++ b/arch/arm/mach-at91/board-rm9200dk.c
@@ -70,7 +70,7 @@ static void __init dk_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata dk_eth_data = {
+static struct eth_platform_data __initdata dk_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200ek.c b/arch/arm/mach-at91/board-rm9200ek.c
index 9df1be8..0fe93aa 100644
--- a/arch/arm/mach-at91/board-rm9200ek.c
+++ b/arch/arm/mach-at91/board-rm9200ek.c
@@ -70,7 +70,7 @@ static void __init ek_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata ek_eth_data = {
+static struct eth_platform_data __initdata ek_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9-l9260.c b/arch/arm/mach-at91/board-sam9-l9260.c
index 25a26be..145884d 100644
--- a/arch/arm/mach-at91/board-sam9-l9260.c
+++ b/arch/arm/mach-at91/board-sam9-l9260.c
@@ -115,7 +115,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-sam9260ek.c b/arch/arm/mach-at91/board-sam9260ek.c
index de1816e..fcaedf5 100644
--- a/arch/arm/mach-at91/board-sam9260ek.c
+++ b/arch/arm/mach-at91/board-sam9260ek.c
@@ -156,7 +156,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9263ek.c b/arch/arm/mach-at91/board-sam9263ek.c
index bfe490d..4f799a4 100644
--- a/arch/arm/mach-at91/board-sam9263ek.c
+++ b/arch/arm/mach-at91/board-sam9263ek.c
@@ -163,7 +163,7 @@ static struct at91_mmc_data __initdata ek_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9g20ek.c b/arch/arm/mach-at91/board-sam9g20ek.c
index ca8198b..d54b3e6 100644
--- a/arch/arm/mach-at91/board-sam9g20ek.c
+++ b/arch/arm/mach-at91/board-sam9g20ek.c
@@ -128,7 +128,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9m10g45ek.c b/arch/arm/mach-at91/board-sam9m10g45ek.c
index 6c999db..7df85eb 100644
--- a/arch/arm/mach-at91/board-sam9m10g45ek.c
+++ b/arch/arm/mach-at91/board-sam9m10g45ek.c
@@ -120,7 +120,7 @@ static struct mci_platform_data __initdata mci1_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PD5,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-snapper9260.c b/arch/arm/mach-at91/board-snapper9260.c
index 17f7d9b..6902e7d 100644
--- a/arch/arm/mach-at91/board-snapper9260.c
+++ b/arch/arm/mach-at91/board-snapper9260.c
@@ -70,7 +70,7 @@ static struct at91_udc_data __initdata snapper9260_udc_data = {
 	.vbus_polled		= 1,
 };
 
-static struct at91_eth_data snapper9260_macb_data = {
+static struct eth_platform_data snapper9260_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-stamp9g20.c b/arch/arm/mach-at91/board-stamp9g20.c
index f8902b1..9a7c586 100644
--- a/arch/arm/mach-at91/board-stamp9g20.c
+++ b/arch/arm/mach-at91/board-stamp9g20.c
@@ -163,7 +163,7 @@ static struct at91_udc_data __initdata stamp9g20evb_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct eth_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9260.c b/arch/arm/mach-at91/board-usb-a9260.c
index 07784ba..c756389 100644
--- a/arch/arm/mach-at91/board-usb-a9260.c
+++ b/arch/arm/mach-at91/board-usb-a9260.c
@@ -84,7 +84,7 @@ static struct at91_udc_data __initdata ek_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9263.c b/arch/arm/mach-at91/board-usb-a9263.c
index b614508..e6c260d 100644
--- a/arch/arm/mach-at91/board-usb-a9263.c
+++ b/arch/arm/mach-at91/board-usb-a9263.c
@@ -97,7 +97,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct eth_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-yl-9200.c b/arch/arm/mach-at91/board-yl-9200.c
index e0f0080..102dfc1 100644
--- a/arch/arm/mach-at91/board-yl-9200.c
+++ b/arch/arm/mach-at91/board-yl-9200.c
@@ -112,7 +112,7 @@ static struct gpio_led yl9200_leds[] = {
 /*
  * Ethernet
  */
-static struct at91_eth_data __initdata yl9200_eth_data = {
+static struct eth_platform_data __initdata yl9200_eth_data = {
 	.phy_irq_pin		= AT91_PIN_PB28,
 	.is_rmii		= 1,
 };
diff --git a/arch/arm/mach-at91/include/mach/board.h b/arch/arm/mach-at91/include/mach/board.h
index 2b499eb..d970420 100644
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
-	|| defined(CONFIG_ARCH_AT91SAM9G45) || defined(CONFIG_ARCH_AT572D940HF)
-#define eth_platform_data	at91_eth_data
-#endif
+extern void __init at91_add_device_eth(struct eth_platform_data *data);
 
  /* USB Host */
 struct at91_usbh_data {
diff --git a/arch/avr32/mach-at32ap/include/mach/board.h b/arch/avr32/mach-at32ap/include/mach/board.h
index 6174020..3d79356 100644
--- a/arch/avr32/mach-at32ap/include/mach/board.h
+++ b/arch/avr32/mach-at32ap/include/mach/board.h
@@ -6,6 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/serial.h>
+#include <linux/platform_data/macb.h>
 
 #define GPIO_PIN_NONE	(-1)
 
@@ -41,10 +42,6 @@ struct atmel_uart_data {
 void at32_map_usart(unsigned int hw_id, unsigned int line, int flags);
 struct platform_device *at32_add_device_usart(unsigned int id);
 
-struct eth_platform_data {
-	u32	phy_mask;
-	u8	is_rmii;
-};
 struct platform_device *
 at32_add_device_eth(unsigned int id, struct eth_platform_data *data);
 
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 79ccb54..bfd3601 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -18,12 +18,10 @@
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
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
new file mode 100644
index 0000000..beddfd3
--- /dev/null
+++ b/include/linux/platform_data/macb.h
@@ -0,0 +1,10 @@
+#ifndef __MACB_PDATA_H__
+#define __MACB_PDATA_H__
+
+struct eth_platform_data {
+	u32		phy_mask;
+	u8		phy_irq_pin;	/* PHY IRQ */
+	u8		is_rmii;	/* using RMII interface? */
+};
+
+#endif /* __MACB_PDATA_H__ */
-- 
1.7.4

