From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: sun4i: fix loopback mode
Date: Tue, 24 Oct 2017 13:27:23 +0200
Message-ID: <20171024112725.13203-2-mkl@pengutronix.de>
References: <20171024112725.13203-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20171024112725.13203-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>

Fix loopback mode by setting the right flag and remove presume mode.

Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sun4i_can.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/can/sun4i_can.c b/drivers/net/can/sun4i_can.c
index 68ef0a4cd821..b0c80859f746 100644
--- a/drivers/net/can/sun4i_can.c
+++ b/drivers/net/can/sun4i_can.c
@@ -342,7 +342,7 @@ static int sun4i_can_start(struct net_device *dev)
 
 	/* enter the selected mode */
 	mod_reg_val = readl(priv->base + SUN4I_REG_MSEL_ADDR);
-	if (priv->can.ctrlmode & CAN_CTRLMODE_PRESUME_ACK)
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
 		mod_reg_val |= SUN4I_MSEL_LOOPBACK_MODE;
 	else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
 		mod_reg_val |= SUN4I_MSEL_LISTEN_ONLY_MODE;
@@ -811,7 +811,6 @@ static int sun4ican_probe(struct platform_device *pdev)
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_BERR_REPORTING |
 				       CAN_CTRLMODE_LISTENONLY |
 				       CAN_CTRLMODE_LOOPBACK |
-				       CAN_CTRLMODE_PRESUME_ACK |
 				       CAN_CTRLMODE_3_SAMPLES;
 	priv->base = addr;
 	priv->clk = clk;
-- 
2.14.2

