From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: only rename enabled led triggers when changing the netdev name
Date: Wed, 28 May 2014 10:04:43 +0200
Message-ID: <1401264283-9353-2-git-send-email-mkl@pengutronix.de>
References: <1401264283-9353-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Fabio Baltieri <fabio.baltieri@gmail.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1401264283-9353-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

Commit a1ef7bd9fce8 ("can: rename LED trigger name on netdev renames") renames
the led trigger names according to the changed netdevice name.

As not every CAN driver supports and initializes the led triggers, checking for
the CAN private datastructure with safe_candev_priv() in the notifier chain is
not enough.

This patch adds a check when CONFIG_CAN_LEDS is enabled and the driver does not
support led triggers.

Cc: Fabio Baltieri <fabio.baltieri@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Acked-by: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Cc: linux-stable <stable@vger.kernel.org> # >= v3.9
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/led.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/led.c b/drivers/net/can/led.c
index a3d99a8..ab7f1b0 100644
--- a/drivers/net/can/led.c
+++ b/drivers/net/can/led.c
@@ -97,6 +97,9 @@ static int can_led_notifier(struct notifier_block *nb, unsigned long msg,
 	if (!priv)
 		return NOTIFY_DONE;
 
+	if (!priv->tx_led_trig || !priv->rx_led_trig)
+		return NOTIFY_DONE;
+
 	if (msg == NETDEV_CHANGENAME) {
 		snprintf(name, sizeof(name), "%s-tx", netdev->name);
 		led_trigger_rename_static(name, priv->tx_led_trig);
-- 
2.0.0.rc2

