From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 16/17] can: m_can: fix incorrect error messages
Date: Tue, 18 Nov 2014 21:37:46 +0100
Message-ID: <1416343067-9810-17-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <b29396@freescale.com>

Fix a few error messages.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 3ad7d88720b7..2f61676b3a97 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -608,14 +608,14 @@ static int m_can_handle_state_errors(struct net_device *dev, u32 psr)
 
 	if ((psr & PSR_EP) &&
 	    (priv->can.state != CAN_STATE_ERROR_PASSIVE)) {
-		netdev_dbg(dev, "entered error warning state\n");
+		netdev_dbg(dev, "entered error passive state\n");
 		work_done += m_can_handle_state_change(dev,
 						       CAN_STATE_ERROR_PASSIVE);
 	}
 
 	if ((psr & PSR_BO) &&
 	    (priv->can.state != CAN_STATE_BUS_OFF)) {
-		netdev_dbg(dev, "entered error warning state\n");
+		netdev_dbg(dev, "entered error bus off state\n");
 		work_done += m_can_handle_state_change(dev,
 						       CAN_STATE_BUS_OFF);
 	}
@@ -627,7 +627,7 @@ static void m_can_handle_other_err(struct net_device *dev, u32 irqstatus)
 {
 	if (irqstatus & IR_WDI)
 		netdev_err(dev, "Message RAM Watchdog event due to missing READY\n");
-	if (irqstatus & IR_BEU)
+	if (irqstatus & IR_ELO)
 		netdev_err(dev, "Error Logging Overflow\n");
 	if (irqstatus & IR_BEU)
 		netdev_err(dev, "Bit Error Uncorrected\n");
-- 
2.1.3

