From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 8/17] can: EG20T PCH: Change Copyright and module
 description
Date: Fri, 19 Nov 2010 14:47:26 +0900
Message-ID: <4CE60F6E.6090205__3958.84643444351$1290145688$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30598 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751670Ab0KSFrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:47:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, Copyright and module description are not formal.


Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   41 +++++++++++++++++++----------------------
 1 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8985e16..3a39786 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1999 - 2010 Intel Corporation.
- * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -169,19 +169,16 @@ struct pch_can_regs {
 
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
@@ -244,9 +241,9 @@ static void pch_can_set_optmode(struct pch_can_priv *priv)
 	iowrite32(reg_val, &priv->regs->opt);
 }
 
-static void pch_can_rw_msg_obj(u32 __iomem *creq_addr, u32 num)
+static void pch_can_rw_msg_obj(void __iomem *creq_addr, u32 num)
 {
-	u32 counter = PCH_COUNTER_LIMIT;
+	int counter = PCH_COUNTER_LIMIT;
 	u32 ifx_creq;
 
 	iowrite32(num, creq_addr);
@@ -334,7 +331,7 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, int set)
 		pch_can_set_rxtx(priv, i, set, 1);
 }
 
-static int pch_can_int_pending(struct pch_can_priv *priv)
+static u32 pch_can_int_pending(struct pch_can_priv *priv)
 {
 	return ioread32(&priv->regs->intr) & 0xffff;
 }
@@ -492,10 +489,10 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 	}
 }
 
-static int pch_can_get_buffer_status(struct pch_can_priv *priv)
+static u32 pch_can_get_buffer_status(struct pch_can_priv *priv)
 {
 	return (ioread32(&priv->regs->treq1) & 0xffff) |
-	       ((ioread32(&priv->regs->treq2) & 0xffff) << 16);
+	       (ioread32(&priv->regs->treq2) << 16);
 }
 
 static void pch_can_reset(struct pch_can_priv *priv)
@@ -759,7 +756,7 @@ static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 		netif_wake_queue(ndev);
 }
 
-static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+static int pch_can_poll(struct napi_struct *napi, int quota)
 {
 	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
@@ -1032,10 +1029,10 @@ static void pch_can_set_int_custom(struct pch_can_priv *priv)
 }
 
 /* This function retrieves interrupt enabled for the CAN device. */
-static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
+static u32 pch_can_get_int_enables(struct pch_can_priv *priv)
 {
 	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
-	*enables = ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1);
+	return (ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1;
 }
 
 static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
@@ -1094,7 +1091,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	int i;			/* Counter variable. */
 	int retval;		/* Return value. */
 	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
-	u32 counter = 0xFFFFFF;
+	int counter = PCH_COUNTER_LIMIT;
 
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct pch_can_priv *priv = netdev_priv(dev);
@@ -1117,7 +1114,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 		dev_err(&pdev->dev, "%s -> Transmission time out.\n", __func__);
 
 	/* Save interrupt configuration and then disable them */
-	pch_can_get_int_enables(priv, &(priv->int_enables));
+	priv->int_enables = pch_can_get_int_enables(priv);
 	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
 
 	/* Save Tx buffer enable state */
@@ -1272,7 +1269,7 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	ndev->netdev_ops = &pch_can_netdev_ops;
 	priv->can.clock.freq = PCH_CAN_CLK; /* Hz */
 
-	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_END);
+	netif_napi_add(ndev, &priv->napi, pch_can_poll, PCH_RX_OBJ_END);
 
 	rc = register_candev(ndev);
 	if (rc) {
@@ -1315,6 +1312,6 @@ static void __exit pch_can_pci_exit(void)
 }
 module_exit(pch_can_pci_exit);
 
-MODULE_DESCRIPTION("Controller Area Network Driver");
+MODULE_DESCRIPTION("Intel EG20T PCH CAN(Controller Area Network) Driver");
 MODULE_LICENSE("GPL v2");
 MODULE_VERSION("0.94");
-- 
1.6.0.6

