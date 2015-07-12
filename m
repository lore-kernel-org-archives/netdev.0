From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/8] can: rcar_can: print request_irq() error code
Date: Sun, 12 Jul 2015 21:18:07 +0200
Message-ID: <1436728691-1145-5-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Also print the error code when the request_irq() call fails in rcar_can_open(),
rewording  the error message...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 310a0cd20679..5e81afffc073 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -527,7 +527,8 @@ static int rcar_can_open(struct net_device *ndev)
 	napi_enable(&priv->napi);
 	err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
 	if (err) {
-		netdev_err(ndev, "error requesting interrupt %d\n", ndev->irq);
+		netdev_err(ndev, "request_irq(%d) failed, error %d\n",
+			   ndev->irq, err);
 		goto out_close;
 	}
 	can_led_event(ndev, CAN_LED_EVENT_OPEN);
-- 
2.1.4

