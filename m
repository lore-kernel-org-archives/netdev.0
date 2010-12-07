From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 06/20] CAN : Rename function/macro name
Date: Tue, 07 Dec 2010 20:05:59 +0900
Message-ID: <4CFE1517.8020906@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

For easy to read/understand, Rename function/macro name.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |  176 ++++++++++++++++++++-------------------------
 1 files changed, 77 insertions(+), 99 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5fc99cb..dd9ce16 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -32,8 +32,6 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
-#define PCH_ENABLE		1 /* The enable flag */
-#define PCH_DISABLE		0 /* The disable flag */
 #define PCH_CTRL_INIT		BIT(0) /* The INIT bit of CANCONT register. */
 #define PCH_CTRL_IE		BIT(1) /* The IE bit of CAN control register */
 #define PCH_CTRL_IE_SIE_EIE	(BIT(3) | BIT(2) | BIT(1))
@@ -78,11 +76,12 @@
 #define PCH_BUS_OFF		BIT(7)
 
 /* bit position of certain controller bits. */
-#define PCH_BIT_BRP		0
-#define PCH_BIT_SJW		6
-#define PCH_BIT_TSEG1		8
-#define PCH_BIT_TSEG2		12
-#define PCH_BIT_BRPE_BRPE	6
+#define PCH_BIT_BRP_SHIFT	0
+#define PCH_BIT_SJW_SHIFT	6
+#define PCH_BIT_TSEG1_SHIFT	8
+#define PCH_BIT_TSEG2_SHIFT	12
+#define PCH_BIT_BRPE_BRPE_SHIFT	6
+
 #define PCH_MSK_BITT_BRP	0x3f
 #define PCH_MSK_BRPE_BRPE	0x3c0
 #define PCH_MSK_CTRL_IE_SIE_EIE	0x07
@@ -170,19 +169,16 @@ struct pch_can_regs {
 
 struct pch_can_priv {
 	struct can_priv can;
-	unsigned int can_num;
 	struct pci_dev *dev;
-	int tx_enable[PCH_TX_OBJ_END];
-	int rx_enable[PCH_TX_OBJ_END];
-	int rx_link[PCH_TX_OBJ_END];
-	unsigned int int_enables;
-	unsigned int int_stat;
+	u32 tx_enable[PCH_TX_OBJ_END];
+	u32 rx_enable[PCH_TX_OBJ_END];
+	u32 rx_link[PCH_TX_OBJ_END];
+	u32 int_enables;
 	struct net_device *ndev;
-	unsigned int msg_obj[PCH_TX_OBJ_END];
 	struct pch_can_regs __iomem *regs;
 	struct napi_struct napi;
-	unsigned int tx_obj;	/* Point next Tx Obj index */
-	unsigned int use_msi;
+	int tx_obj;	/* Point next Tx Obj index */
+	int use_msi;
 };
 
 static struct can_bittiming_const pch_can_bittiming_const = {
@@ -245,14 +241,27 @@ static void pch_can_set_optmode(struct pch_can_priv *priv)
 	iowrite32(reg_val, &priv->regs->opt);
 }
 
+static void pch_can_rw_msg_obj(void __iomem *creq_addr, u32 num)
+{
+	int counter = PCH_COUNTER_LIMIT;
+	u32 ifx_creq;
+
+	iowrite32(num, creq_addr);
+	while (counter) {
+		ifx_creq = ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
+		if (!ifx_creq)
+			break;
+		counter--;
+		udelay(1);
+	}
+	if (!counter)
+		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
+}
+
 static void pch_can_set_int_enables(struct pch_can_priv *priv,
 				    enum pch_can_mode interrupt_no)
 {
 	switch (interrupt_no) {
-	case PCH_CAN_ENABLE:
-		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE);
-		break;
-
 	case PCH_CAN_DISABLE:
 		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE);
 		break;
@@ -271,25 +280,8 @@ static void pch_can_set_int_enables(struct pch_can_priv *priv,
 	}
 }
 
-static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
-{
-	u32 counter = PCH_COUNTER_LIMIT;
-	u32 ifx_creq;
-
-	iowrite32(num, creq_addr);
-	while (counter) {
-		ifx_creq = ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
-		if (!ifx_creq)
-			break;
-		counter--;
-		udelay(1);
-	}
-	if (!counter)
-		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
-}
-
 static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
-			     u32 set, enum pch_ifreg dir)
+			     int set, enum pch_ifreg dir)
 {
 	u32 ie;
 
@@ -300,27 +292,27 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 
 	/* Reading the receive buffer data from RAM to Interface1 registers */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
 	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
 		  &priv->regs->ifregs[dir].cmask);
 
-	if (set == PCH_ENABLE) {
+	if (set) {
 		/* Setting the MsgVal and RxIE bits */
 		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
 		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
 
-	} else if (set == PCH_DISABLE) {
+	} else {
 		/* Resetting the MsgVal and RxIE bits */
 		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
 		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
 	}
 
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 }
 
-static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
+static void pch_can_set_rx_all(struct pch_can_priv *priv, int set)
 {
 	int i;
 
@@ -329,7 +321,7 @@ static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
 		pch_can_set_rxtx(priv, i, set, PCH_RX_IFREG);
 }
 
-static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
+static void pch_can_set_tx_all(struct pch_can_priv *priv, int set)
 {
 	int i;
 
@@ -338,16 +330,16 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
 		pch_can_set_rxtx(priv, i, set, PCH_TX_IFREG);
 }
 
-static int pch_can_int_pending(struct pch_can_priv *priv)
+static u32 pch_can_int_pending(struct pch_can_priv *priv)
 {
 	return ioread32(&priv->regs->intr) & 0xffff;
 }
 
-static void pch_can_clear_buffers(struct pch_can_priv *priv)
+static void pch_can_clear_if_buffers(struct pch_can_priv *priv)
 {
-	int i;
+	int i; /* Msg Obj ID (1~32) */
 
-	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
+	for (i = PCH_RX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
@@ -361,24 +353,7 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
-	}
-
-	for (i = PCH_TX_OBJ_START;  i <= PCH_TX_OBJ_END; i++) {
-		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
-		iowrite32(0xffff, &priv->regs->ifregs[1].mask1);
-		iowrite32(0xffff, &priv->regs->ifregs[1].mask2);
-		iowrite32(0x0, &priv->regs->ifregs[1].id1);
-		iowrite32(0x0, &priv->regs->ifregs[1].id2);
-		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[0]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[1]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[2]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[3]);
-		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->ifregs[1].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 	}
 }
 
@@ -389,7 +364,7 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
 			&priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 
 		iowrite32(0x0, &priv->regs->ifregs[0].id1);
 		iowrite32(0x0, &priv->regs->ifregs[0].id2);
@@ -403,6 +378,9 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 		/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
 		if (i == PCH_RX_OBJ_END)
 			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
+					PCH_IF_MCONT_EOB);
+		else
+			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_EOB);
 
 		iowrite32(0, &priv->regs->ifregs[0].mask1);
@@ -414,13 +392,13 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 	}
 
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
 			&priv->regs->ifregs[1].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 
 		/* Resetting DIR bit for reception */
 		iowrite32(0x0, &priv->regs->ifregs[1].id1);
@@ -441,7 +419,7 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[1].cmask);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 	}
 }
 
@@ -451,7 +429,7 @@ static void pch_can_init(struct pch_can_priv *priv)
 	pch_can_set_run_mode(priv, PCH_CAN_STOP);
 
 	/* Clearing all the message object buffers. */
-	pch_can_clear_buffers(priv);
+	pch_can_clear_if_buffers(priv);
 
 	/* Configuring the respective message object as either rx/tx object. */
 	pch_can_config_rx_tx_buffers(priv);
@@ -496,7 +474,7 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, mask);
 	} else if ((mask >= PCH_TX_OBJ_START) && (mask <= PCH_TX_OBJ_END)) {
 		/* Setting CMASK for clearing interrupts for
 					 frame transmission. */
@@ -512,7 +490,7 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 		pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
 				  PCH_IF_MCONT_TXRQXT);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, mask);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, mask);
 	}
 }
 
@@ -637,7 +615,7 @@ static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
 		/* Clearing NewDat & IntPnd */
 		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_INTPND);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
 	} else if (obj_id > PCH_FIFO_THRESH) {
 		pch_can_int_clr(priv, obj_id);
 	} else if (obj_id == PCH_FIFO_THRESH) {
@@ -659,7 +637,7 @@ static void pch_can_rx_msg_lost(struct net_device *ndev, int obj_id)
 			  PCH_IF_MCONT_MSGLOST);
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
 		  &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
 
 	skb = alloc_can_err_skb(ndev, &cf);
 	if (!skb)
@@ -689,7 +667,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 	do {
 		/* Reading the messsage object from the Message RAM */
 		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_num);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_num);
 
 		/* Reading the MCONT register. */
 		reg = ioread32(&priv->regs->ifregs[0].mcont);
@@ -758,7 +736,7 @@ static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
 	iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
 		  &priv->regs->ifregs[1].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, int_stat);
 	dlc = get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
 			  PCH_IF_MCONT_DLC);
 	stats->tx_bytes += dlc;
@@ -767,7 +745,7 @@ static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 		netif_wake_queue(ndev);
 }
 
-static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+static int pch_can_poll(struct napi_struct *napi, int quota)
 {
 	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
@@ -832,10 +810,10 @@ static int pch_set_bittiming(struct net_device *ndev)
 
 	brp = (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
 	canbit = brp & PCH_MSK_BITT_BRP;
-	canbit |= (bt->sjw - 1) << PCH_BIT_SJW;
-	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1;
-	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2;
-	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE;
+	canbit |= (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
+	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIFT;
+	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
+	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
 	iowrite32(canbit, &priv->regs->bitt);
 	iowrite32(bepe, &priv->regs->brpe);
 	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
@@ -947,7 +925,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
-	int tx_buffer_avail = 0;
+	int tx_obj_no;
 	int i;
 
 	if (can_dropped_invalid_skb(ndev, skb))
@@ -957,16 +935,16 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
 			netif_stop_queue(ndev);
 
-		tx_buffer_avail = priv->tx_obj;
+		tx_obj_no = priv->tx_obj;
 		priv->tx_obj = PCH_TX_OBJ_START;
 	} else {
-		tx_buffer_avail = priv->tx_obj;
+		tx_obj_no = priv->tx_obj;
 		priv->tx_obj++;
 	}
 
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	/* Setting the CMASK register. */
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
@@ -995,7 +973,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 			  &priv->regs->ifregs[1].data[i / 2]);
 	}
 
-	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_END - 1);
+	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
 
 	/* Updating the size of the data. */
 	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
@@ -1010,7 +988,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
 			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
 
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	return NETDEV_TX_OK;
 }
@@ -1064,7 +1042,7 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
 		ie = PCH_IF_MCONT_TXIE;
 
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
 	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
 			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
@@ -1076,37 +1054,37 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
 }
 
 static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
-				       u32 buffer_num, u32 set)
+				       u32 buffer_num, int set)
 {
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
 		  &priv->regs->ifregs[0].cmask);
-	if (set == PCH_ENABLE)
+	if (set)
 		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_EOB);
 	else
 		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
 
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
 }
 
 static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
 				       u32 buffer_num, u32 *link)
 {
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
 
 	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
-		*link = PCH_DISABLE;
+		*link = 0;
 	else
-		*link = PCH_ENABLE;
+		*link = 1;
 }
 
 static int pch_can_get_buffer_status(struct pch_can_priv *priv)
 {
 	return (ioread32(&priv->regs->treq1) & 0xffff) |
-	       ((ioread32(&priv->regs->treq2) & 0xffff) << 16);
+	       (ioread32(&priv->regs->treq2) << 16);
 }
 
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -1114,7 +1092,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	int i;			/* Counter variable. */
 	int retval;		/* Return value. */
 	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
-	u32 counter = 0xFFFFFF;
+	int counter = PCH_COUNTER_LIMIT;
 
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct pch_can_priv *priv = netdev_priv(dev);
@@ -1291,7 +1269,7 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	ndev->netdev_ops = &pch_can_netdev_ops;
 	priv->can.clock.freq = PCH_CAN_CLK; /* Hz */
 
-	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_END);
+	netif_napi_add(ndev, &priv->napi, pch_can_poll, PCH_RX_OBJ_END);
 
 	rc = register_candev(ndev);
 	if (rc) {
-- 
1.6.0.6
