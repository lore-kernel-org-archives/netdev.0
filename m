From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] at91sam9263: add at91_can device to generic device definition
Date: Wed, 16 Sep 2009 11:46:43 +0200
Message-ID: <1253094405-3216-2-git-send-email-mkl@pengutronix.de>
References: <1253094405-3216-1-git-send-email-mkl@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"Hans J. Koch" <hjk@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57241 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbZIPJrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 05:47:02 -0400
In-Reply-To: <1253094405-3216-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the device definition for the at91_can device to
the generic device definiton file for the at91sam9263.

Signed-off-by: Hans J. Koch <hjk@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 arch/arm/mach-at91/at91sam9263_devices.c |   36 ++++++++++++++++++++++++++++++
 arch/arm/mach-at91/include/mach/board.h  |    6 +++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
index b7f2332..6026c2e 100644
--- a/arch/arm/mach-at91/at91sam9263_devices.c
+++ b/arch/arm/mach-at91/at91sam9263_devices.c
@@ -757,6 +757,42 @@ void __init at91_add_device_ac97(struct atmel_ac97_data *data)
 void __init at91_add_device_ac97(struct atmel_ac97_data *data) {}
 #endif
 
+/* --------------------------------------------------------------------
+ *  CAN Controller
+ * -------------------------------------------------------------------- */
+
+#if defined(CONFIG_CAN_AT91) || defined(CONFIG_CAN_AT91_MODULE)
+static struct resource can_resources[] = {
+	[0] = {
+		.start	= AT91SAM9263_BASE_CAN,
+		.end	= AT91SAM9263_BASE_CAN + SZ_16K - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start	= AT91SAM9263_ID_CAN,
+		.end	= AT91SAM9263_ID_CAN,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device at91sam9263_can_device = {
+	.name		= "at91_can",
+	.id		= -1,
+	.resource	= can_resources,
+	.num_resources	= ARRAY_SIZE(can_resources),
+};
+
+void __init at91_add_device_can(struct at91_can_data *data)
+{
+	at91_set_A_periph(AT91_PIN_PA13, 0);	/* CANTX */
+	at91_set_A_periph(AT91_PIN_PA14, 0);	/* CANRX */
+	at91sam9263_can_device.dev.platform_data = data;
+
+	platform_device_register(&at91sam9263_can_device);
+}
+#else
+void __init at91_add_device_can(struct at91_can_data *data) {}
+#endif
 
 /* --------------------------------------------------------------------
  *  LCD Controller
diff --git a/arch/arm/mach-at91/include/mach/board.h b/arch/arm/mach-at91/include/mach/board.h
index e6afff8..134731c 100644
--- a/arch/arm/mach-at91/include/mach/board.h
+++ b/arch/arm/mach-at91/include/mach/board.h
@@ -179,6 +179,12 @@ extern void __init at91_add_device_isi(void);
  /* Touchscreen Controller */
 extern void __init at91_add_device_tsadcc(void);
 
+/* CAN */
+struct at91_can_data {
+	void (*transceiver_switch)(int on);
+};
+extern void __init at91_add_device_can(struct at91_can_data *data);
+
  /* LEDs */
 extern void __init at91_init_leds(u8 cpu_led, u8 timer_led);
 extern void __init at91_gpio_leds(struct gpio_led *leds, int nr);
-- 
1.6.3.3

