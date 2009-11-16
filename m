From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 04/11] net/can/mscan: use {clr|set}bits8 macros
Date: Mon, 16 Nov 2009 23:57:47 +0100
Message-ID: <1258412274-14686-5-git-send-email-w.sang@pengutronix.de>
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

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 839b471..ca8b556 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -78,8 +78,7 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 
 		canctl1 = in_8(&regs->canctl1);
 		if ((mode & MSCAN_SLPRQ) && !(canctl1 & MSCAN_SLPAK)) {
-			out_8(&regs->canctl0,
-			      in_8(&regs->canctl0) | MSCAN_SLPRQ);
+			setbits8(&regs->canctl0, MSCAN_SLPRQ);
 			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
 				if (in_8(&regs->canctl1) & MSCAN_SLPAK)
 					break;
@@ -105,8 +104,7 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 		}
 
 		if ((mode & MSCAN_INITRQ) && !(canctl1 & MSCAN_INITAK)) {
-			out_8(&regs->canctl0,
-			      in_8(&regs->canctl0) | MSCAN_INITRQ);
+			setbits8(&regs->canctl0, MSCAN_INITRQ);
 			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
 				if (in_8(&regs->canctl1) & MSCAN_INITAK)
 					break;
@@ -118,14 +116,12 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 			priv->can.state = CAN_STATE_STOPPED;
 
 		if (mode & MSCAN_CSWAI)
-			out_8(&regs->canctl0,
-			      in_8(&regs->canctl0) | MSCAN_CSWAI);
+			setbits8(&regs->canctl0, MSCAN_CSWAI);
 
 	} else {
 		canctl1 = in_8(&regs->canctl1);
 		if (canctl1 & (MSCAN_SLPAK | MSCAN_INITAK)) {
-			out_8(&regs->canctl0, in_8(&regs->canctl0) &
-			      ~(MSCAN_SLPRQ | MSCAN_INITRQ));
+			clrbits8(&regs->canctl0, MSCAN_SLPRQ | MSCAN_INITRQ);
 			for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
 				canctl1 = in_8(&regs->canctl1);
 				if (!(canctl1 & (MSCAN_INITAK | MSCAN_SLPAK)))
@@ -359,8 +355,7 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 			 */
 			out_8(&regs->cantier, 0);
 			out_8(&regs->canrier, 0);
-			out_8(&regs->canctl0, in_8(&regs->canctl0) |
-				MSCAN_SLPRQ | MSCAN_INITRQ);
+			setbits8(&regs->canctl0, MSCAN_SLPRQ | MSCAN_INITRQ);
 			can_bus_off(dev);
 			break;
 		default:
@@ -548,7 +543,7 @@ static int mscan_open(struct net_device *dev)
 
 	priv->open_time = jiffies;
 
-	out_8(&regs->canctl1, in_8(&regs->canctl1) & ~MSCAN_LISTEN);
+	clrbits8(&regs->canctl1, MSCAN_LISTEN);
 
 	ret = mscan_start(dev);
 	if (ret)
@@ -623,7 +618,7 @@ void unregister_mscandev(struct net_device *dev)
 	struct mscan_priv *priv = netdev_priv(dev);
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
 	mscan_set_mode(dev, MSCAN_INIT_MODE);
-	out_8(&regs->canctl1, in_8(&regs->canctl1) & ~MSCAN_CANE);
+	clrbits8(&regs->canctl1, MSCAN_CANE);
 	unregister_candev(dev);
 }
 EXPORT_SYMBOL_GPL(unregister_mscandev);
-- 
1.6.3.3
