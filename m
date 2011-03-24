From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: RFC: [PATCH] can: c_can: disable one shot mode until driver is
	fixed
Date: Thu, 24 Mar 2011 11:28:52 +0100
Message-ID: <20110324102852.GA339@e-circ.dyndns.org>
References: <1300961549-28882-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1300961549-28882-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Thu, Mar 24, 2011 at 11:12:29AM +0100, Marc Kleine-Budde wrote:
> This patch disables the one shot mode, until the driver has been fixed and
> tested to support it.
> 
isn't this part necessary now (temporarily) to avoid dead code?

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 1405078..2c3d090 100644
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
