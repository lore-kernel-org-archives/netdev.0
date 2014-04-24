From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 16/26] can: c_can: Cleanup c_can_inval_msg_object()
Date: Fri, 25 Apr 2014 00:00:19 +0200
Message-ID: <1398376829-6771-17-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index e4eaa84..bf3aed4 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -129,6 +129,9 @@
 /* Receive setup of message objects */
 #define IF_COMM_RCV_SETUP	(IF_COMM_MASK | IF_COMM_ARB | IF_COMM_CONTROL)
 
+/* Invalidation of message objects */
+#define IF_COMM_INVAL		(IF_COMM_ARB | IF_COMM_CONTROL)
+
 /* IFx arbitration */
 #define IF_ARB_MSGVAL		BIT(15)
 #define IF_ARB_MSGXTD		BIT(14)
@@ -447,7 +450,7 @@ static void c_can_setup_receive_object(struct net_device *dev, int iface,
 	c_can_object_put(dev, iface, obj, IF_COMM_RCV_SETUP);
 }
 
-static void c_can_inval_msg_object(struct net_device *dev, int iface, int objno)
+static void c_can_inval_msg_object(struct net_device *dev, int iface, int obj)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
@@ -455,10 +458,7 @@ static void c_can_inval_msg_object(struct net_device *dev, int iface, int objno)
 	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), 0);
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), 0);
 
-	c_can_object_put(dev, iface, objno, IF_COMM_ARB | IF_COMM_CONTROL);
-
-	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
-			c_can_read_reg32(priv, C_CAN_MSGVAL1_REG));
+	c_can_object_put(dev, iface, obj, IF_COMM_INVAL);
 }
 
 static inline int c_can_is_next_tx_obj_busy(struct c_can_priv *priv, int objno)
-- 
1.9.0.279.gdc9e3eb

