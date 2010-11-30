From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v6 12/20] can: EG20T PCH: Delete unnecessary/redundant
 code
Date: Tue, 30 Nov 2010 13:31:58 +0900
Message-ID: <4CF47E3E.3000601__6565.88416682116$1291091578$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:21575 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753034Ab0K3Eca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:32:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete unnecessary/redundant code.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8e607ad..9f5241b 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -447,11 +447,6 @@ static void pch_can_release(struct pch_can_priv *priv)
 /* This function clears interrupt(s) from the CAN device. */
 static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 {
-	if (mask == PCH_STATUS_INT) {
-		ioread32(&priv->regs->stat);
-		return;
-	}
-
 	/* Clear interrupt for transmit object */
 	if ((mask >= PCH_RX_OBJ_START) && (mask <= PCH_RX_OBJ_END)) {
 		/* Setting CMASK for clearing the reception interrupts. */
@@ -518,8 +513,6 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		state = CAN_STATE_BUS_OFF;
 		cf->can_id |= CAN_ERR_BUSOFF;
 		can_bus_off(ndev);
-		pch_can_set_run_mode(priv, PCH_CAN_RUN);
-		dev_err(&ndev->dev, "%s -> Bus Off occurres.\n", __func__);
 	}
 
 	errc = ioread32(&priv->regs->errc);
@@ -753,7 +746,7 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 	if (!int_stat)
 		goto end;
 
-	if ((int_stat == PCH_STATUS_INT) && (quota > 0)) {
+	if (int_stat == PCH_STATUS_INT) {
 		reg_stat = ioread32(&priv->regs->stat);
 		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
 			if (reg_stat & PCH_BUS_OFF ||
@@ -939,10 +932,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 		priv->tx_obj++;
 	}
 
-	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
-
 	/* Setting the CMASK register. */
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
 
@@ -1072,7 +1061,6 @@ static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
 	return link;
 }
 
-
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	int i;			/* Counter variable. */
-- 
1.6.0.6
