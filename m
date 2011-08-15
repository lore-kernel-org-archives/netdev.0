From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] net/can/mscan: add __iomem annotations
Date: Mon, 15 Aug 2011 12:57:14 +0200
Message-ID: <1313405834-10340-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

This patch fixes the following sparse warning by adding the missing
__iomem annotation.

drivers/net/can/mscan/mscan.c:73:32: warning: incorrect type in argument 1 (different address spaces)
drivers/net/can/mscan/mscan.c:73:32:    expected unsigned char volatile [noderef] [usertype] <asn:2>*addr
drivers/net/can/mscan/mscan.c:73:32:    got unsigned char *<noident>

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---

This patch applies so current net-next-2.6/master and can be pulled:

The following changes since commit b333293058aa2d401737c7246bce58f8ba00906d:

  qeth: add support for af_iucv HiperSockets transport (2011-08-13 01:10:17 -0700)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git can/mscan

Marc Kleine-Budde (1):
      net/can/mscan: add __iomem annotations

 drivers/net/can/mscan/mscan.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 92feac6..ac42f5d 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -62,7 +62,7 @@ static enum can_state state_map[] = {
 static int mscan_set_mode(struct net_device *dev, u8 mode)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	int ret = 0;
 	int i;
 	u8 canctl1;
@@ -138,7 +138,7 @@ static int mscan_set_mode(struct net_device *dev, u8 mode)
 static int mscan_start(struct net_device *dev)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	u8 canrflg;
 	int err;
 
@@ -178,7 +178,7 @@ static int mscan_restart(struct net_device *dev)
 	struct mscan_priv *priv = netdev_priv(dev);
 
 	if (priv->type == MSCAN_TYPE_MPC5121) {
-		struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+		struct mscan_regs __iomem *regs = priv->reg_base;
 
 		priv->can.state = CAN_STATE_ERROR_ACTIVE;
 		WARN(!(in_8(&regs->canmisc) & MSCAN_BOHOLD),
@@ -199,7 +199,7 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct can_frame *frame = (struct can_frame *)skb->data;
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	int i, rtr, buf_id;
 	u32 can_id;
 
@@ -305,7 +305,7 @@ static enum can_state check_set_state(struct net_device *dev, u8 canrflg)
 static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	u32 can_id;
 	int i;
 
@@ -343,7 +343,7 @@ static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 				u8 canrflg)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	struct net_device_stats *stats = &dev->stats;
 	enum can_state old_state;
 
@@ -406,7 +406,7 @@ static int mscan_rx_poll(struct napi_struct *napi, int quota)
 {
 	struct mscan_priv *priv = container_of(napi, struct mscan_priv, napi);
 	struct net_device *dev = napi->dev;
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	struct net_device_stats *stats = &dev->stats;
 	int npackets = 0;
 	int ret = 1;
@@ -453,7 +453,7 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	struct net_device_stats *stats = &dev->stats;
 	u8 cantier, cantflg, canrflg;
 	irqreturn_t ret = IRQ_NONE;
@@ -537,7 +537,7 @@ static int mscan_do_set_mode(struct net_device *dev, enum can_mode mode)
 static int mscan_do_set_bittiming(struct net_device *dev)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	struct can_bittiming *bt = &priv->can.bittiming;
 	u8 btr0, btr1;
 
@@ -559,7 +559,7 @@ static int mscan_open(struct net_device *dev)
 {
 	int ret;
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 
 	/* common open */
 	ret = open_candev(dev);
@@ -598,7 +598,7 @@ exit_napi_disable:
 static int mscan_close(struct net_device *dev)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
@@ -622,7 +622,7 @@ static const struct net_device_ops mscan_netdev_ops = {
 int register_mscandev(struct net_device *dev, int mscan_clksrc)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	u8 ctl1;
 
 	ctl1 = in_8(&regs->canctl1);
@@ -659,7 +659,7 @@ int register_mscandev(struct net_device *dev, int mscan_clksrc)
 void unregister_mscandev(struct net_device *dev)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
-	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
+	struct mscan_regs __iomem *regs = priv->reg_base;
 	mscan_set_mode(dev, MSCAN_INIT_MODE);
 	clrbits8(&regs->canctl1, MSCAN_CANE);
 	unregister_candev(dev);
-- 
1.7.5.4
