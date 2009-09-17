From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 1/3] at91sam9263: add at91_can device to generic device
	definition
Date: Thu, 17 Sep 2009 11:37:32 +0200
Message-ID: <1253180254-11910-2-git-send-email-mkl@pengutronix.de>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, Andrew Victor <linux-PelNFVqkFnVyf+4FbqDuWQ@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1253180254-11910-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the device definition for the at91_can device to
the generic device definiton file for the at91sam9263.

Signed-off-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
1.6.4.3
