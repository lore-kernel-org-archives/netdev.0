From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/12] tg3: Fix message 80 char violations
Date: Mon, 5 Apr 2010 13:19:23 -0700
Message-ID: <1270498770-23765-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1343 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756460Ab0DEUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 05dbe005386e7521153dce6c5ad95c98b73b80c7, "Use (pr|netdev)_<level>
macro helpers" extended some of the message lines longer than 80 chars.
This patch reels the line lengths back in.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   60 +++++++++++++++++++++++++++++++++-------------------
 1 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 80d3f15..4d96d2d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4335,8 +4335,11 @@ static void tg3_tx_recover(struct tg3 *tp)
 	BUG_ON((tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER) ||
 	       tp->write32_tx_mbox == tg3_write_indirect_mbox);
 
-	netdev_warn(tp->dev, "The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover\n"
-		    "Please report the problem to the driver maintainer and include system chipset information.\n");
+	netdev_warn(tp->dev,
+		    "The system may be re-ordering memory-mapped I/O "
+		    "cycles to the network device, attempting to recover. "
+		    "Please report the problem to the driver maintainer "
+		    "and include system chipset information.\n");
 
 	spin_lock(&tp->lock);
 	tp->tg3_flags |= TG3_FLAG_TX_RECOVERY_PENDING;
@@ -5260,7 +5263,8 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 
 	err = tg3_init_hw(tp, reset_phy);
 	if (err) {
-		netdev_err(tp->dev, "Failed to re-initialize device, aborting\n");
+		netdev_err(tp->dev,
+			   "Failed to re-initialize device, aborting\n");
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
@@ -5508,7 +5512,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			netif_tx_stop_queue(txq);
 
 			/* This is a hard error, log it. */
-			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
+			netdev_err(dev,
+				   "BUG! Tx Ring full when queue awake!\n");
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -5711,7 +5716,8 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			netif_tx_stop_queue(txq);
 
 			/* This is a hard error, log it. */
-			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
+			netdev_err(dev,
+				   "BUG! Tx Ring full when queue awake!\n");
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -6058,8 +6064,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
 		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
-			netdev_warn(tp->dev, "Using a smaller RX standard ring, only %d out of %d buffers were allocated successfully\n",
-				    i, tp->rx_pending);
+			netdev_warn(tp->dev,
+				    "Using a smaller RX standard ring. Only "
+				    "%d out of %d buffers were allocated "
+				    "successfully\n", i, tp->rx_pending);
 			if (i == 0)
 				goto initfail;
 			tp->rx_pending = i;
@@ -6088,8 +6096,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	for (i = 0; i < tp->rx_jumbo_pending; i++) {
 		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_JUMBO, i) < 0) {
-			netdev_warn(tp->dev, "Using a smaller RX jumbo ring, only %d out of %d buffers were allocated successfully\n",
-				    i, tp->rx_jumbo_pending);
+			netdev_warn(tp->dev,
+				    "Using a smaller RX jumbo ring. Only %d "
+				    "out of %d buffers were allocated "
+				    "successfully\n", i, tp->rx_jumbo_pending);
 			if (i == 0)
 				goto initfail;
 			tp->rx_jumbo_pending = i;
@@ -7158,7 +7168,8 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base, u32 cpu_scratch_b
 
 	if (cpu_base == TX_CPU_BASE &&
 	    (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		netdev_err(tp->dev, "%s: Trying to load TX cpu firmware which is 5705\n",
+		netdev_err(tp->dev,
+			   "%s: Trying to load TX cpu firmware which is 5705\n",
 			   __func__);
 		return -EINVAL;
 	}
@@ -7238,7 +7249,8 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 		udelay(1000);
 	}
 	if (i >= 5) {
-		netdev_err(tp->dev, "tg3_load_firmware fails to set RX CPU PC, is %08x should be %08x\n",
+		netdev_err(tp->dev, "%s fails to set RX CPU PC, is %08x "
+			   "should be %08x\n", __func__,
 			   tr32(RX_CPU_BASE + CPU_PC), info.fw_base);
 		return -ENODEV;
 	}
@@ -7302,7 +7314,8 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 		udelay(1000);
 	}
 	if (i >= 5) {
-		netdev_err(tp->dev, "%s fails to set CPU PC, is %08x should be %08x\n",
+		netdev_err(tp->dev,
+			   "%s fails to set CPU PC, is %08x should be %08x\n",
 			   __func__, tr32(cpu_base + CPU_PC), info.fw_base);
 		return -ENODEV;
 	}
@@ -8627,8 +8640,9 @@ static int tg3_test_msi(struct tg3 *tp)
 		return err;
 
 	/* MSI test failed, go back to INTx mode */
-	netdev_warn(tp->dev, "No interrupt was generated using MSI, switching to INTx mode\n"
-		    "Please report this failure to the PCI maintainer and include system chipset information\n");
+	netdev_warn(tp->dev, "No interrupt was generated using MSI. Switching "
+		    "to INTx mode. Please report this failure to the PCI "
+		    "maintainer and include system chipset information\n");
 
 	free_irq(tp->napi[0].irq_vec, &tp->napi[0]);
 
@@ -8740,7 +8754,8 @@ static void tg3_ints_init(struct tg3 *tp)
 		/* All MSI supporting chips should support tagged
 		 * status.  Assert that this is the case.
 		 */
-		netdev_warn(tp->dev, "MSI without TAGGED? Not using MSI\n");
+		netdev_warn(tp->dev,
+			    "MSI without TAGGED_STATUS? Not using MSI\n");
 		goto defcfg;
 	}
 
@@ -11778,7 +11793,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		tp->tg3_flags |= TG3_FLAG_NVRAM;
 
 		if (tg3_nvram_lock(tp)) {
-			netdev_warn(tp->dev, "Cannot get nvram lock, %s failed\n",
+			netdev_warn(tp->dev,
+				    "Cannot get nvram lock, %s failed\n",
 				    __func__);
 			return;
 		}
@@ -14130,9 +14146,8 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 		/* Now read it back. */
 		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, 0);
 		if (ret) {
-			dev_err(&tp->pdev->dev,
-				"%s: Buffer read failed. err = %d\n",
-				__func__, ret);
+			dev_err(&tp->pdev->dev, "%s: Buffer read failed. "
+				"err = %d\n", __func__, ret);
 			break;
 		}
 
@@ -14733,11 +14748,12 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
 		struct phy_device *phydev;
 		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
-		netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
+		netdev_info(dev,
+			    "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
 			    phydev->drv->name, dev_name(&phydev->dev));
 	} else
-		netdev_info(dev, "attached PHY is %s (%s Ethernet) (WireSpeed[%d])\n",
-			    tg3_phy_string(tp),
+		netdev_info(dev, "attached PHY is %s (%s Ethernet) "
+			    "(WireSpeed[%d])\n", tg3_phy_string(tp),
 			    ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
 			     ((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
 			      "10/100/1000Base-T")),
-- 
1.6.4.4


