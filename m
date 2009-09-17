From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 2/3] at91sam9263ek: activate at91 CAN controller
Date: Thu, 17 Sep 2009 11:37:33 +0200
Message-ID: <1253180254-11910-3-git-send-email-mkl@pengutronix.de>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>
	<1253180254-11910-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, Andrew Victor <linux-PelNFVqkFnVyf+4FbqDuWQ@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1253180254-11910-2-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

This patch activates the at91 CAN controller for the at91sam9263ek
development board.

Signed-off-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 arch/arm/mach-at91/board-sam9263ek.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-at91/board-sam9263ek.c b/arch/arm/mach-at91/board-sam9263ek.c
index 57d5252..e6268b3 100644
--- a/arch/arm/mach-at91/board-sam9263ek.c
+++ b/arch/arm/mach-at91/board-sam9263ek.c
@@ -400,6 +400,23 @@ static struct gpio_led ek_pwm_led[] = {
 	}
 };
 
+/*
+ * CAN
+ */
+static void sam9263ek_transceiver_switch(int on)
+{
+	if (on) {
+		at91_set_gpio_output(AT91_PIN_PA18, 1); /* CANRXEN */
+		at91_set_gpio_output(AT91_PIN_PA19, 0); /* CANRS */
+	} else {
+		at91_set_gpio_output(AT91_PIN_PA18, 0); /* CANRXEN */
+		at91_set_gpio_output(AT91_PIN_PA19, 1); /* CANRS */
+	}
+}
+
+static struct at91_can_data ek_can_data = {
+	.transceiver_switch = sam9263ek_transceiver_switch,
+};
 
 static void __init ek_board_init(void)
 {
@@ -431,6 +448,8 @@ static void __init ek_board_init(void)
 	/* LEDs */
 	at91_gpio_leds(ek_leds, ARRAY_SIZE(ek_leds));
 	at91_pwm_leds(ek_pwm_led, ARRAY_SIZE(ek_pwm_led));
+	/* CAN */
+	at91_add_device_can(&ek_can_data);
 }
 
 MACHINE_START(AT91SAM9263EK, "Atmel AT91SAM9263-EK")
-- 
1.6.4.3
