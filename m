From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 8/8] can: at91_can: add missing prepare and unprepare of the clock
Date: Thu, 18 Sep 2014 12:41:02 +0200
Message-ID: <1411036862-13255-9-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, David Dueck <davidcdueck@googlemail.com>,
	Anthony Harivel <anthony.harivel@emtrion.de>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Dueck <davidcdueck@googlemail.com>

In order to make the driver work with the common clock framework, this patch
converts the clk_enable()/clk_disable() to
clk_prepare_enable()/clk_disable_unprepare(). While there, add the missing
error handling.

Signed-off-by: David Dueck <davidcdueck@googlemail.com>
Signed-off-by: Anthony Harivel <anthony.harivel@emtrion.de>
Acked-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index f07fa89..05e1aa0 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1123,7 +1123,9 @@ static int at91_open(struct net_device *dev)
 	struct at91_priv *priv = netdev_priv(dev);
 	int err;
 
-	clk_enable(priv->clk);
+	err = clk_prepare_enable(priv->clk);
+	if (err)
+		return err;
 
 	/* check or determine and set bittime */
 	err = open_candev(dev);
@@ -1149,7 +1151,7 @@ static int at91_open(struct net_device *dev)
  out_close:
 	close_candev(dev);
  out:
-	clk_disable(priv->clk);
+	clk_disable_unprepare(priv->clk);
 
 	return err;
 }
@@ -1166,7 +1168,7 @@ static int at91_close(struct net_device *dev)
 	at91_chip_stop(dev, CAN_STATE_STOPPED);
 
 	free_irq(dev->irq, dev);
-	clk_disable(priv->clk);
+	clk_disable_unprepare(priv->clk);
 
 	close_candev(dev);
 
-- 
2.1.0

