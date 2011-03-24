From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 1/2 V3] can: c_can: disable one shot mode until driver is fixed
Date: Thu, 24 Mar 2011 13:34:32 +0100
Message-ID: <1300970073-25522-2-git-send-email-mkl@pengutronix.de>
References: <1300970073-25522-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1300970073-25522-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch disables the one shot mode, until the driver has been fixed and
tested to support it.

> I'm quite sure I've seen a situation where msg_obj 17 "seemed" to be
> pending, while msg_obj 18 and 19 already have been transmitted. But
> in that case, I enabled ONESHOT for the can interface, which enables
> the DA mode (automatic retransmission is disabled).

Reported-by: Jan Altenberg <jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Cc: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
---

Changes since v2: add Wolfgang's Ack.

 drivers/net/can/c_can/c_can.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 110eda0..d0bffb0 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -588,14 +588,9 @@ static void c_can_chip_config(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
-		/* disable automatic retransmission */
-		priv->write_reg(priv, &priv->regs->control,
-				CONTROL_DISABLE_AR);
-	else
-		/* enable automatic retransmission */
-		priv->write_reg(priv, &priv->regs->control,
-				CONTROL_ENABLE_AR);
+	/* enable automatic retransmission */
+	priv->write_reg(priv, &priv->regs->control,
+			CONTROL_ENABLE_AR);
 
 	if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
 					CAN_CTRLMODE_LOOPBACK)) {
@@ -1112,8 +1107,7 @@ struct net_device *alloc_c_can_dev(void)
 	priv->can.bittiming_const = &c_can_bittiming_const;
 	priv->can.do_set_mode = c_can_set_mode;
 	priv->can.do_get_berr_counter = c_can_get_berr_counter;
-	priv->can.ctrlmode_supported = CAN_CTRLMODE_ONE_SHOT |
-					CAN_CTRLMODE_LOOPBACK |
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_LOOPBACK |
 					CAN_CTRLMODE_LISTENONLY |
 					CAN_CTRLMODE_BERR_REPORTING;
 
-- 
1.7.2.3
