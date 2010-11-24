From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 14/17 v3] can: EG20T PCH: Comment optimization
Date: Wed, 24 Nov 2010 21:23:31 +0900
Message-ID: <4CED03C3.7010908__30809.3678126626$1290601479$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:3014 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754367Ab0KXMX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 07:23:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comment optimization

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 610cf3b..df14569 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -292,7 +292,7 @@ static void pch_can_set_rxtx(struct pch_can_priv
*priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_RXIE;

-	/* Reading the receive buffer data from RAM to Interface1/2 registers */
+	/* Reading the Msg buffer from Message RAM to IF1/2 registers. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);

@@ -868,7 +868,7 @@ static int pch_can_open(struct net_device *ndev)
 		priv->use_msi = 1;
 	}

-	/* Regsitering the interrupt. */
+	/* Regstering the interrupt. */
 	retval = request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED,
 			     ndev->name, ndev);
 	if (retval) {
@@ -972,7 +972,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)

 	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);

-	/* Updating the size of the data. */
+	/* Set the size of the data. Update if2_mcont */
 	iowrite32(cf->can_dlc | PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT |
 		  PCH_IF_MCONT_TXIE, &priv->regs->ifregs[1].mcont);

@@ -1072,8 +1072,8 @@ static u32 pch_can_get_rx_buffer_link(struct
pch_can_priv *priv, u32 buffer_num)

 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	int i;			/* Counter variable. */
-	int retval;		/* Return value. */
+	int i;
+	int retval;
 	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
 	int counter = PCH_COUNTER_LIMIT;

@@ -1130,8 +1130,8 @@ static int pch_can_suspend(struct pci_dev *pdev,
pm_message_t state)

 static int pch_can_resume(struct pci_dev *pdev)
 {
-	int i;			/* Counter variable. */
-	int retval;		/* Return variable. */
+	int i;
+	int retval;
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct pch_can_priv *priv = netdev_priv(dev);

-- 
1.6.0.6

