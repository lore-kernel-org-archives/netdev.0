From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Thu, 17 Mar 2011 21:51:01 +0000
Message-ID: <20110317215101.GC2927@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-4-git-send-email-jamie@jamieiles.com>
 <87vczkmy94.fsf@macbook.be.48ers.dk>
 <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
 <871v26m8tf.fsf@macbook.be.48ers.dk>
 <20110317085835.GC29758@n2100.arm.linux.org.uk>
 <87wrjyksnm.fsf@macbook.be.48ers.dk>
 <20110317093403.GA15396@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Korsgaard <jacmet@sunsite.dk>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"avictor.za@gmail.com" <avictor.za@gmail.com>,
	plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49067 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755682Ab1CQVvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 17:51:07 -0400
Received: by bwz15 with SMTP id 15so2863820bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 14:51:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110317093403.GA15396@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 09:34:03AM +0000, Jamie Iles wrote:
> Ok, I'll rename to macb_platform_data and update at91_ether to use 
> that with a comment describing that we're sharing the platform data 
> with macb.  At least that gets rid of the preprocessor stuff in 
> board.h for at91 too.

So here's the updated patch with changes to the at91_ether driver to 
share the data with macb.

Russell, are you happy to take this series?  If so, how would you prefer 
it, in the patch system or as a git pull?

Jamie

----

>From 7e719117365953dbabe292c1fbc5bd0c1590698c Mon Sep 17 00:00:00 2001
From: Jamie Iles <jamie@jamieiles.com>
Date: Tue, 8 Mar 2011 20:17:06 +0000
Subject: [PATCHv3 3/9] macb: unify at91 and avr32 platform data

Both at91 and avr32 defines its own platform data structure for
the macb driver and both share common structures though at91
includes a currently unused phy_irq_pin.  Create a common
macb_platform_data for macb that both at91 and avr32 can use.  In
future we can use this to support other architectures that use the
same IP block with the macb driver.

v2: rename eth_platform_data to macb_platform_data and allow at91_ether
to share the platform data with macb.

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
 52 files changed, 91 insertions(+), 86 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

diff --git a/arch/arm/mach-at91/at572d940hf_devices.c b/arch/arm/mach-at91/at572d940hf_devices.c
index 0fc20a2..503b080 100644
--- a/arch/arm/mach-at91/at572d940hf_devices.c
+++ b/arch/arm/mach-at91/at572d940hf_devices.c
@@ -140,7 +140,7 @@ void __init at91_add_device_udc(struct at91_udc_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -167,7 +167,7 @@ static struct platform_device at572d940hf_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -196,7 +196,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at572d940hf_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91cap9_devices.c b/arch/arm/mach-at91/at91cap9_devices.c
index d1f775e..70d39fec 100644
--- a/arch/arm/mach-at91/at91cap9_devices.c
+++ b/arch/arm/mach-at91/at91cap9_devices.c
@@ -198,7 +198,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -225,7 +225,7 @@ static struct platform_device at91cap9_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -262,7 +262,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91cap9_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/at91rm9200_devices.c b/arch/arm/mach-at91/at91rm9200_devices.c
index 7b53922..ca504a0 100644
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
index 07eb7b0..f6d4c57 100644
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
index fb5c23a..d4a310c 100644
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
index 1e8f275..679247f 100644
--- a/arch/arm/mach-at91/at91sam9g45_devices.c
+++ b/arch/arm/mach-at91/at91sam9g45_devices.c
@@ -283,7 +283,7 @@ void __init at91_add_device_usba(struct usba_platform_data *data) {}
 
 #if defined(CONFIG_MACB) || defined(CONFIG_MACB_MODULE)
 static u64 eth_dmamask = DMA_BIT_MASK(32);
-static struct at91_eth_data eth_data;
+static struct macb_platform_data eth_data;
 
 static struct resource eth_resources[] = {
 	[0] = {
@@ -310,7 +310,7 @@ static struct platform_device at91sam9g45_eth_device = {
 	.num_resources	= ARRAY_SIZE(eth_resources),
 };
 
-void __init at91_add_device_eth(struct at91_eth_data *data)
+void __init at91_add_device_eth(struct macb_platform_data *data)
 {
 	if (!data)
 		return;
@@ -347,7 +347,7 @@ void __init at91_add_device_eth(struct at91_eth_data *data)
 	platform_device_register(&at91sam9g45_eth_device);
 }
 #else
-void __init at91_add_device_eth(struct at91_eth_data *data) {}
+void __init at91_add_device_eth(struct macb_platform_data *data) {}
 #endif
 
 
diff --git a/arch/arm/mach-at91/board-1arm.c b/arch/arm/mach-at91/board-1arm.c
index 8a3fc84..ab4fefc 100644
--- a/arch/arm/mach-at91/board-1arm.c
+++ b/arch/arm/mach-at91/board-1arm.c
@@ -64,7 +64,7 @@ static void __init onearm_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata onearm_eth_data = {
+static struct macb_platform_data __initdata onearm_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-afeb-9260v1.c b/arch/arm/mach-at91/board-afeb-9260v1.c
index cba7f77..6d8bfa1 100644
--- a/arch/arm/mach-at91/board-afeb-9260v1.c
+++ b/arch/arm/mach-at91/board-afeb-9260v1.c
@@ -109,7 +109,7 @@ static struct spi_board_info afeb9260_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata afeb9260_macb_data = {
+static struct macb_platform_data __initdata afeb9260_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA9,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-at572d940hf_ek.c b/arch/arm/mach-at91/board-at572d940hf_ek.c
index 3929f1c..c57cf34 100644
--- a/arch/arm/mach-at91/board-at572d940hf_ek.c
+++ b/arch/arm/mach-at91/board-at572d940hf_ek.c
@@ -104,7 +104,7 @@ static struct at91_mmc_data __initdata eb_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata eb_eth_data = {
+static struct macb_platform_data __initdata eb_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PB25,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-cam60.c b/arch/arm/mach-at91/board-cam60.c
index b54e3e6..fcab5ba 100644
--- a/arch/arm/mach-at91/board-cam60.c
+++ b/arch/arm/mach-at91/board-cam60.c
@@ -121,7 +121,7 @@ static struct spi_board_info cam60_spi_devices[] __initdata = {
 /*
  * MACB Ethernet device
  */
-static struct __initdata at91_eth_data cam60_macb_data = {
+static struct __initdata macb_platform_data cam60_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PB5,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-cap9adk.c b/arch/arm/mach-at91/board-cap9adk.c
index e727444..6196438 100644
--- a/arch/arm/mach-at91/board-cap9adk.c
+++ b/arch/arm/mach-at91/board-cap9adk.c
@@ -158,7 +158,7 @@ static struct at91_mmc_data __initdata cap9adk_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cap9adk_macb_data = {
+static struct macb_platform_data __initdata cap9adk_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-carmeva.c b/arch/arm/mach-at91/board-carmeva.c
index 2e74a19..a5db698 100644
--- a/arch/arm/mach-at91/board-carmeva.c
+++ b/arch/arm/mach-at91/board-carmeva.c
@@ -62,7 +62,7 @@ static void __init carmeva_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata carmeva_eth_data = {
+static struct macb_platform_data __initdata carmeva_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-cpu9krea.c b/arch/arm/mach-at91/board-cpu9krea.c
index 3838594..0cd73fc 100644
--- a/arch/arm/mach-at91/board-cpu9krea.c
+++ b/arch/arm/mach-at91/board-cpu9krea.c
@@ -104,7 +104,7 @@ static struct at91_udc_data __initdata cpu9krea_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata cpu9krea_macb_data = {
+static struct macb_platform_data __initdata cpu9krea_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-cpuat91.c b/arch/arm/mach-at91/board-cpuat91.c
index 2f4dd8c..1faf4ff 100644
--- a/arch/arm/mach-at91/board-cpuat91.c
+++ b/arch/arm/mach-at91/board-cpuat91.c
@@ -83,7 +83,7 @@ static void __init cpuat91_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata cpuat91_eth_data = {
+static struct macb_platform_data __initdata cpuat91_eth_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-csb337.c b/arch/arm/mach-at91/board-csb337.c
index 464839d..e090e3b 100644
--- a/arch/arm/mach-at91/board-csb337.c
+++ b/arch/arm/mach-at91/board-csb337.c
@@ -63,7 +63,7 @@ static void __init csb337_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata csb337_eth_data = {
+static struct macb_platform_data __initdata csb337_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-csb637.c b/arch/arm/mach-at91/board-csb637.c
index 431688c..01d5e01 100644
--- a/arch/arm/mach-at91/board-csb637.c
+++ b/arch/arm/mach-at91/board-csb637.c
@@ -57,7 +57,7 @@ static void __init csb637_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata csb637_eth_data = {
+static struct macb_platform_data __initdata csb637_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC0,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eb9200.c b/arch/arm/mach-at91/board-eb9200.c
index 6cf6566..5a439ec 100644
--- a/arch/arm/mach-at91/board-eb9200.c
+++ b/arch/arm/mach-at91/board-eb9200.c
@@ -65,7 +65,7 @@ static void __init eb9200_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata eb9200_eth_data = {
+static struct macb_platform_data __initdata eb9200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-ecbat91.c b/arch/arm/mach-at91/board-ecbat91.c
index de2fd04..029832d 100644
--- a/arch/arm/mach-at91/board-ecbat91.c
+++ b/arch/arm/mach-at91/board-ecbat91.c
@@ -65,7 +65,7 @@ static void __init ecb_at91init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata ecb_at91eth_data = {
+static struct macb_platform_data __initdata ecb_at91eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-eco920.c b/arch/arm/mach-at91/board-eco920.c
index a158a0c..7475432 100644
--- a/arch/arm/mach-at91/board-eco920.c
+++ b/arch/arm/mach-at91/board-eco920.c
@@ -47,7 +47,7 @@ static void __init eco920_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata eco920_eth_data = {
+static struct macb_platform_data __initdata eco920_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-foxg20.c b/arch/arm/mach-at91/board-foxg20.c
index dfc7dfe..a405841 100644
--- a/arch/arm/mach-at91/board-foxg20.c
+++ b/arch/arm/mach-at91/board-foxg20.c
@@ -141,7 +141,7 @@ static struct spi_board_info foxg20_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata foxg20_macb_data = {
+static struct macb_platform_data __initdata foxg20_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-gsia18s.c b/arch/arm/mach-at91/board-gsia18s.c
index bc28136..5de9a6b 100644
--- a/arch/arm/mach-at91/board-gsia18s.c
+++ b/arch/arm/mach-at91/board-gsia18s.c
@@ -98,7 +98,7 @@ static struct at91_udc_data __initdata udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-kafa.c b/arch/arm/mach-at91/board-kafa.c
index d2e1f4e..0e1096c 100644
--- a/arch/arm/mach-at91/board-kafa.c
+++ b/arch/arm/mach-at91/board-kafa.c
@@ -62,7 +62,7 @@ static void __init kafa_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata kafa_eth_data = {
+static struct macb_platform_data __initdata kafa_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-kb9202.c b/arch/arm/mach-at91/board-kb9202.c
index a13d206..9fe14a2 100644
--- a/arch/arm/mach-at91/board-kb9202.c
+++ b/arch/arm/mach-at91/board-kb9202.c
@@ -71,7 +71,7 @@ static void __init kb9202_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata kb9202_eth_data = {
+static struct macb_platform_data __initdata kb9202_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PB29,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-neocore926.c b/arch/arm/mach-at91/board-neocore926.c
index fe5f1d4..02f2e4d 100644
--- a/arch/arm/mach-at91/board-neocore926.c
+++ b/arch/arm/mach-at91/board-neocore926.c
@@ -161,7 +161,7 @@ static struct at91_mmc_data __initdata neocore926_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata neocore926_macb_data = {
+static struct macb_platform_data __initdata neocore926_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-pcontrol-g20.c b/arch/arm/mach-at91/board-pcontrol-g20.c
index feb6578..a719aef 100644
--- a/arch/arm/mach-at91/board-pcontrol-g20.c
+++ b/arch/arm/mach-at91/board-pcontrol-g20.c
@@ -129,7 +129,7 @@ static struct at91_udc_data __initdata pcontrol_g20_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-picotux200.c b/arch/arm/mach-at91/board-picotux200.c
index 55dad3a..f7c5ae0 100644
--- a/arch/arm/mach-at91/board-picotux200.c
+++ b/arch/arm/mach-at91/board-picotux200.c
@@ -65,7 +65,7 @@ static void __init picotux200_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata picotux200_eth_data = {
+static struct macb_platform_data __initdata picotux200_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-qil-a9260.c b/arch/arm/mach-at91/board-qil-a9260.c
index 69d15a8..1173fd9 100644
--- a/arch/arm/mach-at91/board-qil-a9260.c
+++ b/arch/arm/mach-at91/board-qil-a9260.c
@@ -110,7 +110,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200dk.c b/arch/arm/mach-at91/board-rm9200dk.c
index 4c1047c..6dcb06a 100644
--- a/arch/arm/mach-at91/board-rm9200dk.c
+++ b/arch/arm/mach-at91/board-rm9200dk.c
@@ -70,7 +70,7 @@ static void __init dk_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata dk_eth_data = {
+static struct macb_platform_data __initdata dk_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-rm9200ek.c b/arch/arm/mach-at91/board-rm9200ek.c
index 9df1be8..e325eb8 100644
--- a/arch/arm/mach-at91/board-rm9200ek.c
+++ b/arch/arm/mach-at91/board-rm9200ek.c
@@ -70,7 +70,7 @@ static void __init ek_init_irq(void)
 	at91rm9200_init_interrupts(NULL);
 }
 
-static struct at91_eth_data __initdata ek_eth_data = {
+static struct macb_platform_data __initdata ek_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC4,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9-l9260.c b/arch/arm/mach-at91/board-sam9-l9260.c
index 25a26be..1e29e79 100644
--- a/arch/arm/mach-at91/board-sam9-l9260.c
+++ b/arch/arm/mach-at91/board-sam9-l9260.c
@@ -115,7 +115,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 0,
 };
diff --git a/arch/arm/mach-at91/board-sam9260ek.c b/arch/arm/mach-at91/board-sam9260ek.c
index de1816e..8c84331 100644
--- a/arch/arm/mach-at91/board-sam9260ek.c
+++ b/arch/arm/mach-at91/board-sam9260ek.c
@@ -156,7 +156,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9263ek.c b/arch/arm/mach-at91/board-sam9263ek.c
index bfe490d..a88d8c5 100644
--- a/arch/arm/mach-at91/board-sam9263ek.c
+++ b/arch/arm/mach-at91/board-sam9263ek.c
@@ -163,7 +163,7 @@ static struct at91_mmc_data __initdata ek_mmc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9g20ek.c b/arch/arm/mach-at91/board-sam9g20ek.c
index ca8198b..48a5f4c 100644
--- a/arch/arm/mach-at91/board-sam9g20ek.c
+++ b/arch/arm/mach-at91/board-sam9g20ek.c
@@ -128,7 +128,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA7,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-sam9m10g45ek.c b/arch/arm/mach-at91/board-sam9m10g45ek.c
index 6c999db..933a21d 100644
--- a/arch/arm/mach-at91/board-sam9m10g45ek.c
+++ b/arch/arm/mach-at91/board-sam9m10g45ek.c
@@ -120,7 +120,7 @@ static struct mci_platform_data __initdata mci1_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PD5,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-snapper9260.c b/arch/arm/mach-at91/board-snapper9260.c
index 0a99b3c..8c9eb1b 100644
--- a/arch/arm/mach-at91/board-snapper9260.c
+++ b/arch/arm/mach-at91/board-snapper9260.c
@@ -70,7 +70,7 @@ static struct at91_udc_data __initdata snapper9260_udc_data = {
 	.vbus_polled		= 1,
 };
 
-static struct at91_eth_data snapper9260_macb_data = {
+static struct macb_platform_data snapper9260_macb_data = {
 	.is_rmii	= 1,
 };
 
diff --git a/arch/arm/mach-at91/board-stamp9g20.c b/arch/arm/mach-at91/board-stamp9g20.c
index f8902b1..821afb0 100644
--- a/arch/arm/mach-at91/board-stamp9g20.c
+++ b/arch/arm/mach-at91/board-stamp9g20.c
@@ -163,7 +163,7 @@ static struct at91_udc_data __initdata stamp9g20evb_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata macb_data = {
+static struct macb_platform_data __initdata macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA28,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9260.c b/arch/arm/mach-at91/board-usb-a9260.c
index 07784ba..8cc7868 100644
--- a/arch/arm/mach-at91/board-usb-a9260.c
+++ b/arch/arm/mach-at91/board-usb-a9260.c
@@ -84,7 +84,7 @@ static struct at91_udc_data __initdata ek_udc_data = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PA31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-usb-a9263.c b/arch/arm/mach-at91/board-usb-a9263.c
index b614508..242da50 100644
--- a/arch/arm/mach-at91/board-usb-a9263.c
+++ b/arch/arm/mach-at91/board-usb-a9263.c
@@ -97,7 +97,7 @@ static struct spi_board_info ek_spi_devices[] = {
 /*
  * MACB Ethernet device
  */
-static struct at91_eth_data __initdata ek_macb_data = {
+static struct macb_platform_data __initdata ek_macb_data = {
 	.phy_irq_pin	= AT91_PIN_PE31,
 	.is_rmii	= 1,
 };
diff --git a/arch/arm/mach-at91/board-yl-9200.c b/arch/arm/mach-at91/board-yl-9200.c
index e0f0080..2aa861c 100644
--- a/arch/arm/mach-at91/board-yl-9200.c
+++ b/arch/arm/mach-at91/board-yl-9200.c
@@ -112,7 +112,7 @@ static struct gpio_led yl9200_leds[] = {
 /*
  * Ethernet
  */
-static struct at91_eth_data __initdata yl9200_eth_data = {
+static struct macb_platform_data __initdata yl9200_eth_data = {
 	.phy_irq_pin		= AT91_PIN_PB28,
 	.is_rmii		= 1,
 };
diff --git a/arch/arm/mach-at91/include/mach/board.h b/arch/arm/mach-at91/include/mach/board.h
index 2b499eb..5e5acc4 100644
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
+extern void __init at91_add_device_eth(struct macb_platform_data *data);
 
  /* USB Host */
 struct at91_usbh_data {
diff --git a/arch/avr32/boards/atngw100/setup.c b/arch/avr32/boards/atngw100/setup.c
index 659d119..1e14083 100644
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
index e67c999..a8d2e6c 100644
--- a/arch/avr32/mach-at32ap/at32ap700x.c
+++ b/arch/avr32/mach-at32ap/at32ap700x.c
@@ -1064,7 +1064,7 @@ void __init at32_setup_serial_console(unsigned int usart_id)
  * -------------------------------------------------------------------- */
 
 #ifdef CONFIG_CPU_AT32AP7000
-static struct eth_platform_data macb0_data;
+static struct macb_platform_data macb0_data;
 static struct resource macb0_resource[] = {
 	PBMEM(0xfff01800),
 	IRQ(25),
@@ -1073,7 +1073,7 @@ DEFINE_DEV_DATA(macb, 0);
 DEV_CLK(hclk, macb0, hsb, 8);
 DEV_CLK(pclk, macb0, pbb, 6);
 
-static struct eth_platform_data macb1_data;
+static struct macb_platform_data macb1_data;
 static struct resource macb1_resource[] = {
 	PBMEM(0xfff01c00),
 	IRQ(26),
@@ -1083,7 +1083,7 @@ DEV_CLK(hclk, macb1, hsb, 9);
 DEV_CLK(pclk, macb1, pbb, 7);
 
 struct platform_device *__init
-at32_add_device_eth(unsigned int id, struct eth_platform_data *data)
+at32_add_device_eth(unsigned int id, struct macb_platform_data *data)
 {
 	struct platform_device *pdev;
 	u32 pin_mask;
@@ -1160,7 +1160,7 @@ at32_add_device_eth(unsigned int id, struct eth_platform_data *data)
 		return NULL;
 	}
 
-	memcpy(pdev->dev.platform_data, data, sizeof(struct eth_platform_data));
+	memcpy(pdev->dev.platform_data, data, sizeof(struct macb_platform_data));
 	platform_device_register(pdev);
 
 	return pdev;
diff --git a/arch/avr32/mach-at32ap/include/mach/board.h b/arch/avr32/mach-at32ap/include/mach/board.h
index 6174020..cb340ae 100644
--- a/arch/avr32/mach-at32ap/include/mach/board.h
+++ b/arch/avr32/mach-at32ap/include/mach/board.h
@@ -6,6 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/serial.h>
+#include <linux/platform_data/macb.h>
 
 #define GPIO_PIN_NONE	(-1)
 
@@ -41,12 +42,8 @@ struct atmel_uart_data {
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
index e07b314..cb85318 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -25,6 +25,7 @@
 #include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/ethtool.h>
+#include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
 #include <linux/gfp.h>
@@ -983,7 +984,7 @@ static const struct net_device_ops at91ether_netdev_ops = {
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
index e3860d6..aee1e51 100644
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
@@ -190,7 +188,7 @@ static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev;
-	struct eth_platform_data *pdata;
+	struct macb_platform_data *pdata;
 	int ret;
 
 	phydev = phy_find_first(bp->mii_bus);
@@ -227,7 +225,7 @@ static int macb_mii_probe(struct net_device *dev)
 
 static int macb_mii_init(struct macb *bp)
 {
-	struct eth_platform_data *pdata;
+	struct macb_platform_data *pdata;
 	int err = -ENXIO, i;
 
 	/* Enable management port */
@@ -1107,7 +1105,7 @@ static const struct net_device_ops macb_netdev_ops = {
 
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
1.7.4

