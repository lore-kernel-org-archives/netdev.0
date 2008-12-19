From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Fri, 19 Dec 2008 08:42:37 -0500
Message-ID: <20081219134237.GA8802@hmsreliant.think-freely.org>
References: <20081218195236.GA5191@hmsreliant.think-freely.org> <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk> <20081219012527.GA2669@localhost.localdomain> <20081218.224224.227412554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59443 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbYLSNpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 08:45:04 -0500
Content-Disposition: inline
In-Reply-To: <20081218.224224.227412554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 10:42:24PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 18 Dec 2008 20:25:27 -0500
> 
> > Dave, can you fix this up, or would you rather I repost the patch?
> 
> You need to do that anyways so that you can provide a proper
> full commit message and a proper signoff.
> 
> Thanks.
> 
> 

Copy that.  New patch, same as old, with the inappropriately modified comments
left out

When the napi api was changed to separate its 1:1 binding to the net_device
struct, the netif_rx_[prep|schedule|complete] api failed to remove the now
vestigual net_device structure parameter.  This patch cleans up that api by
properly removing it..

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drivers/infiniband/hw/nes/nes_hw.c      |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c     |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    6 +++---
 drivers/net/8139cp.c                    |    6 +++---
 drivers/net/8139too.c                   |    6 +++---
 drivers/net/amd8111e.c                  |    6 +++---
 drivers/net/arm/ep93xx_eth.c            |    6 +++---
 drivers/net/arm/ixp4xx_eth.c            |    6 +++---
 drivers/net/atl1e/atl1e_main.c          |    6 +++---
 drivers/net/b44.c                       |    6 +++---
 drivers/net/bnx2.c                      |   15 ++++++---------
 drivers/net/bnx2x_main.c                |    6 +++---
 drivers/net/cassini.c                   |    8 ++++----
 drivers/net/chelsio/sge.c               |    4 ++--
 drivers/net/cpmac.c                     |   10 +++++-----
 drivers/net/e100.c                      |    7 +++----
 drivers/net/e1000/e1000_main.c          |   10 +++++-----
 drivers/net/e1000e/netdev.c             |   14 +++++++-------
 drivers/net/ehea/ehea_main.c            |    6 +++---
 drivers/net/enic/enic_main.c            |   12 ++++++------
 drivers/net/epic100.c                   |    6 +++---
 drivers/net/forcedeth.c                 |   10 +++++-----
 drivers/net/fs_enet/fs_enet-main.c      |    4 ++--
 drivers/net/gianfar.c                   |    6 +++---
 drivers/net/ibmveth.c                   |    6 +++---
 drivers/net/igb/igb_main.c              |   12 ++++++------
 drivers/net/ixgb/ixgb_main.c            |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c          |   12 ++++++------
 drivers/net/ixp2000/ixpdev.c            |    4 ++--
 drivers/net/jme.c                       |    1 -
 drivers/net/jme.h                       |    6 +++---
 drivers/net/korina.c                    |    4 ++--
 drivers/net/macb.c                      |   10 +++++-----
 drivers/net/mlx4/en_rx.c                |    4 ++--
 drivers/net/myri10ge/myri10ge.c         |    6 +++---
 drivers/net/natsemi.c                   |    6 +++---
 drivers/net/netxen/netxen_nic_main.c    |    2 +-
 drivers/net/niu.c                       |    6 +++---
 drivers/net/pasemi_mac.c                |    6 +++---
 drivers/net/pcnet32.c                   |    6 +++---
 drivers/net/qla3xxx.c                   |    6 +++---
 drivers/net/qlge/qlge_main.c            |    7 +++----
 drivers/net/r6040.c                     |    4 ++--
 drivers/net/r8169.c                     |    6 +++---
 drivers/net/s2io.c                      |    8 ++++----
 drivers/net/sb1250-mac.c                |    6 +++---
 drivers/net/sfc/efx.c                   |    2 +-
 drivers/net/sfc/efx.h                   |    2 +-
 drivers/net/skge.c                      |    6 +++---
 drivers/net/smsc911x.c                  |    2 +-
 drivers/net/smsc9420.c                  |    4 ++--
 drivers/net/spider_net.c                |   15 ++++++---------
 drivers/net/starfire.c                  |    6 +++---
 drivers/net/sungem.c                    |    6 +++---
 drivers/net/tc35815.c                   |    6 +++---
 drivers/net/tehuti.c                    |    7 +++----
 drivers/net/tg3.c                       |   14 +++++++-------
 drivers/net/tsi108_eth.c                |    6 +++---
 drivers/net/tulip/interrupt.c           |    8 ++++----
 drivers/net/typhoon.c                   |    7 +++----
 drivers/net/ucc_geth.c                  |    6 +++---
 drivers/net/via-rhine.c                 |    4 ++--
 drivers/net/virtio_net.c                |   12 ++++++------
 drivers/net/wan/hd64572.c               |    4 ++--
 drivers/net/xen-netfront.c              |    8 ++++----
 include/linux/netdevice.h               |   24 +++++++++---------------
 66 files changed, 218 insertions(+), 235 deletions(-)


diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 7c49cc8..735c125 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2541,7 +2541,7 @@ static void nes_nic_napi_ce_handler(struct nes_device *nesdev, struct nes_hw_nic
 {
 	struct nes_vnic *nesvnic = container_of(cq, struct nes_vnic, nic_cq);
 
-	netif_rx_schedule(nesdev->netdev[nesvnic->netdev_index], &nesvnic->napi);
+	netif_rx_schedule(&nesvnic->napi);
 }
 
 
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 3c96203..80e7a4d 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -112,7 +112,7 @@ static int nes_netdev_poll(struct napi_struct *napi, int budget)
 	nes_nic_ce_handler(nesdev, nescq);
 
 	if (nescq->cqes_pending == 0) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		/* clear out completed cqes and arm */
 		nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_NOTIFY_NEXT |
 				nescq->cq_number | (nescq->cqe_allocs_pending << 16));
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 28eb6f0..a192581 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -446,11 +446,11 @@ poll_more:
 		if (dev->features & NETIF_F_LRO)
 			lro_flush_all(&priv->lro.lro_mgr);
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		if (unlikely(ib_req_notify_cq(priv->recv_cq,
 					      IB_CQ_NEXT_COMP |
 					      IB_CQ_REPORT_MISSED_EVENTS)) &&
-		    netif_rx_reschedule(dev, napi))
+		    netif_rx_reschedule(napi))
 			goto poll_more;
 	}
 
@@ -462,7 +462,7 @@ void ipoib_ib_completion(struct ib_cq *cq, void *dev_ptr)
 	struct net_device *dev = dev_ptr;
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	netif_rx_schedule(dev, &priv->napi);
+	netif_rx_schedule(&priv->napi);
 }
 
 static void drain_tx_cq(struct net_device *dev)
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index f6d9d13..dd7ac82 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -604,7 +604,7 @@ rx_next:
 
 		spin_lock_irqsave(&cp->lock, flags);
 		cpw16_f(IntrMask, cp_intr_mask);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
 
@@ -641,9 +641,9 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	}
 
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
-		if (netif_rx_schedule_prep(dev, &cp->napi)) {
+		if (netif_rx_schedule_prep(&cp->napi)) {
 			cpw16_f(IntrMask, cp_norx_intr_mask);
-			__netif_rx_schedule(dev, &cp->napi);
+			__netif_rx_schedule(&cp->napi);
 		}
 
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 67bbf4f..fe370f8 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2128,7 +2128,7 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 		 */
 		spin_lock_irqsave(&tp->lock, flags);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 	spin_unlock(&tp->rx_lock);
@@ -2178,9 +2178,9 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
 	if (status & RxAckBits){
-		if (netif_rx_schedule_prep(dev, &tp->napi)) {
+		if (netif_rx_schedule_prep(&tp->napi)) {
 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
-			__netif_rx_schedule(dev, &tp->napi);
+			__netif_rx_schedule(&tp->napi);
 		}
 	}
 
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 0bc4f54..187ac6e 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -831,7 +831,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	if (rx_pkt_limit > 0) {
 		/* Receive descriptor is empty now */
 		spin_lock_irqsave(&lp->lock, flags);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		writel(VAL0|RINTEN0, mmio + INTEN0);
 		writel(VAL2 | RDMD0, mmio + CMD0);
 		spin_unlock_irqrestore(&lp->lock, flags);
@@ -1170,11 +1170,11 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 
 	/* Check if Receive Interrupt has occurred. */
 	if (intr0 & RINT0) {
-		if (netif_rx_schedule_prep(dev, &lp->napi)) {
+		if (netif_rx_schedule_prep(&lp->napi)) {
 			/* Disable receive interupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
-			__netif_rx_schedule(dev, &lp->napi);
+			__netif_rx_schedule(&lp->napi);
 		} else if (intren0 & RINTEN0) {
 			printk("************Driver bug! \
 				interrupt while in poll\n");
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 588c973..6ecc600 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -298,7 +298,7 @@ poll_some_more:
 		int more = 0;
 
 		spin_lock_irq(&ep->rx_lock);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
 		if (ep93xx_have_more_rx(ep)) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
@@ -415,9 +415,9 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id)
 
 	if (status & REG_INTSTS_RX) {
 		spin_lock(&ep->rx_lock);
-		if (likely(netif_rx_schedule_prep(dev, &ep->napi))) {
+		if (likely(netif_rx_schedule_prep(&ep->napi))) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
-			__netif_rx_schedule(dev, &ep->napi);
+			__netif_rx_schedule(&ep->napi);
 		}
 		spin_unlock(&ep->rx_lock);
 	}
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 14ffa2a..b03609f 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -498,7 +498,7 @@ static void eth_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: eth_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(port->plat->rxq);
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 }
 
 static int eth_poll(struct napi_struct *napi, int budget)
@@ -526,7 +526,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
 			       dev->name);
 #endif
-			netif_rx_complete(dev, napi);
+			netif_rx_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
 			    netif_rx_reschedule(dev, napi)) {
@@ -1025,7 +1025,7 @@ static int eth_open(struct net_device *dev)
 	}
 	ports_open++;
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 	return 0;
 }
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 98b2a7a..a72a461 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1326,9 +1326,9 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 			AT_WRITE_REG(hw, REG_IMR,
 				     IMR_NORMAL_MASK & ~ISR_RX_EVENT);
 			AT_WRITE_FLUSH(hw);
-			if (likely(netif_rx_schedule_prep(netdev,
+			if (likely(netif_rx_schedule_prep(
 				   &adapter->napi)))
-				__netif_rx_schedule(netdev, &adapter->napi);
+				__netif_rx_schedule(&adapter->napi);
 		}
 	} while (--max_ints > 0);
 	/* re-enable Interrupt*/
@@ -1515,7 +1515,7 @@ static int atl1e_clean(struct napi_struct *napi, int budget)
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if (work_done < budget) {
 quit_polling:
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		imr_data = AT_READ_REG(&adapter->hw, REG_IMR);
 		AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT);
 		/* test debug */
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 2c7a32e..934a950 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -875,7 +875,7 @@ static int b44_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		b44_enable_ints(bp);
 	}
 
@@ -907,13 +907,13 @@ static irqreturn_t b44_interrupt(int irq, void *dev_id)
 			goto irq_ack;
 		}
 
-		if (netif_rx_schedule_prep(dev, &bp->napi)) {
+		if (netif_rx_schedule_prep(&bp->napi)) {
 			/* NOTE: These writes are posted by the readback of
 			 *       the ISTAT register below.
 			 */
 			bp->istat = istat;
 			__b44_disable_ints(bp);
-			__netif_rx_schedule(dev, &bp->napi);
+			__netif_rx_schedule(&bp->napi);
 		} else {
 			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
 			       dev->name);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1a27803..33d69dd 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3043,7 +3043,6 @@ bnx2_msi(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
@@ -3054,7 +3053,7 @@ bnx2_msi(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev, &bnapi->napi);
+	netif_rx_schedule(&bnapi->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3064,7 +3063,6 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 
@@ -3072,7 +3070,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev, &bnapi->napi);
+	netif_rx_schedule(&bnapi->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3082,7 +3080,6 @@ bnx2_interrupt(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bnapi->status_blk.msi;
 
 	/* When using INTx, it is possible for the interrupt to arrive
@@ -3109,9 +3106,9 @@ bnx2_interrupt(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	if (netif_rx_schedule_prep(dev, &bnapi->napi)) {
+	if (netif_rx_schedule_prep(&bnapi->napi)) {
 		bnapi->last_status_idx = sblk->status_idx;
-		__netif_rx_schedule(dev, &bnapi->napi);
+		__netif_rx_schedule(&bnapi->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -3221,7 +3218,7 @@ static int bnx2_poll_msix(struct napi_struct *napi, int budget)
 		rmb();
 		if (likely(!bnx2_has_fast_work(bnapi))) {
 
-			netif_rx_complete(bp->dev, napi);
+			netif_rx_complete(napi);
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 			       bnapi->last_status_idx);
@@ -3254,7 +3251,7 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
-			netif_rx_complete(bp->dev, napi);
+			netif_rx_complete(napi);
 			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
 				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 24d2ae8..02ab9b0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1615,7 +1615,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	prefetch(&fp->status_blk->c_status_block.status_block_index);
 	prefetch(&fp->status_blk->u_status_block.status_block_index);
 
-	netif_rx_schedule(dev, &bnx2x_fp(bp, index, napi));
+	netif_rx_schedule(&bnx2x_fp(bp, index, napi));
 
 	return IRQ_HANDLED;
 }
@@ -1654,7 +1654,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		prefetch(&fp->status_blk->c_status_block.status_block_index);
 		prefetch(&fp->status_blk->u_status_block.status_block_index);
 
-		netif_rx_schedule(dev, &bnx2x_fp(bp, 0, napi));
+		netif_rx_schedule(&bnx2x_fp(bp, 0, napi));
 
 		status &= ~mask;
 	}
@@ -9284,7 +9284,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
-		netif_rx_complete(bp->dev, napi);
+		netif_rx_complete(napi);
 
 		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 023d205..321f43d 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2506,7 +2506,7 @@ static irqreturn_t cas_interruptN(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, ring, 0);
 #endif
@@ -2557,7 +2557,7 @@ static irqreturn_t cas_interrupt1(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 1, 0);
 #endif
@@ -2613,7 +2613,7 @@ static irqreturn_t cas_interrupt(int irq, void *dev_id)
 	if (status & INTR_RX_DONE) {
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 0, 0);
 #endif
@@ -2691,7 +2691,7 @@ rx_comp:
 #endif
 	spin_unlock_irqrestore(&cp->lock, flags);
 	if (enable_intr) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		cas_unmask_intr(cp);
 	}
 	return credits;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 1da7007..7896468 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1613,7 +1613,7 @@ int t1_poll(struct napi_struct *napi, int budget)
 	int work_done = process_responses(adapter, budget);
 
 	if (likely(work_done < budget)) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
 	}
@@ -1633,7 +1633,7 @@ irqreturn_t t1_interrupt(int irq, void *data)
 
 		if (napi_schedule_prep(&adapter->napi)) {
 			if (process_pure_responses(adapter))
-				__netif_rx_schedule(dev, &adapter->napi);
+				__netif_rx_schedule(&adapter->napi);
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index d39a77c..f665487 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -428,7 +428,7 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
 			       priv->dev->name);
 		spin_unlock(&priv->rx_lock);
-		netif_rx_complete(priv->dev, napi);
+		netif_rx_complete(napi);
 		return 0;
 	}
 
@@ -514,7 +514,7 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 	if (processed == 0) {
 		/* we ran out of packets to read,
 		 * revert to interrupt-driven mode */
-		netif_rx_complete(priv->dev, napi);
+		netif_rx_complete(napi);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
 	}
@@ -536,7 +536,7 @@ fatal_error:
 	}
 
 	spin_unlock(&priv->rx_lock);
-	netif_rx_complete(priv->dev, napi);
+	netif_rx_complete(napi);
 	netif_tx_stop_all_queues(priv->dev);
 	napi_disable(&priv->napi);
 
@@ -802,9 +802,9 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 
 	if (status & MAC_INT_RX) {
 		queue = (status >> 8) & 7;
-		if (netif_rx_schedule_prep(dev, &priv->napi)) {
+		if (netif_rx_schedule_prep(&priv->napi)) {
 			cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
-			__netif_rx_schedule(dev, &priv->napi);
+			__netif_rx_schedule(&priv->napi);
 		}
 	}
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index dce7ff2..9f38b16 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2049,9 +2049,9 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	if(stat_ack & stat_ack_rnr)
 		nic->ru_running = RU_SUSPENDED;
 
-	if(likely(netif_rx_schedule_prep(netdev, &nic->napi))) {
+	if(likely(netif_rx_schedule_prep(&nic->napi))) {
 		e100_disable_irq(nic);
-		__netif_rx_schedule(netdev, &nic->napi);
+		__netif_rx_schedule(&nic->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2060,7 +2060,6 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 static int e100_poll(struct napi_struct *napi, int budget)
 {
 	struct nic *nic = container_of(napi, struct nic, napi);
-	struct net_device *netdev = nic->netdev;
 	unsigned int work_done = 0;
 
 	e100_rx_clean(nic, &work_done, budget);
@@ -2068,7 +2067,7 @@ static int e100_poll(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		e100_enable_irq(nic);
 	}
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 116c96e..26474c9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3687,12 +3687,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
+	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
 
@@ -3747,12 +3747,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		ew32(IMC, ~0);
 		E1000_WRITE_FLUSH();
 	}
-	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
+	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
@@ -3793,7 +3793,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev, napi);
+		netif_rx_complete(napi);
 		e1000_irq_enable(adapter);
 	}
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f7b0560..d4639fa 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1179,12 +1179,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -1246,12 +1246,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -1320,10 +1320,10 @@ static irqreturn_t e1000_intr_msix_rx(int irq, void *data)
 		adapter->rx_ring->set_itr = 0;
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -2028,7 +2028,7 @@ clean_rx:
 	if (work_done < budget) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev, napi);
+		netif_rx_complete(napi);
 		if (adapter->msix_entries)
 			ew32(IMS, adapter->rx_ring->ims_val);
 		else
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 44c9ae1..035aa7d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -830,7 +830,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 	while ((rx != budget) || force_irq) {
 		pr->poll_counter = 0;
 		force_irq = 0;
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
@@ -859,7 +859,7 @@ static void ehea_netpoll(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < port->num_def_qps; i++)
-		netif_rx_schedule(dev, &port->port_res[i].napi);
+		netif_rx_schedule(&port->port_res[i].napi);
 }
 #endif
 
@@ -867,7 +867,7 @@ static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
 
-	netif_rx_schedule(pr->port->netdev, &pr->napi);
+	netif_rx_schedule(&pr->napi);
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index deddd76..d039e16 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -411,8 +411,8 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 	}
 
 	if (ENIC_TEST_INTR(pba, ENIC_INTX_WQ_RQ)) {
-		if (netif_rx_schedule_prep(netdev, &enic->napi))
-			__netif_rx_schedule(netdev, &enic->napi);
+		if (netif_rx_schedule_prep(&enic->napi))
+			__netif_rx_schedule(&enic->napi);
 	} else {
 		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
 	}
@@ -440,7 +440,7 @@ static irqreturn_t enic_isr_msi(int irq, void *data)
 	 * writes).
 	 */
 
-	netif_rx_schedule(enic->netdev, &enic->napi);
+	netif_rx_schedule(&enic->napi);
 
 	return IRQ_HANDLED;
 }
@@ -450,7 +450,7 @@ static irqreturn_t enic_isr_msix_rq(int irq, void *data)
 	struct enic *enic = data;
 
 	/* schedule NAPI polling for RQ cleanup */
-	netif_rx_schedule(enic->netdev, &enic->napi);
+	netif_rx_schedule(&enic->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1068,7 +1068,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
 
@@ -1112,7 +1112,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
 
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 4a951b8..f9b37c8 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1109,9 +1109,9 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
 		spin_lock(&ep->napi_lock);
-		if (netif_rx_schedule_prep(dev, &ep->napi)) {
+		if (netif_rx_schedule_prep(&ep->napi)) {
 			epic_napi_irq_off(dev, ep);
-			__netif_rx_schedule(dev, &ep->napi);
+			__netif_rx_schedule(&ep->napi);
 		} else
 			ep->reschedule_in_poll++;
 		spin_unlock(&ep->napi_lock);
@@ -1288,7 +1288,7 @@ rx_action:
 
 		more = ep->reschedule_in_poll;
 		if (!more) {
-			__netif_rx_complete(dev, napi);
+			__netif_rx_complete(napi);
 			outl(EpicNapiEvent, ioaddr + INTSTAT);
 			epic_napi_irq_on(dev, ep);
 		} else
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1f2b247..9fbfa85 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1760,7 +1760,7 @@ static void nv_do_rx_refill(unsigned long data)
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* Just reschedule NAPI rx processing */
-	netif_rx_schedule(dev, &np->napi);
+	netif_rx_schedule(&np->napi);
 }
 #else
 static void nv_do_rx_refill(unsigned long data)
@@ -3403,7 +3403,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3520,7 +3520,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3678,7 +3678,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 		/* re-enable receive interrupts */
 		spin_lock_irqsave(&np->lock, flags);
 
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 
 		np->irqmask |= NVREG_IRQ_RX_ALL;
 		if (np->msi_flags & NV_MSI_X_ENABLED)
@@ -3704,7 +3704,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 
 	if (events) {
-		netif_rx_schedule(dev, &np->napi);
+		netif_rx_schedule(&np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index df66d62..4e6a919 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -209,7 +209,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 	if (received < budget) {
 		/* done */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		(*fep->ops->napi_enable_rx)(dev);
 	}
 	return received;
@@ -478,7 +478,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 				/* NOTE: it is possible for FCCs in NAPI mode    */
 				/* to submit a spurious interrupt while in poll  */
 				if (napi_ok)
-					__netif_rx_schedule(dev, &fep->napi);
+					__netif_rx_schedule(&fep->napi);
 			}
 		}
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 13f4964..c672ecf 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1607,9 +1607,9 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 static void gfar_schedule_cleanup(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	if (netif_rx_schedule_prep(dev, &priv->napi)) {
+	if (netif_rx_schedule_prep(&priv->napi)) {
 		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
-		__netif_rx_schedule(dev, &priv->napi);
+		__netif_rx_schedule(&priv->napi);
 	}
 }
 
@@ -1863,7 +1863,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		return budget;
 
 	if (rx_cleaned < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 02ecfdb..1f055a9 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1028,7 +1028,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 
 		ibmveth_assert(lpar_rc == H_SUCCESS);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 
 		if (ibmveth_rxq_pending_buffer(adapter) &&
 		    netif_rx_reschedule(netdev, napi)) {
@@ -1047,11 +1047,11 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_DISABLE);
 		ibmveth_assert(lpar_rc == H_SUCCESS);
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 25df7c9..6a40d94 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3347,8 +3347,8 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 
 	igb_write_itr(rx_ring);
 
-	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
-		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
+	if (netif_rx_schedule_prep(&rx_ring->napi))
+		__netif_rx_schedule(&rx_ring->napi);
 
 #ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
@@ -3500,7 +3500,7 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
+	netif_rx_schedule(&adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3538,7 +3538,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
+	netif_rx_schedule(&adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3573,7 +3573,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	    !netif_running(netdev)) {
 		if (adapter->itr_setting & 3)
 			igb_set_itr(adapter);
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			igb_irq_enable(adapter);
 		return 0;
@@ -3599,7 +3599,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done == 0) || !netif_running(netdev)) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 
 		if (adapter->itr_setting & 3) {
 			if (adapter->num_rx_queues == 1)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 820a92c..679125b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1721,14 +1721,14 @@ ixgb_intr(int irq, void *data)
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 
 		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
 
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -1750,7 +1750,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 92b35cf..b6ae9f6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1012,7 +1012,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	netif_rx_schedule(adapter->netdev, &q_vector->napi);
+	netif_rx_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1053,7 +1053,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1102,7 +1102,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1378,13 +1378,13 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 
-	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
+	if (netif_rx_schedule_prep(&adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
 		adapter->tx_ring[0].total_bytes = 0;
 		adapter->rx_ring[0].total_packets = 0;
 		adapter->rx_ring[0].total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
-		__netif_rx_schedule(netdev, &adapter->q_vector[0].napi);
+		__netif_rx_schedule(&adapter->q_vector[0].napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2308,7 +2308,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index bd96dbc..0147457 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -141,7 +141,7 @@ static int ixpdev_poll(struct napi_struct *napi, int budget)
 			break;
 	} while (ixp2000_reg_read(IXP2000_IRQ_THD_RAW_STATUS_A_0) & 0x00ff);
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 	ixp2000_reg_write(IXP2000_IRQ_THD_ENABLE_SET_A_0, 0x00ff);
 
 	return rx;
@@ -204,7 +204,7 @@ static irqreturn_t ixpdev_interrupt(int irq, void *dev_id)
 
 		ixp2000_reg_wrb(IXP2000_IRQ_THD_ENABLE_CLEAR_A_0, 0x00ff);
 		if (likely(napi_schedule_prep(&ip->napi))) {
-			__netif_rx_schedule(dev, &ip->napi);
+			__netif_rx_schedule(&ip->napi);
 		} else {
 			printk(KERN_CRIT "ixp2000: irq while polling!!\n");
 		}
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 15035cb..08b3405 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1250,7 +1250,6 @@ static int
 jme_poll(JME_NAPI_HOLDER(holder), JME_NAPI_WEIGHT(budget))
 {
 	struct jme_adapter *jme = jme_napi_priv(holder);
-	struct net_device *netdev = jme->dev;
 	int rest;
 
 	rest = jme_process_receive(jme, JME_NAPI_WEIGHT_VAL(budget));
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index adaf3dd..2d6f30e 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -398,15 +398,15 @@ struct jme_ring {
 #define JME_NAPI_WEIGHT(w) int w
 #define JME_NAPI_WEIGHT_VAL(w) w
 #define JME_NAPI_WEIGHT_SET(w, r)
-#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(dev, napis)
+#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(napis)
 #define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
 #define JME_NAPI_DISABLE(priv) \
 	if (!napi_disable_pending(&priv->napi)) \
 		napi_disable(&priv->napi);
 #define JME_RX_SCHEDULE_PREP(priv) \
-	netif_rx_schedule_prep(priv->dev, &priv->napi)
+	netif_rx_schedule_prep(&priv->napi)
 #define JME_RX_SCHEDULE(priv) \
-	__netif_rx_schedule(priv->dev, &priv->napi);
+	__netif_rx_schedule(&priv->napi);
 
 /*
  * Jmac Adapter Private data
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 6362695..4a5580c 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -327,7 +327,7 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
 
 	dmas = readl(&lp->rx_dma_regs->dmas);
 	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
-		netif_rx_schedule_prep(dev, &lp->napi);
+		netif_rx_schedule_prep(&lp->napi);
 
 		dmasm = readl(&lp->rx_dma_regs->dmasm);
 		writel(dmasm | (DMA_STAT_DONE |
@@ -466,7 +466,7 @@ static int korina_poll(struct napi_struct *napi, int budget)
 
 	work_done = korina_rx(dev, budget);
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		writel(readl(&lp->rx_dma_regs->dmasm) &
 			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 261b950..a04da4e 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -519,7 +519,7 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		 * this function was called last time, and no packets
 		 * have been received since.
 		 */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		goto out;
 	}
 
@@ -530,13 +530,13 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		dev_warn(&bp->pdev->dev,
 			 "No RX buffers complete, status = %02lx\n",
 			 (unsigned long)status);
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		goto out;
 	}
 
 	work_done = macb_rx(bp, budget);
 	if (work_done < budget)
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 	/*
 	 * We've done what we can to clean the buffers. Make sure we
@@ -571,7 +571,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (status & MACB_RX_INT_FLAGS) {
-			if (netif_rx_schedule_prep(dev, &bp->napi)) {
+			if (netif_rx_schedule_prep(&bp->napi)) {
 				/*
 				 * There's no point taking any more interrupts
 				 * until we have processed the buffers
@@ -579,7 +579,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
-				__netif_rx_schedule(dev, &bp->napi);
+				__netif_rx_schedule(&bp->napi);
 			}
 		}
 
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index ffe2808..c61b0bd 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -814,7 +814,7 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
 	if (priv->port_up)
-		netif_rx_schedule(cq->dev, &cq->napi);
+		netif_rx_schedule(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
@@ -834,7 +834,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
 	else {
 		/* Done for now */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
 	return done;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f017c77..378c89e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1515,7 +1515,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
@@ -1533,7 +1533,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* an interrupt on a non-zero receive-only slice is implicitly
 	 * valid  since MSI-X irqs are not shared */
 	if ((mgp->dev->real_num_tx_queues == 1) && (ss != mgp->ss)) {
-		netif_rx_schedule(ss->dev, &ss->napi);
+		netif_rx_schedule(&ss->napi);
 		return (IRQ_HANDLED);
 	}
 
@@ -1544,7 +1544,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(ss->dev, &ss->napi);
+		netif_rx_schedule(&ss->napi);
 
 	if (!mgp->msi_enabled && !mgp->msix_enabled) {
 		put_be32(0, mgp->irq_deassert);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9f81fcb..478edb9 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2193,10 +2193,10 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
 
-	if (netif_rx_schedule_prep(dev, &np->napi)) {
+	if (netif_rx_schedule_prep(&np->napi)) {
 		/* Disable interrupts and register for poll */
 		natsemi_irq_disable(dev);
-		__netif_rx_schedule(dev, &np->napi);
+		__netif_rx_schedule(&np->napi);
 	} else
 		printk(KERN_WARNING
 	       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
@@ -2248,7 +2248,7 @@ static int natsemi_poll(struct napi_struct *napi, int budget)
 		np->intr_status = readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6876bfd..ba01524 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1583,7 +1583,7 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 	}
 
 	if ((work_done < budget) && tx_complete) {
-		netif_rx_complete(adapter->netdev, &adapter->napi);
+		netif_rx_complete(&adapter->napi);
 		netxen_nic_enable_int(adapter);
 	}
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 022866d..7d662bb 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3614,7 +3614,7 @@ static int niu_poll(struct napi_struct *napi, int budget)
 	work_done = niu_poll_core(np, lp, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(np->dev, napi);
+		netif_rx_complete(napi);
 		niu_ldg_rearm(np, lp, 1);
 	}
 	return work_done;
@@ -4033,12 +4033,12 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
-	if (likely(netif_rx_schedule_prep(np->dev, &lp->napi))) {
+	if (likely(netif_rx_schedule_prep(&lp->napi))) {
 		lp->v0 = v0;
 		lp->v1 = v1;
 		lp->v2 = v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
-		__netif_rx_schedule(np->dev, &lp->napi);
+		__netif_rx_schedule(&lp->napi);
 	}
 }
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index fcbf6cc..dcd1990 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -971,7 +971,7 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
 
-	netif_rx_schedule(dev, &mac->napi);
+	netif_rx_schedule(&mac->napi);
 
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(chan->chno), reg);
 
@@ -1011,7 +1011,7 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 
 	mod_timer(&txring->clean_timer, jiffies + (TX_CLEAN_INTERVAL)*2);
 
-	netif_rx_schedule(mac->netdev, &mac->napi);
+	netif_rx_schedule(&mac->napi);
 
 	if (reg)
 		write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
@@ -1641,7 +1641,7 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	pkts = pasemi_mac_clean_rx(rx_ring(mac), budget);
 	if (pkts < budget) {
 		/* all done, no more packets present */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		pasemi_mac_restart_rx_intr(mac);
 		pasemi_mac_restart_tx_intr(mac);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index f2b192c..044b7b0 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1397,7 +1397,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		spin_lock_irqsave(&lp->lock, flags);
 
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 
 		/* clear interrupt masks */
 		val = lp->a.read_csr(ioaddr, CSR3);
@@ -2586,14 +2586,14 @@ pcnet32_interrupt(int irq, void *dev_id)
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-		if (netif_rx_schedule_prep(dev, &lp->napi)) {
+		if (netif_rx_schedule_prep(&lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
 			val = lp->a.read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
 			mmiowb();
-			__netif_rx_schedule(dev, &lp->napi);
+			__netif_rx_schedule(&lp->napi);
 			break;
 		}
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 6b7ed1a..33e8e62 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2293,7 +2293,7 @@ static int ql_poll(struct napi_struct *napi, int budget)
 
 	if (tx_cleaned + rx_cleaned != budget) {
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-		__netif_rx_complete(ndev, napi);
+		__netif_rx_complete(napi);
 		ql_update_small_bufq_prod_index(qdev);
 		ql_update_lrg_bufq_prod_index(qdev);
 		writel(qdev->rsp_consumer_index,
@@ -2352,8 +2352,8 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(ndev, &qdev->napi))) {
-			__netif_rx_schedule(ndev, &qdev->napi);
+		if (likely(netif_rx_schedule_prep(&qdev->napi))) {
+			__netif_rx_schedule(&qdev->napi);
 		}
 	} else {
 		return IRQ_NONE;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 225930f..0214708 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1647,7 +1647,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 		rx_ring->cq_id);
 
 	if (work_done < budget) {
-		__netif_rx_complete(qdev->ndev, napi);
+		__netif_rx_complete(napi);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
 	}
 	return work_done;
@@ -1733,7 +1733,7 @@ static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
 	struct ql_adapter *qdev = rx_ring->qdev;
-	netif_rx_schedule(qdev->ndev, &rx_ring->napi);
+	netif_rx_schedule(&rx_ring->napi);
 	return IRQ_HANDLED;
 }
 
@@ -1819,8 +1819,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 							      &rx_ring->rx_work,
 							      0);
 				else
-					netif_rx_schedule(qdev->ndev,
-							  &rx_ring->napi);
+					netif_rx_schedule(&rx_ring->napi);
 				work_done++;
 			}
 		}
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 281080d..6694eef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -667,7 +667,7 @@ static int r6040_poll(struct napi_struct *napi, int budget)
 	work_done = r6040_rx(dev, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* Enable RX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) | RX_INTS, ioaddr + MIER);
 	}
@@ -702,7 +702,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 
 		/* Mask off RX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) & ~RX_INTS, ioaddr + MIER);
-		netif_rx_schedule(dev, &lp->napi);
+		netif_rx_schedule(&lp->napi);
 	}
 
 	/* TX interrupt request */
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dddf6ae..2c73ca6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3581,8 +3581,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 		tp->intr_mask = ~tp->napi_event;
 
-		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
-			__netif_rx_schedule(dev, &tp->napi);
+		if (likely(netif_rx_schedule_prep(&tp->napi)))
+			__netif_rx_schedule(&tp->napi);
 		else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x in poll\n",
 			       dev->name, status);
@@ -3603,7 +3603,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		tp->intr_mask = 0xffff;
 		/*
 		 * 20040426: the barrier is not strictly required but the
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 1b489df..5128619 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2852,7 +2852,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	s2io_chk_rx_buffers(nic, ring);
 
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/*Re Enable MSI-Rx Vector*/
 		addr = (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr += 7 - ring->ring_no;
@@ -2890,7 +2890,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 			break;
 	}
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* Re enable the Rx interrupts for the ring */
 		writeq(0, &bar0->rx_traffic_mask);
 		readl(&bar0->rx_traffic_mask);
@@ -4344,7 +4344,7 @@ static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 		val8 = (ring->ring_no == 0) ? 0x7f : 0xff;
 		writeb(val8, addr);
 		val8 = readb(addr);
-		netif_rx_schedule(dev, &ring->napi);
+		netif_rx_schedule(&ring->napi);
 	} else {
 		rx_intr_handler(ring, 0);
 		s2io_chk_rx_buffers(sp, ring);
@@ -4791,7 +4791,7 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 
 		if (config->napi) {
 			if (reason & GEN_INTR_RXTRAFFIC) {
-				netif_rx_schedule(dev, &sp->napi);
+				netif_rx_schedule(&sp->napi);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 				readl(&bar0->rx_traffic_int);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 480caec..31e38fa 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2039,9 +2039,9 @@ static irqreturn_t sbmac_intr(int irq,void *dev_instance)
 		sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
 
 	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-		if (netif_rx_schedule_prep(dev, &sc->napi)) {
+		if (netif_rx_schedule_prep(&sc->napi)) {
 			__raw_writeq(0, sc->sbm_imr);
-			__netif_rx_schedule(dev, &sc->napi);
+			__netif_rx_schedule(&sc->napi);
 			/* Depend on the exit from poll to reenable intr */
 		}
 		else {
@@ -2667,7 +2667,7 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 #ifdef CONFIG_SBMAC_COALESCE
 		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 086629c..42934ba 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -230,7 +230,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		 * since efx_channel_processed() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		netif_rx_complete(napi_dev, napi);
+		netif_rx_complete(napi);
 		efx_channel_processed(channel);
 	}
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index dd0d45b..0dd7a53 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -77,7 +77,7 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 		  channel->channel, raw_smp_processor_id());
 	channel->work_pending = true;
 
-	netif_rx_schedule(channel->napi_dev, &channel->napi_str);
+	netif_rx_schedule(&channel->napi_str);
 }
 
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f73ee79..c9dbb06 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3214,7 +3214,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 		unsigned long flags;
 
 		spin_lock_irqsave(&hw->hw_lock, flags);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
@@ -3377,7 +3377,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 	if (status & (IS_XA1_F|IS_R1_F)) {
 		struct skge_port *skge = netdev_priv(hw->dev[0]);
 		hw->intr_mask &= ~(IS_XA1_F|IS_R1_F);
-		netif_rx_schedule(hw->dev[0], &skge->napi);
+		netif_rx_schedule(&skge->napi);
 	}
 
 	if (status & IS_PA_TO_TX1)
@@ -3397,7 +3397,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 
 		if (status & (IS_XA2_F|IS_R2_F)) {
 			hw->intr_mask &= ~(IS_XA2_F|IS_R2_F);
-			netif_rx_schedule(hw->dev[1], &skge->napi);
+			netif_rx_schedule(&skge->napi);
 		}
 
 		if (status & IS_PA_TO_RX2) {
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index fa28542..ecdde03 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -984,7 +984,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 			/* We processed all packets available.  Tell NAPI it can
 			 * stop polling then re-enable rx interrupts */
 			smsc911x_reg_write(pdata, INT_STS, INT_STS_RSFL_);
-			netif_rx_complete(dev, napi);
+			netif_rx_complete(napi);
 			temp = smsc911x_reg_read(pdata, INT_EN);
 			temp |= INT_EN_RSFL_EN_;
 			smsc911x_reg_write(pdata, INT_EN, temp);
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 940220f..27e017d 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -666,7 +666,7 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_id)
 			smsc9420_pci_flush_write(pd);
 
 			ints_to_clear |= (DMAC_STS_RX_ | DMAC_STS_NIS_);
-			netif_rx_schedule(pd->dev, &pd->napi);
+			netif_rx_schedule(&pd->napi);
 		}
 
 		if (ints_to_clear)
@@ -889,7 +889,7 @@ static int smsc9420_rx_poll(struct napi_struct *napi, int budget)
 	smsc9420_pci_flush_write(pd);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, &pd->napi);
+		netif_rx_complete(&pd->napi);
 
 		/* re-enable RX DMA interrupts */
 		dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 325fbc9..c5c123d 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1302,7 +1302,7 @@ static int spider_net_poll(struct napi_struct *napi, int budget)
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (packets_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull = 0;
 	}
@@ -1529,8 +1529,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 			spider_net_refill_rx_chain(card);
 			spider_net_enable_rxdmac(card);
 			card->num_rx_ints ++;
-			netif_rx_schedule(card->netdev,
-					  &card->napi);
+			netif_rx_schedule(&card->napi);
 		}
 		show_error = 0;
 		break;
@@ -1550,8 +1549,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev,
-				  &card->napi);
+		netif_rx_schedule(&card->napi);
 		show_error = 0;
 		break;
 
@@ -1565,8 +1563,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev,
-				  &card->napi);
+		netif_rx_schedule(&card->napi);
 		show_error = 0;
 		break;
 
@@ -1660,11 +1657,11 @@ spider_net_interrupt(int irq, void *ptr)
 
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
-		netif_rx_schedule(netdev, &card->napi);
+		netif_rx_schedule(&card->napi);
 		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
-		netif_rx_schedule(netdev, &card->napi);
+		netif_rx_schedule(&card->napi);
 
 	if (status_reg & SPIDER_NET_LINKINT)
 		spider_net_link_reset(netdev);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 0358809..d5b9dd8 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1290,8 +1290,8 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 		if (intr_status & (IntrRxDone | IntrRxEmpty)) {
 			u32 enable;
 
-			if (likely(netif_rx_schedule_prep(dev, &np->napi))) {
-				__netif_rx_schedule(dev, &np->napi);
+			if (likely(netif_rx_schedule_prep(&np->napi))) {
+				__netif_rx_schedule(&np->napi);
 				enable = readl(ioaddr + IntrEnable);
 				enable &= ~(IntrRxDone | IntrRxEmpty);
 				writel(enable, ioaddr + IntrEnable);
@@ -1530,7 +1530,7 @@ static int netdev_poll(struct napi_struct *napi, int budget)
 		intr_status = readl(ioaddr + IntrStatus);
 	} while (intr_status & (IntrRxDone | IntrRxEmpty));
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 	intr_status = readl(ioaddr + IntrEnable);
 	intr_status |= IntrRxDone | IntrRxEmpty;
 	writel(intr_status, ioaddr + IntrEnable);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index f4b0bee..8a74604 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -921,7 +921,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
 
-	__netif_rx_complete(dev, napi);
+	__netif_rx_complete(napi);
 	gem_enable_ints(gp);
 
 	spin_unlock_irqrestore(&gp->lock, flags);
@@ -944,7 +944,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 
 	spin_lock_irqsave(&gp->lock, flags);
 
-	if (netif_rx_schedule_prep(dev, &gp->napi)) {
+	if (netif_rx_schedule_prep(&gp->napi)) {
 		u32 gem_status = readl(gp->regs + GREG_STAT);
 
 		if (gem_status == 0) {
@@ -954,7 +954,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 		}
 		gp->status = gem_status;
 		gem_disable_ints(gp);
-		__netif_rx_schedule(dev, &gp->napi);
+		__netif_rx_schedule(&gp->napi);
 	}
 
 	spin_unlock_irqrestore(&gp->lock, flags);
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 308f365..bcd0e60 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1609,8 +1609,8 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	if (!(dmactl & DMA_IntMask)) {
 		/* disable interrupts */
 		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
-		if (netif_rx_schedule_prep(dev, &lp->napi))
-			__netif_rx_schedule(dev, &lp->napi);
+		if (netif_rx_schedule_prep(&lp->napi))
+			__netif_rx_schedule(&lp->napi);
 		else {
 			printk(KERN_ERR "%s: interrupt taken in poll\n",
 			       dev->name);
@@ -1919,7 +1919,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	spin_unlock(&lp->lock);
 
 	if (received < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* enable interrupts */
 		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
 	}
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 5b83fbb..a10a83a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -265,8 +265,8 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 		bdx_isr_extra(priv, isr);
 
 	if (isr & (IR_RX_DESC_0 | IR_TX_FREE_0)) {
-		if (likely(netif_rx_schedule_prep(ndev, &priv->napi))) {
-			__netif_rx_schedule(ndev, &priv->napi);
+		if (likely(netif_rx_schedule_prep(&priv->napi))) {
+			__netif_rx_schedule(&priv->napi);
 			RET(IRQ_HANDLED);
 		} else {
 			/* NOTE: we get here if intr has slipped into window
@@ -289,7 +289,6 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 static int bdx_poll(struct napi_struct *napi, int budget)
 {
 	struct bdx_priv *priv = container_of(napi, struct bdx_priv, napi);
-	struct net_device *dev = priv->ndev;
 	int work_done;
 
 	ENTER;
@@ -303,7 +302,7 @@ static int bdx_poll(struct napi_struct *napi, int budget)
 		 * device lock and allow waiting tasks (eg rmmod) to advance) */
 		priv->napi_stop = 0;
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		bdx_enable_interrupts(priv);
 	}
 	return work_done;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 06bd2f4..46a8d93 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4453,7 +4453,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			sblk->status &= ~SD_STATUS_UPDATED;
 
 		if (likely(!tg3_has_work(tp))) {
-			netif_rx_complete(tp->dev, napi);
+			netif_rx_complete(napi);
 			tg3_restart_ints(tp);
 			break;
 		}
@@ -4463,7 +4463,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 
 tx_recovery:
 	/* work_done is guaranteed to be less than budget. */
-	netif_rx_complete(tp->dev, napi);
+	netif_rx_complete(napi);
 	schedule_work(&tp->reset_task);
 	return work_done;
 }
@@ -4512,7 +4512,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -4537,7 +4537,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 
 	return IRQ_RETVAL(1);
 }
@@ -4579,7 +4579,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -4625,7 +4625,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (netif_rx_schedule_prep(dev, &tp->napi)) {
+	if (netif_rx_schedule_prep(&tp->napi)) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		/* Update last_tag to mark that this status has been
 		 * seen. Because interrupt may be shared, we may be
@@ -4633,7 +4633,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 		 * if tg3_poll() is not scheduled.
 		 */
 		tp->last_tag = sblk->status_tag;
-		__netif_rx_schedule(dev, &tp->napi);
+		__netif_rx_schedule(&tp->napi);
 	}
 out:
 	return IRQ_RETVAL(handled);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 271bc23..75461db 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -888,7 +888,7 @@ static int tsi108_poll(struct napi_struct *napi, int budget)
 
 	if (num_received < budget) {
 		data->rxpending = 0;
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		TSI_WRITE(TSI108_EC_INTMASK,
 				     TSI_READ(TSI108_EC_INTMASK)
@@ -919,7 +919,7 @@ static void tsi108_rx_int(struct net_device *dev)
 	 * from tsi108_check_rxring().
 	 */
 
-	if (netif_rx_schedule_prep(dev, &data->napi)) {
+	if (netif_rx_schedule_prep(&data->napi)) {
 		/* Mask, rather than ack, the receive interrupts.  The ack
 		 * will happen in tsi108_poll().
 		 */
@@ -930,7 +930,7 @@ static void tsi108_rx_int(struct net_device *dev)
 				     | TSI108_INT_RXTHRESH |
 				     TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR |
 				     TSI108_INT_RXWAIT);
-		__netif_rx_schedule(dev, &data->napi);
+		__netif_rx_schedule(&data->napi);
 	} else {
 		if (!netif_running(dev)) {
 			/* This can happen if an interrupt occurs while the
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 739d610..6c3428a 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -103,7 +103,7 @@ void oom_timer(unsigned long data)
 {
         struct net_device *dev = (struct net_device *)data;
 	struct tulip_private *tp = netdev_priv(dev);
-	netif_rx_schedule(dev, &tp->napi);
+	netif_rx_schedule(&tp->napi);
 }
 
 int tulip_poll(struct napi_struct *napi, int budget)
@@ -300,7 +300,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
          /* Remove us from polling list and enable RX intr. */
 
-         netif_rx_complete(dev, napi);
+         netif_rx_complete(napi);
          iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+CSR7);
 
          /* The last op happens after poll completion. Which means the following:
@@ -336,7 +336,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
           * before we did netif_rx_complete(). See? We would lose it. */
 
          /* remove ourselves from the polling list */
-         netif_rx_complete(dev, napi);
+         netif_rx_complete(napi);
 
          return work_done;
 }
@@ -519,7 +519,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 			rxd++;
 			/* Mask RX intrs and add the device to poll list. */
 			iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + CSR7);
-			netif_rx_schedule(dev, &tp->napi);
+			netif_rx_schedule(&tp->napi);
 
 			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
                                break;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 5386d9b..0009f4e 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1755,7 +1755,6 @@ static int
 typhoon_poll(struct napi_struct *napi, int budget)
 {
 	struct typhoon *tp = container_of(napi, struct typhoon, napi);
-	struct net_device *dev = tp->dev;
 	struct typhoon_indexes *indexes = tp->indexes;
 	int work_done;
 
@@ -1784,7 +1783,7 @@ typhoon_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
@@ -1807,10 +1806,10 @@ typhoon_interrupt(int irq, void *dev_instance)
 
 	iowrite32(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
 
-	if (netif_rx_schedule_prep(dev, &tp->napi)) {
+	if (netif_rx_schedule_prep(&tp->napi)) {
 		iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(ioaddr);
-		__netif_rx_schedule(dev, &tp->napi);
+		__netif_rx_schedule(&tp->napi);
 	} else {
 		printk(KERN_ERR "%s: Error, poll already scheduled\n",
                        dev->name);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 0a5b817..83c3345 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3590,7 +3590,7 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 		struct ucc_fast_private *uccf;
 		u32 uccm;
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		uccf = ugeth->uccf;
 		uccm = in_be32(uccf->p_uccm);
 		uccm |= UCCE_RX_EVENTS;
@@ -3624,10 +3624,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
-		if (netif_rx_schedule_prep(dev, &ugeth->napi)) {
+		if (netif_rx_schedule_prep(&ugeth->napi)) {
 			uccm &= ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
-			__netif_rx_schedule(dev, &ugeth->napi);
+			__netif_rx_schedule(&ugeth->napi);
 		}
 	}
 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8d405c8..ac07cc6 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -589,7 +589,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 	work_done = rhine_rx(dev, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1318,7 +1318,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
 
-			netif_rx_schedule(dev, &rp->napi);
+			netif_rx_schedule(&rp->napi);
 		}
 
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 71ca29c..b7004ff 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -374,9 +374,9 @@ static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (netif_rx_schedule_prep(vi->dev, &vi->napi)) {
+	if (netif_rx_schedule_prep(&vi->napi)) {
 		rvq->vq_ops->disable_cb(rvq);
-		__netif_rx_schedule(vi->dev, &vi->napi);
+		__netif_rx_schedule(&vi->napi);
 	}
 }
 
@@ -402,11 +402,11 @@ again:
 
 	/* Out of packets? */
 	if (received < budget) {
-		netif_rx_complete(vi->dev, napi);
+		netif_rx_complete(napi);
 		if (unlikely(!vi->rvq->vq_ops->enable_cb(vi->rvq))
 		    && napi_schedule_prep(napi)) {
 			vi->rvq->vq_ops->disable_cb(vi->rvq);
-			__netif_rx_schedule(vi->dev, napi);
+			__netif_rx_schedule(napi);
 			goto again;
 		}
 	}
@@ -580,9 +580,9 @@ static int virtnet_open(struct net_device *dev)
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (netif_rx_schedule_prep(dev, &vi->napi)) {
+	if (netif_rx_schedule_prep(&vi->napi)) {
 		vi->rvq->vq_ops->disable_cb(vi->rvq);
-		__netif_rx_schedule(dev, &vi->napi);
+		__netif_rx_schedule(&vi->napi);
 	}
 	return 0;
 }
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index 0bcc0b5..08b3536 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -341,7 +341,7 @@ static int sca_poll(struct napi_struct *napi, int budget)
 		received = sca_rx_done(port, budget);
 
 	if (received < budget) {
-		netif_rx_complete(port->netdev, napi);
+		netif_rx_complete(napi);
 		enable_intr(port);
 	}
 
@@ -359,7 +359,7 @@ static irqreturn_t sca_intr(int irq, void *dev_id)
 		if (port && (isr0 & (i ? 0x08002200 : 0x00080022))) {
 			handled = 1;
 			disable_intr(port);
-			netif_rx_schedule(port->netdev, &port->napi);
+			netif_rx_schedule(&port->napi);
 		}
 	}
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index fe376fd..761635b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -196,7 +196,7 @@ static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct netfront_info *np = netdev_priv(dev);
-	netif_rx_schedule(dev, &np->napi);
+	netif_rx_schedule(&np->napi);
 }
 
 static int netfront_tx_slot_available(struct netfront_info *np)
@@ -328,7 +328,7 @@ static int xennet_open(struct net_device *dev)
 		xennet_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -979,7 +979,7 @@ err:
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
 		if (!more_to_do)
-			__netif_rx_complete(dev, napi);
+			__netif_rx_complete(napi);
 
 		local_irq_restore(flags);
 	}
@@ -1310,7 +1310,7 @@ static irqreturn_t xennet_interrupt(int irq, void *dev_id)
 		xennet_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 58856b6..41e1224 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1555,8 +1555,7 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 }
 
 /* Test if receive needs to be scheduled but only if up */
-static inline int netif_rx_schedule_prep(struct net_device *dev,
-					 struct napi_struct *napi)
+static inline int netif_rx_schedule_prep(struct napi_struct *napi)
 {
 	return napi_schedule_prep(napi);
 }
@@ -1564,27 +1563,24 @@ static inline int netif_rx_schedule_prep(struct net_device *dev,
 /* Add interface to tail of rx poll list. This assumes that _prep has
  * already been called and returned 1.
  */
-static inline void __netif_rx_schedule(struct net_device *dev,
-				       struct napi_struct *napi)
+static inline void __netif_rx_schedule(struct napi_struct *napi)
 {
 	__napi_schedule(napi);
 }
 
 /* Try to reschedule poll. Called by irq handler. */
 
-static inline void netif_rx_schedule(struct net_device *dev,
-				     struct napi_struct *napi)
+static inline void netif_rx_schedule(struct napi_struct *napi)
 {
-	if (netif_rx_schedule_prep(dev, napi))
-		__netif_rx_schedule(dev, napi);
+	if (netif_rx_schedule_prep(napi))
+		__netif_rx_schedule(napi);
 }
 
 /* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
-static inline int netif_rx_reschedule(struct net_device *dev,
-				      struct napi_struct *napi)
+static inline int netif_rx_reschedule(struct napi_struct *napi)
 {
 	if (napi_schedule_prep(napi)) {
-		__netif_rx_schedule(dev, napi);
+		__netif_rx_schedule(napi);
 		return 1;
 	}
 	return 0;
@@ -1593,8 +1589,7 @@ static inline int netif_rx_reschedule(struct net_device *dev,
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
-static inline void __netif_rx_complete(struct net_device *dev,
-				       struct napi_struct *napi)
+static inline void __netif_rx_complete(struct napi_struct *napi)
 {
 	__napi_complete(napi);
 }
@@ -1604,8 +1599,7 @@ static inline void __netif_rx_complete(struct net_device *dev,
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev,
-				     struct napi_struct *napi)
+static inline void netif_rx_complete(struct napi_struct *napi)
 {
 	napi_complete(napi);
 }
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
