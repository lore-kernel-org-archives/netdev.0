From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/11] can: flexcan: rename legacy error state quirk
Date: Thu, 19 Oct 2017 13:19:36 +0200
Message-ID: <20171019111945.13580-3-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>,
        Zhu Yi <yi.zhu5@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "ZHU Yi (ST-FIR/ENG1-Zhu)" <Yi.Zhu5@cn.bosch.com>

Rename FLEXCAN_QUIRK_BROKEN_ERR_STATE to FLEXCAN_QUIRK_BROKEN_WERR_STATE
for better description of the missing [TR]WRN_INT quirk.

Signed-off-by: Zhu Yi <yi.zhu5@cn.bosch.com>
Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v4.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index df4bfb83024c..e163c55e737b 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -193,7 +193,7 @@
  *
  * Some SOCs do not have the RX_WARN & TX_WARN interrupt line connected.
  */
-#define FLEXCAN_QUIRK_BROKEN_ERR_STATE	BIT(1) /* [TR]WRN_INT not connected */
+#define FLEXCAN_QUIRK_BROKEN_WERR_STATE	BIT(1) /* [TR]WRN_INT not connected */
 #define FLEXCAN_QUIRK_DISABLE_RXFG	BIT(2) /* Disable RX FIFO Global mask */
 #define FLEXCAN_QUIRK_ENABLE_EACEN_RRS	BIT(3) /* Enable EACEN and RRS bit in ctrl2 */
 #define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disable Memory error detection */
@@ -281,7 +281,7 @@ struct flexcan_priv {
 };
 
 static const struct flexcan_devtype_data fsl_p1010_devtype_data = {
-	.quirks = FLEXCAN_QUIRK_BROKEN_ERR_STATE,
+	.quirks = FLEXCAN_QUIRK_BROKEN_WERR_STATE,
 };
 
 static const struct flexcan_devtype_data fsl_imx28_devtype_data;
@@ -767,7 +767,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 
 	/* state change interrupt or broken error state quirk fix is enabled */
 	if ((reg_esr & FLEXCAN_ESR_ERR_STATE) ||
-	    (priv->devtype_data->quirks & FLEXCAN_QUIRK_BROKEN_ERR_STATE))
+	    (priv->devtype_data->quirks & FLEXCAN_QUIRK_BROKEN_WERR_STATE))
 		flexcan_irq_state(dev, reg_esr);
 
 	/* bus error IRQ - handle if bus error reporting is activated */
@@ -888,7 +888,7 @@ static int flexcan_chip_start(struct net_device *dev)
 	 * on most Flexcan cores, too. Otherwise we don't get
 	 * any error warning or passive interrupts.
 	 */
-	if (priv->devtype_data->quirks & FLEXCAN_QUIRK_BROKEN_ERR_STATE ||
+	if (priv->devtype_data->quirks & FLEXCAN_QUIRK_BROKEN_WERR_STATE ||
 	    priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
 		reg_ctrl |= FLEXCAN_CTRL_ERR_MSK;
 	else
-- 
2.14.2

