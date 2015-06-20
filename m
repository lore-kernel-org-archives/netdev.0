From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] rcar_can: print request_irq() error code
Date: Sat, 20 Jun 2015 03:50:35 +0300
Message-ID: <1636106.QZXWqHuxCQ@wasted.cogentembedded.com>
References: <1593397.kKIHxKLe5s@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1593397.kKIHxKLe5s@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also print the error code when the request_irq() call fails in rcar_can_open(),
rewording  the error message...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/can/rcar_can.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-can/drivers/net/can/rcar_can.c
===================================================================
--- linux-can.orig/drivers/net/can/rcar_can.c
+++ linux-can/drivers/net/can/rcar_can.c
@@ -527,7 +527,8 @@ static int rcar_can_open(struct net_devi
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
To unsubscribe from this list: send the line "unsubscribe linux-sh" in
