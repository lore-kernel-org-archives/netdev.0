From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 02/11] net/can/mscan: trivial fixes
Date: Mon, 16 Nov 2009 23:57:45 +0100
Message-ID: <1258412274-14686-3-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

- remove whitespaces
- use ! and ?: when apropriate
- make braces consistent

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mpc52xx_can.c |   16 +++++-----------
 drivers/net/can/mscan/mscan.c       |   25 +++++++++++++------------
 2 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/net/can/mscan/mpc52xx_can.c b/drivers/net/can/mscan/mpc52xx_can.c
index 4707a82..34ae2ba 100644
--- a/drivers/net/can/mscan/mpc52xx_can.c
+++ b/drivers/net/can/mscan/mpc52xx_can.c
@@ -34,7 +34,6 @@
 
 #include "mscan.h"
 
-
 #define DRV_NAME "mpc5xxx_can"
 
 static struct of_device_id mpc52xx_cdm_ids[] __devinitdata = {
@@ -71,15 +70,10 @@ static unsigned int  __devinit mpc52xx_can_xtal_freq(struct of_device *of)
 
 	if (in_8(&cdm->ipb_clk_sel) & 0x1)
 		freq *= 2;
-	val  = in_be32(&cdm->rstcfg);
-	if (val & (1 << 5))
-		freq *= 8;
-	else
-		freq *= 4;
-	if (val & (1 << 6))
-		freq /= 12;
-	else
-		freq /= 16;
+	val = in_be32(&cdm->rstcfg);
+
+	freq *= (val & (1 << 5)) ? 8 : 4;
+	freq /= (val & (1 << 6)) ? 12 : 16;
 
 	iounmap(cdm);
 
@@ -222,7 +216,7 @@ static int mpc5xxx_can_resume(struct of_device *ofdev)
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
 
 	regs->canctl0 |= MSCAN_INITRQ;
-	while ((regs->canctl1 & MSCAN_INITAK) == 0)
+	while (!(regs->canctl1 & MSCAN_INITAK))
 		udelay(10);
 
 	regs->canctl1 = saved_regs.canctl1;
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 2539ebe..6394de8 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -69,7 +69,6 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 	u8 canctl1;
 
 	if (mode != MSCAN_NORMAL_MODE) {
-
 		if (priv->tx_active) {
 			/* Abort transfers before going to sleep */#
 			out_8(&regs->cantarq, priv->tx_active);
@@ -78,7 +77,7 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 		}
 
 		canctl1 = in_8(&regs->canctl1);
-		if ((mode & MSCAN_SLPRQ) && (canctl1 & MSCAN_SLPAK) == 0) {
+		if ((mode & MSCAN_SLPRQ) && !(canctl1 & MSCAN_SLPAK)) {
 			out_8(&regs->canctl0,
 			      in_8(&regs->canctl0) | MSCAN_SLPRQ);
 			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
@@ -105,7 +104,7 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 				priv->can.state = CAN_STATE_SLEEPING;
 		}
 
-		if ((mode & MSCAN_INITRQ) && (canctl1 & MSCAN_INITAK) == 0) {
+		if ((mode & MSCAN_INITRQ) && !(canctl1 & MSCAN_INITAK)) {
 			out_8(&regs->canctl0,
 			      in_8(&regs->canctl0) | MSCAN_INITRQ);
 			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
@@ -233,7 +232,8 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!rtr) {
 		void __iomem *data = &regs->tx.dsr1_0;
-		u16 *payload = (u16 *) frame->data;
+		u16 *payload = (u16 *)frame->data;
+
 		/* It is safe to write into dsr[dlc+1] */
 		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
 			out_be16(data, *payload++);
@@ -300,7 +300,8 @@ static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
 
 	if (!(frame->can_id & CAN_RTR_FLAG)) {
 		void __iomem *data = &regs->rx.dsr1_0;
-		u16 *payload = (u16 *) frame->data;
+		u16 *payload = (u16 *)frame->data;
+
 		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
 			*payload++ = in_be16(data);
 			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
@@ -326,8 +327,9 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 		frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
 		stats->rx_over_errors++;
 		stats->rx_errors++;
-	} else
+	} else {
 		frame->data[1] = 0;
+	}
 
 	old_state = check_set_state(dev, canrflg);
 	/* State changed */
@@ -339,7 +341,6 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 			if ((priv->shadow_statflg & MSCAN_RSTAT_MSK) <
 			    (canrflg & MSCAN_RSTAT_MSK))
 				frame->data[1] |= CAN_ERR_CRTL_RX_WARNING;
-
 			if ((priv->shadow_statflg & MSCAN_TSTAT_MSK) <
 			    (canrflg & MSCAN_TSTAT_MSK))
 				frame->data[1] |= CAN_ERR_CRTL_TX_WARNING;
@@ -397,7 +398,7 @@ static int mscan_rx_poll(struct napi_struct *napi, int quota)
 
 		if (canrflg & MSCAN_RXF)
 			mscan_get_rx_frame(dev, frame);
-		 else if (canrflg & MSCAN_ERR_IF)
+		else if (canrflg & MSCAN_ERR_IF)
 			mscan_get_err_frame(dev, frame, canrflg);
 
 		stats->rx_packets++;
@@ -429,7 +430,6 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)
 	cantflg = in_8(&regs->cantflg) & cantier;
 
 	if (cantier && cantflg) {
-
 		struct list_head *tmp, *pos;
 
 		list_for_each_safe(pos, tmp, &priv->tx_head) {
@@ -452,8 +452,9 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)
 			clear_bit(F_TX_WAIT_ALL, &priv->flags);
 			clear_bit(F_TX_PROGRESS, &priv->flags);
 			priv->cur_pri = 0;
-		} else
+		} else {
 			dev->trans_start = jiffies;
+		}
 
 		if (!test_bit(F_TX_WAIT_ALL, &priv->flags))
 			netif_wake_queue(dev);
@@ -470,15 +471,15 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)
 			out_8(&regs->canrier, 0);
 			napi_schedule(&priv->napi);
 			ret = IRQ_HANDLED;
-		} else
+		} else {
 			clear_bit(F_RX_PROGRESS, &priv->flags);
+		}
 	}
 	return ret;
 }
 
 static int mscan_do_set_mode(struct net_device *dev, enum can_mode mode)
 {
-
 	struct mscan_priv *priv = netdev_priv(dev);
 	int ret = 0;
 
-- 
1.6.3.3
