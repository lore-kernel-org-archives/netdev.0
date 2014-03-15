From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/3] sh_eth: convert dev_*() to netdev_*() calls
Date: Sat, 15 Mar 2014 03:29:14 +0300
Message-ID: <201403150329.14838.sergei.shtylyov@cogentembedded.com>
References: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert dev_*(&ndev->dev, ...) to netdev_*(ndev, ...) calls since they are a bit
shorter and at the same time give more information on a device.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   47 +++++++++++++++++-----------------
 1 file changed, 24 insertions(+), 23 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1558,7 +1558,7 @@ ignore_link:
 		if (intr_status & EESR_TABT) {	/* Transmit Abort int */
 			ndev->stats.tx_aborted_errors++;
 			if (netif_msg_tx_err(mdp))
-				dev_err(&ndev->dev, "Transmit Abort\n");
+				netdev_err(ndev, "Transmit Abort\n");
 		}
 	}
 
@@ -1568,7 +1568,7 @@ ignore_link:
 			/* Receive Frame Overflow int */
 			ndev->stats.rx_frame_errors++;
 			if (netif_msg_rx_err(mdp))
-				dev_err(&ndev->dev, "Receive Abort\n");
+				netdev_err(ndev, "Receive Abort\n");
 		}
 	}
 
@@ -1576,14 +1576,14 @@ ignore_link:
 		/* Transmit Descriptor Empty int */
 		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Transmit Descriptor Empty\n");
+			netdev_err(ndev, "Transmit Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_TFE) {
 		/* FIFO under flow */
 		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Transmit FIFO Under flow\n");
+			netdev_err(ndev, "Transmit FIFO Under flow\n");
 	}
 
 	if (intr_status & EESR_RDE) {
@@ -1591,21 +1591,21 @@ ignore_link:
 		ndev->stats.rx_over_errors++;
 
 		if (netif_msg_rx_err(mdp))
-			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
+			netdev_err(ndev, "Receive Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		ndev->stats.rx_fifo_errors++;
 		if (netif_msg_rx_err(mdp))
-			dev_err(&ndev->dev, "Receive FIFO Overflow\n");
+			netdev_err(ndev, "Receive FIFO Overflow\n");
 	}
 
 	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
 		/* Address Error */
 		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
-			dev_err(&ndev->dev, "Address Error\n");
+			netdev_err(ndev, "Address Error\n");
 	}
 
 	mask = EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE;
@@ -1616,9 +1616,9 @@ ignore_link:
 		u32 edtrr = sh_eth_read(ndev, EDTRR);
 
 		/* dmesg */
-		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
-			intr_status, mdp->cur_tx, mdp->dirty_tx,
-			(u32)ndev->state, edtrr);
+		netdev_err(ndev, "TX error. status=%8.8x cur_tx=%8.8x dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
+			   intr_status, mdp->cur_tx, mdp->dirty_tx,
+			   (u32)ndev->state, edtrr);
 		/* dirty buffer free */
 		sh_eth_txfree(ndev);
 
@@ -1663,9 +1663,9 @@ static irqreturn_t sh_eth_interrupt(int 
 				     EESIPR);
 			__napi_schedule(&mdp->napi);
 		} else {
-			dev_warn(&ndev->dev,
-				 "ignoring interrupt, status 0x%08lx, mask 0x%08lx.\n",
-				 intr_status, intr_enable);
+			netdev_warn(ndev,
+				    "ignoring interrupt, status 0x%08lx, mask 0x%08lx.\n",
+				    intr_status, intr_enable);
 		}
 	}
 
@@ -1794,12 +1794,12 @@ static int sh_eth_phy_init(struct net_de
 	}
 
 	if (IS_ERR(phydev)) {
-		dev_err(&ndev->dev, "failed to connect PHY\n");
+		netdev_err(ndev, "failed to connect PHY\n");
 		return PTR_ERR(phydev);
 	}
 
-	dev_info(&ndev->dev, "attached PHY %d (IRQ %d) to driver %s\n",
-		 phydev->addr, phydev->irq, phydev->drv->name);
+	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
+		    phydev->addr, phydev->irq, phydev->drv->name);
 
 	mdp->phydev = phydev;
 
@@ -1980,12 +1980,12 @@ static int sh_eth_set_ringparam(struct n
 
 	ret = sh_eth_ring_init(ndev);
 	if (ret < 0) {
-		dev_err(&ndev->dev, "%s: sh_eth_ring_init failed.\n", __func__);
+		netdev_err(ndev, "%s: sh_eth_ring_init failed.\n", __func__);
 		return ret;
 	}
 	ret = sh_eth_dev_init(ndev, false);
 	if (ret < 0) {
-		dev_err(&ndev->dev, "%s: sh_eth_dev_init failed.\n", __func__);
+		netdev_err(ndev, "%s: sh_eth_dev_init failed.\n", __func__);
 		return ret;
 	}
 
@@ -2026,7 +2026,7 @@ static int sh_eth_open(struct net_device
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 			  mdp->cd->irq_flags, ndev->name, ndev);
 	if (ret) {
-		dev_err(&ndev->dev, "Can not assign IRQ number\n");
+		netdev_err(ndev, "Can not assign IRQ number\n");
 		goto out_napi_off;
 	}
 
@@ -2065,8 +2065,9 @@ static void sh_eth_tx_timeout(struct net
 	netif_stop_queue(ndev);
 
 	if (netif_msg_timer(mdp)) {
-		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, resetting...\n",
-			ndev->name, (int)sh_eth_read(ndev, EESR));
+		netdev_err(ndev,
+			   "transmit timed out, status %8.8x, resetting...\n",
+			   (int)sh_eth_read(ndev, EESR));
 	}
 
 	/* tx_errors count up */
@@ -2103,7 +2104,7 @@ static int sh_eth_start_xmit(struct sk_b
 	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
 		if (!sh_eth_txfree(ndev)) {
 			if (netif_msg_tx_queued(mdp))
-				dev_warn(&ndev->dev, "TxFD exhausted.\n");
+				netdev_warn(ndev, "TxFD exhausted.\n");
 			netif_stop_queue(ndev);
 			spin_unlock_irqrestore(&mdp->lock, flags);
 			return NETDEV_TX_BUSY;
@@ -2273,7 +2274,7 @@ static int sh_eth_tsu_busy(struct net_de
 		udelay(10);
 		timeout--;
 		if (timeout <= 0) {
-			dev_err(&ndev->dev, "%s: timeout\n", __func__);
+			netdev_err(ndev, "%s: timeout\n", __func__);
 			return -ETIMEDOUT;
 		}
 	}
