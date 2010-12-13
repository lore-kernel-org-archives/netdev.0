From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v9 15/20] pch_can: Comment optimization
Date: Mon, 13 Dec 2010 15:24:21 +0900
Message-ID: <1292221467-8039-15-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-10-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-11-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-12-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-13-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-14-git-send-email-tomoya-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: wg@grandegger.com, w.sang@pengutronix.de, chripell@fsfe.org,
	21cnbao@gmail.com, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kerne
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292221467-8039-14-git-send-email-tomoya-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comment optimization

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c500b6d..a1fd3be 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -292,7 +292,7 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_RXIE;
 
-	/* Reading the receive buffer data from RAM to Interface1/2 registers */
+	/* Reading the Msg buffer from Message RAM to IF1/2 registers. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
@@ -854,7 +854,7 @@ static int pch_can_open(struct net_device *ndev)
 		priv->use_msi = 1;
 	}
 
-	/* Regsitering the interrupt. */
+	/* Regstering the interrupt. */
 	retval = request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED,
 			     ndev->name, ndev);
 	if (retval) {
@@ -954,7 +954,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
 
-	/* Updating the size of the data. */
+	/* Set the size of the data. Update if2_mcont */
 	iowrite32(cf->can_dlc | PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT |
 		  PCH_IF_MCONT_TXIE, &priv->regs->ifregs[1].mcont);
 
@@ -1061,8 +1061,8 @@ static int pch_can_get_buffer_status(struct pch_can_priv *priv)
 
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	int i;			/* Counter variable. */
-	int retval;		/* Return value. */
+	int i;
+	int retval;
 	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
 	int counter = PCH_COUNTER_LIMIT;
 
@@ -1119,8 +1119,8 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 
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
