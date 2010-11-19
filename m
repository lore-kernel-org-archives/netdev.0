From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 10/17] can: EG20T PCH: Fix coding rule violation
Date: Fri, 19 Nov 2010 14:48:09 +0900
Message-ID: <4CE60F99.7070605__9325.71256203136$1290145758$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30676 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751547Ab0KSFs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:48:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix coding rule violation.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   48 ++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index e71817d..318eb1f 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -89,9 +89,11 @@
 
 #define PCH_CAN_CLK		50000000	/* 50MHz */
 
-/* Define the number of message object.
+/*
+ * Define the number of message object.
  * PCH CAN communications are done via Message RAM.
- * The Message RAM consists of 32 message objects. */
+ * The Message RAM consists of 32 message objects.
+ */
 #define PCH_RX_OBJ_NUM		26
 #define PCH_TX_OBJ_NUM		6
 #define PCH_RX_OBJ_START	1
@@ -126,7 +128,7 @@ enum pch_can_mode {
 	PCH_CAN_ALL,
 	PCH_CAN_NONE,
 	PCH_CAN_STOP,
-	PCH_CAN_RUN
+	PCH_CAN_RUN,
 };
 
 struct pch_can_if_regs {
@@ -290,21 +292,20 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_RXIE;
 
-	/* Reading the receive buffer data from RAM to Interface1 registers */
+	/* Reading the receive buffer data from RAM to Interface1/2 registers */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
-	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
+	/* Setting the IF1/2MASK1 register to access MsgVal and RxIE bits */
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
 		  &priv->regs->ifregs[dir].cmask);
 
 	if (set) {
-		/* Setting the MsgVal and RxIE bits */
+		/* Setting the MsgVal and RxIE/TxIE bits */
 		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
 		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
-
 	} else {
-		/* Resetting the MsgVal and RxIE bits */
+		/* Clearing the MsgVal and RxIE/TxIE bits */
 		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
 		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
 	}
@@ -312,7 +313,6 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 }
 
-
 static void pch_can_set_rx_all(struct pch_can_priv *priv, int set)
 {
 	int i;
@@ -328,7 +328,7 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, int set)
 
 	/* Traversing to obtain the object configured as transmit object. */
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
-		pch_can_set_rxtx(priv, i, set, 1);
+		pch_can_set_rxtx(priv, i, set, PCH_TX_IFREG);
 }
 
 static u32 pch_can_int_pending(struct pch_can_priv *priv)
@@ -363,8 +363,7 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 	int i;
 
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
-		iowrite32(PCH_CMASK_RX_TX_GET,
-			&priv->regs->ifregs[0].cmask);
+		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 
 		iowrite32(0x0, &priv->regs->ifregs[0].id1);
@@ -386,16 +385,14 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 				  0x1fff | PCH_MASK2_MDIR_MXTD);
 
 		/* Setting CMASK for writing */
-		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->ifregs[0].cmask);
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
+			  PCH_CMASK_CTRL, &priv->regs->ifregs[0].cmask);
 
 		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 	}
 
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
-		iowrite32(PCH_CMASK_RX_TX_GET,
-			&priv->regs->ifregs[1].cmask);
+		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
 		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 
 		/* Resetting DIR bit for reception */
@@ -410,9 +407,8 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
 
 		/* Setting CMASK for writing */
-		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->ifregs[1].cmask);
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
+			  PCH_CMASK_CTRL, &priv->regs->ifregs[1].cmask);
 
 		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 	}
@@ -471,8 +467,9 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 
 		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, mask);
 	} else if ((mask >= PCH_TX_OBJ_START) && (mask <= PCH_TX_OBJ_END)) {
-		/* Setting CMASK for clearing interrupts for
-					 frame transmission. */
+		/*
+		 * Setting CMASK for clearing interrupts for frame transmission.
+		 */
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
 			  &priv->regs->ifregs[1].cmask);
 
@@ -600,7 +597,6 @@ static irqreturn_t pch_can_interrupt(int irq, void *dev_id)
 	struct pch_can_priv *priv = netdev_priv(ndev);
 
 	pch_can_set_int_enables(priv, PCH_CAN_NONE);
-
 	napi_schedule(&priv->napi);
 
 	return IRQ_HANDLED;
@@ -1048,11 +1044,11 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
 	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
 	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
-			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
+			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie))
 		enable = 1;
-	} else {
+	else
 		enable = 0;
-	}
+
 	return enable;
 }
 
-- 
1.6.0.6

