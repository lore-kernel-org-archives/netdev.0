From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: remove obsolete assignment for CAN protocol error type
Date: Mon, 23 Nov 2015 09:46:54 +0100
Message-ID: <1448268414-18583-4-git-send-email-mkl@pengutronix.de>
References: <1448268414-18583-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1448268414-18583-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

The assignment 'cf->data[2] |= CAN_ERR_PROT_UNSPEC' used at CAN error message
creation time is obsolete as CAN_ERR_PROT_UNSPEC is zero and cf->data[2] is
initialized with zero in alloc_can_err_skb() anyway.

So we could either assign 'cf->data[2] = CAN_ERR_PROT_UNSPEC' correctly or we
can remove the obsolete OR operation entirely.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/bfin_can.c        | 2 --
 drivers/net/can/c_can/c_can.c     | 1 -
 drivers/net/can/janz-ican3.c      | 1 -
 drivers/net/can/m_can/m_can.c     | 1 -
 drivers/net/can/rcar_can.c        | 5 ++---
 drivers/net/can/sja1000/sja1000.c | 1 -
 drivers/net/can/sun4i_can.c       | 1 -
 drivers/net/can/ti_hecc.c         | 1 -
 drivers/net/can/usb/ems_usb.c     | 1 -
 drivers/net/can/usb/esd_usb2.c    | 1 -
 drivers/net/can/usb/usb_8dev.c    | 1 -
 drivers/net/can/xilinx_can.c      | 4 +---
 12 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 57dadd52b428..1deb8ff90a89 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -501,8 +501,6 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
 			cf->data[2] |= CAN_ERR_PROT_FORM;
 		else if (status & SER)
 			cf->data[2] |= CAN_ERR_PROT_STUFF;
-		else
-			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 	}
 
 	priv->can.state = state;
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 7c9892ab0a6a..f91b094288da 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -962,7 +962,6 @@ static int c_can_handle_bus_err(struct net_device *dev,
 	 * type of the last error to occur on the CAN bus
 	 */
 	cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
-	cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 
 	switch (lec_type) {
 	case LEC_STUFF_ERROR:
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index c1e85368a198..5d04f5464faf 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1096,7 +1096,6 @@ static int ican3_handle_cevtind(struct ican3_dev *mod, struct ican3_msg *msg)
 			cf->data[2] |= CAN_ERR_PROT_STUFF;
 			break;
 		default:
-			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 			cf->data[3] = ecc & ECC_SEG;
 			break;
 		}
diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 9dd3ca7a73aa..39cf911f7a1e 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -487,7 +487,6 @@ static int m_can_handle_lec_err(struct net_device *dev,
 	 * type of the last error to occur on the CAN bus
 	 */
 	cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
-	cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 
 	switch (lec_type) {
 	case LEC_STUFF_ERROR:
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 9161f045d44c..bc46be39549d 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -241,10 +241,9 @@ static void rcar_can_error(struct net_device *ndev)
 		u8 ecsr;
 
 		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
-		if (skb) {
+		if (skb)
 			cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
-			cf->data[2] = CAN_ERR_PROT_UNSPEC;
-		}
+
 		ecsr = readb(&priv->regs->ecsr);
 		if (ecsr & RCAR_CAN_ECSR_ADEF) {
 			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index f10834be48a5..8dda3b703d39 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -449,7 +449,6 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
 			cf->data[2] |= CAN_ERR_PROT_STUFF;
 			break;
 		default:
-			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 			cf->data[3] = ecc & ECC_SEG;
 			break;
 		}
diff --git a/drivers/net/can/sun4i_can.c b/drivers/net/can/sun4i_can.c
index d9a42c646783..68ef0a4cd821 100644
--- a/drivers/net/can/sun4i_can.c
+++ b/drivers/net/can/sun4i_can.c
@@ -575,7 +575,6 @@ static int sun4i_can_err(struct net_device *dev, u8 isrc, u8 status)
 				cf->data[2] |= CAN_ERR_PROT_STUFF;
 				break;
 			default:
-				cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 				cf->data[3] = (ecc & SUN4I_STA_ERR_SEG_CODE)
 					       >> 16;
 				break;
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 6eab4fe7e872..680d1ff07a55 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -722,7 +722,6 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
 	if (err_status & HECC_BUS_ERROR) {
 		++priv->can.can_stats.bus_error;
 		cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
-		cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 		if (err_status & HECC_CANES_FE) {
 			hecc_set_bit(priv, HECC_CANES, HECC_CANES_FE);
 			cf->data[2] |= CAN_ERR_PROT_FORM;
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 2d390384ef3b..fc5b75675cd8 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -377,7 +377,6 @@ static void ems_usb_rx_err(struct ems_usb *dev, struct ems_cpc_msg *msg)
 			cf->data[2] |= CAN_ERR_PROT_STUFF;
 			break;
 		default:
-			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 			cf->data[3] = ecc & SJA1000_ECC_SEG;
 			break;
 		}
diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 0e5a4493ba4f..113e64fcd73b 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -282,7 +282,6 @@ static void esd_usb2_rx_event(struct esd_usb2_net_priv *priv,
 				cf->data[2] |= CAN_ERR_PROT_STUFF;
 				break;
 			default:
-				cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 				cf->data[3] = ecc & SJA1000_ECC_SEG;
 				break;
 			}
diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index 017ae5002169..a731720f1d13 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -401,7 +401,6 @@ static void usb_8dev_rx_err_msg(struct usb_8dev_priv *priv,
 		tx_errors = 1;
 		break;
 	case USB_8DEV_STATUSMSG_CRC:
-		cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 		cf->data[3] = CAN_ERR_PROT_LOC_CRC_SEQ;
 		rx_errors = 1;
 		break;
diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 4c57ddf12684..51670b322409 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -608,10 +608,8 @@ static void xcan_err_interrupt(struct net_device *ndev, u32 isr)
 
 	/* Check for error interrupt */
 	if (isr & XCAN_IXR_ERROR_MASK) {
-		if (skb) {
+		if (skb)
 			cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
-			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
-		}
 
 		/* Check for Ack error interrupt */
 		if (err_status & XCAN_ESR_ACKER_MASK) {
-- 
2.6.2

