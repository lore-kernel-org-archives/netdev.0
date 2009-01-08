From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Remove redundant NAPI functions
Date: Thu, 08 Jan 2009 20:30:10 +0000
Message-ID: <1231446610.3893.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:57351 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751570AbZAHUaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:30:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ollowing the removal of the unused struct net_device * parameter fro=
m
the NAPI functions named *netif_rx_* in commit 908a7a1, they are
exactly equivalent to the corresponding *napi_* functions and are
therefore redundant.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
=EF=BB=BFNeil Horman <nhorman@tuxdriver.com> wrote
re: [PATCH] netpoll: fix race on poll_list resulting in garbage entry:
> On Wed, Dec 17, 2008 at 07:29:36PM -0800, David Miller wrote:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Wed, 17 Dec 2008 20:13:06 -0500
> >=20
> > > Ok, here you go, one omnibus patch
> >=20
> > This doesn't apply to net-next-2.6, not even by a country mile.
> > :-)
> >=20
> > Please respin this, thanks.
>=20
>=20
> Respun, and diffeed against the head of net-next-2.6.git
>=20
> Since we migrated the napi polling infrastructure out of the net_devi=
ce
> structure, the netif_rx_[prep|schedule|complete] api has taken a net_=
device
> structure pointer, which in all cases goes unused.  This patch modifi=
es the api
> to remove that parameter, and fixes up all the required call sites.
[...]

I revisited this to update the out-of-tree version of the sfc driver.
This makes the *netif_rx_* functions equivalent to the corresponding
*napi_* functions.  So let's finish the job.  This is another search-
and-replace, mostly compile-tested.

Ben.

 drivers/infiniband/hw/nes/nes_hw.c      |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c     |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    6 ++--
 drivers/net/8139cp.c                    |    6 ++--
 drivers/net/8139too.c                   |    6 ++--
 drivers/net/amd8111e.c                  |    6 ++--
 drivers/net/arm/ep93xx_eth.c            |    8 ++--
 drivers/net/arm/ixp4xx_eth.c            |   12 ++++----
 drivers/net/atl1e/atl1e_main.c          |    6 ++--
 drivers/net/b44.c                       |    6 ++--
 drivers/net/bnx2.c                      |   12 ++++----
 drivers/net/bnx2x_main.c                |    6 ++--
 drivers/net/cassini.c                   |    8 ++--
 drivers/net/chelsio/sge.c               |    4 +-
 drivers/net/cpmac.c                     |   10 +++---
 drivers/net/e100.c                      |    6 ++--
 drivers/net/e1000/e1000_main.c          |   10 +++---
 drivers/net/e1000e/netdev.c             |   14 ++++----
 drivers/net/ehea/ehea_main.c            |    8 ++--
 drivers/net/enic/enic_main.c            |   12 ++++----
 drivers/net/epic100.c                   |    6 ++--
 drivers/net/forcedeth.c                 |   10 +++---
 drivers/net/fs_enet/fs_enet-main.c      |    4 +-
 drivers/net/gianfar.c                   |    6 ++--
 drivers/net/ibmveth.c                   |    8 ++--
 drivers/net/igb/igb_main.c              |   12 ++++----
 drivers/net/ixgb/ixgb_main.c            |    6 ++--
 drivers/net/ixgbe/ixgbe_main.c          |   12 ++++----
 drivers/net/ixp2000/ixpdev.c            |    4 +-
 drivers/net/jme.h                       |    6 ++--
 drivers/net/korina.c                    |    4 +-
 drivers/net/macb.c                      |   10 +++---
 drivers/net/mlx4/en_rx.c                |    4 +-
 drivers/net/myri10ge/myri10ge.c         |    6 ++--
 drivers/net/natsemi.c                   |    6 ++--
 drivers/net/netxen/netxen_nic_main.c    |    2 +-
 drivers/net/niu.c                       |    6 ++--
 drivers/net/pasemi_mac.c                |    6 ++--
 drivers/net/pcnet32.c                   |    6 ++--
 drivers/net/qla3xxx.c                   |    6 ++--
 drivers/net/qlge/qlge_main.c            |    6 ++--
 drivers/net/r6040.c                     |    4 +-
 drivers/net/r8169.c                     |    6 ++--
 drivers/net/s2io.c                      |    8 ++--
 drivers/net/sb1250-mac.c                |    6 ++--
 drivers/net/sfc/efx.c                   |    4 +-
 drivers/net/sfc/efx.h                   |    2 +-
 drivers/net/skge.c                      |    6 ++--
 drivers/net/smsc911x.c                  |    8 ++--
 drivers/net/smsc9420.c                  |    4 +-
 drivers/net/spider_net.c                |   12 ++++----
 drivers/net/starfire.c                  |    6 ++--
 drivers/net/sungem.c                    |    6 ++--
 drivers/net/tc35815.c                   |    6 ++--
 drivers/net/tehuti.c                    |    6 ++--
 drivers/net/tg3.c                       |   14 ++++----
 drivers/net/tsi108_eth.c                |    8 ++--
 drivers/net/tulip/interrupt.c           |   10 +++---
 drivers/net/typhoon.c                   |    6 ++--
 drivers/net/ucc_geth.c                  |    6 ++--
 drivers/net/via-rhine.c                 |    4 +-
 drivers/net/virtio_net.c                |   12 ++++----
 drivers/net/wan/hd64572.c               |    4 +-
 drivers/net/wan/ixp4xx_hss.c            |   12 ++++----
 drivers/net/xen-netfront.c              |    8 ++--
 include/linux/netdevice.h               |   50 -----------------------=
--------
 66 files changed, 227 insertions(+), 277 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw=
/nes/nes_hw.c
index 5d139db..53df9de 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2541,7 +2541,7 @@ static void nes_nic_napi_ce_handler(struct nes_de=
vice *nesdev, struct nes_hw_nic
 {
 	struct nes_vnic *nesvnic =3D container_of(cq, struct nes_vnic, nic_cq=
);
=20
-	netif_rx_schedule(&nesvnic->napi);
+	napi_schedule(&nesvnic->napi);
 }
=20

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index 57a47cf..f5484ad 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -111,7 +111,7 @@ static int nes_netdev_poll(struct napi_struct *napi=
, int budget)
 	nes_nic_ce_handler(nesdev, nescq);
=20
 	if (nescq->cqes_pending =3D=3D 0) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		/* clear out completed cqes and arm */
 		nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_NOTIFY_NEXT |
 				nescq->cq_number | (nescq->cqe_allocs_pending << 16));
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_ib.c
index a192581..da60827 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -446,11 +446,11 @@ poll_more:
 		if (dev->features & NETIF_F_LRO)
 			lro_flush_all(&priv->lro.lro_mgr);
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (unlikely(ib_req_notify_cq(priv->recv_cq,
 					      IB_CQ_NEXT_COMP |
 					      IB_CQ_REPORT_MISSED_EVENTS)) &&
-		    netif_rx_reschedule(napi))
+		    napi_reschedule(napi))
 			goto poll_more;
 	}
=20
@@ -462,7 +462,7 @@ void ipoib_ib_completion(struct ib_cq *cq, void *de=
v_ptr)
 	struct net_device *dev =3D dev_ptr;
 	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
=20
-	netif_rx_schedule(&priv->napi);
+	napi_schedule(&priv->napi);
 }
=20
 static void drain_tx_cq(struct net_device *dev)
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index dd7ac82..7bad249 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -604,7 +604,7 @@ rx_next:
=20
 		spin_lock_irqsave(&cp->lock, flags);
 		cpw16_f(IntrMask, cp_intr_mask);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
=20
@@ -641,9 +641,9 @@ static irqreturn_t cp_interrupt (int irq, void *dev=
_instance)
 	}
=20
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
-		if (netif_rx_schedule_prep(&cp->napi)) {
+		if (napi_schedule_prep(&cp->napi)) {
 			cpw16_f(IntrMask, cp_norx_intr_mask);
-			__netif_rx_schedule(&cp->napi);
+			__napi_schedule(&cp->napi);
 		}
=20
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index fe370f8..16c1054 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2128,7 +2128,7 @@ static int rtl8139_poll(struct napi_struct *napi,=
 int budget)
 		 */
 		spin_lock_irqsave(&tp->lock, flags);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 	spin_unlock(&tp->rx_lock);
@@ -2178,9 +2178,9 @@ static irqreturn_t rtl8139_interrupt (int irq, vo=
id *dev_instance)
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
 	if (status & RxAckBits){
-		if (netif_rx_schedule_prep(&tp->napi)) {
+		if (napi_schedule_prep(&tp->napi)) {
 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
-			__netif_rx_schedule(&tp->napi);
+			__napi_schedule(&tp->napi);
 		}
 	}
=20
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 187ac6e..87ae8c0 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -831,7 +831,7 @@ static int amd8111e_rx_poll(struct napi_struct *nap=
i, int budget)
 	if (rx_pkt_limit > 0) {
 		/* Receive descriptor is empty now */
 		spin_lock_irqsave(&lp->lock, flags);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		writel(VAL0|RINTEN0, mmio + INTEN0);
 		writel(VAL2 | RDMD0, mmio + CMD0);
 		spin_unlock_irqrestore(&lp->lock, flags);
@@ -1170,11 +1170,11 @@ static irqreturn_t amd8111e_interrupt(int irq, =
void *dev_id)
=20
 	/* Check if Receive Interrupt has occurred. */
 	if (intr0 & RINT0) {
-		if (netif_rx_schedule_prep(&lp->napi)) {
+		if (napi_schedule_prep(&lp->napi)) {
 			/* Disable receive interupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
-			__netif_rx_schedule(&lp->napi);
+			__napi_schedule(&lp->napi);
 		} else if (intren0 & RINTEN0) {
 			printk("************Driver bug! \
 				interrupt while in poll\n");
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.=
c
index 3ec20cc..cc77087 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -298,7 +298,7 @@ poll_some_more:
 		int more =3D 0;
=20
 		spin_lock_irq(&ep->rx_lock);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
 		if (ep93xx_have_more_rx(ep)) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
@@ -307,7 +307,7 @@ poll_some_more:
 		}
 		spin_unlock_irq(&ep->rx_lock);
=20
-		if (more && netif_rx_reschedule(napi))
+		if (more && napi_reschedule(napi))
 			goto poll_some_more;
 	}
=20
@@ -415,9 +415,9 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id=
)
=20
 	if (status & REG_INTSTS_RX) {
 		spin_lock(&ep->rx_lock);
-		if (likely(netif_rx_schedule_prep(&ep->napi))) {
+		if (likely(napi_schedule_prep(&ep->napi))) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
-			__netif_rx_schedule(&ep->napi);
+			__napi_schedule(&ep->napi);
 		}
 		spin_unlock(&ep->rx_lock);
 	}
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.=
c
index 5fce1d5..5fe17d5 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -473,7 +473,7 @@ static void eth_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: eth_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(port->plat->rxq);
-	netif_rx_schedule(&port->napi);
+	napi_schedule(&port->napi);
 }
=20
 static int eth_poll(struct napi_struct *napi, int budget)
@@ -498,16 +498,16 @@ static int eth_poll(struct napi_struct *napi, int=
 budget)
=20
 		if ((n =3D queue_get_desc(rxq, port, 0)) < 0) {
 #if DEBUG_RX
-			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
+			printk(KERN_DEBUG "%s: eth_poll napi_complete\n",
 			       dev->name);
 #endif
-			netif_rx_complete(napi);
+			napi_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
-			    netif_rx_reschedule(napi)) {
+			    napi_reschedule(napi)) {
 #if DEBUG_RX
 				printk(KERN_DEBUG "%s: eth_poll"
-				       " netif_rx_reschedule successed\n",
+				       " napi_reschedule successed\n",
 				       dev->name);
 #endif
 				qmgr_disable_irq(rxq);
@@ -1036,7 +1036,7 @@ static int eth_open(struct net_device *dev)
 	}
 	ports_open++;
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(&port->napi);
+	napi_schedule(&port->napi);
 	return 0;
 }
=20
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index bb9094d..c758884 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1326,9 +1326,9 @@ static irqreturn_t atl1e_intr(int irq, void *data=
)
 			AT_WRITE_REG(hw, REG_IMR,
 				     IMR_NORMAL_MASK & ~ISR_RX_EVENT);
 			AT_WRITE_FLUSH(hw);
-			if (likely(netif_rx_schedule_prep(
+			if (likely(napi_schedule_prep(
 				   &adapter->napi)))
-				__netif_rx_schedule(&adapter->napi);
+				__napi_schedule(&adapter->napi);
 		}
 	} while (--max_ints > 0);
 	/* re-enable Interrupt*/
@@ -1514,7 +1514,7 @@ static int atl1e_clean(struct napi_struct *napi, =
int budget)
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if (work_done < budget) {
 quit_polling:
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		imr_data =3D AT_READ_REG(&adapter->hw, REG_IMR);
 		AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT);
 		/* test debug */
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 0e7470a..44b7ee6 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -874,7 +874,7 @@ static int b44_poll(struct napi_struct *napi, int b=
udget)
 	}
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		b44_enable_ints(bp);
 	}
=20
@@ -906,13 +906,13 @@ static irqreturn_t b44_interrupt(int irq, void *d=
ev_id)
 			goto irq_ack;
 		}
=20
-		if (netif_rx_schedule_prep(&bp->napi)) {
+		if (napi_schedule_prep(&bp->napi)) {
 			/* NOTE: These writes are posted by the readback of
 			 *       the ISTAT register below.
 			 */
 			bp->istat =3D istat;
 			__b44_disable_ints(bp);
-			__netif_rx_schedule(&bp->napi);
+			__napi_schedule(&bp->napi);
 		} else {
 			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
 			       dev->name);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d4a3dac..e817802 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3053,7 +3053,7 @@ bnx2_msi(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) !=3D 0))
 		return IRQ_HANDLED;
=20
-	netif_rx_schedule(&bnapi->napi);
+	napi_schedule(&bnapi->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -3070,7 +3070,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) !=3D 0))
 		return IRQ_HANDLED;
=20
-	netif_rx_schedule(&bnapi->napi);
+	napi_schedule(&bnapi->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -3106,9 +3106,9 @@ bnx2_interrupt(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) !=3D 0))
 		return IRQ_HANDLED;
=20
-	if (netif_rx_schedule_prep(&bnapi->napi)) {
+	if (napi_schedule_prep(&bnapi->napi)) {
 		bnapi->last_status_idx =3D sblk->status_idx;
-		__netif_rx_schedule(&bnapi->napi);
+		__napi_schedule(&bnapi->napi);
 	}
=20
 	return IRQ_HANDLED;
@@ -3218,7 +3218,7 @@ static int bnx2_poll_msix(struct napi_struct *nap=
i, int budget)
 		rmb();
 		if (likely(!bnx2_has_fast_work(bnapi))) {
=20
-			netif_rx_complete(napi);
+			napi_complete(napi);
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 			       bnapi->last_status_idx);
@@ -3251,7 +3251,7 @@ static int bnx2_poll(struct napi_struct *napi, in=
t budget)
=20
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
-			netif_rx_complete(napi);
+			napi_complete(napi);
 			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
 				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ef8103b..eda58ce 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1614,7 +1614,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, voi=
d *fp_cookie)
 	prefetch(&fp->status_blk->c_status_block.status_block_index);
 	prefetch(&fp->status_blk->u_status_block.status_block_index);
=20
-	netif_rx_schedule(&bnx2x_fp(bp, index, napi));
+	napi_schedule(&bnx2x_fp(bp, index, napi));
=20
 	return IRQ_HANDLED;
 }
@@ -1653,7 +1653,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void =
*dev_instance)
 		prefetch(&fp->status_blk->c_status_block.status_block_index);
 		prefetch(&fp->status_blk->u_status_block.status_block_index);
=20
-		netif_rx_schedule(&bnx2x_fp(bp, 0, napi));
+		napi_schedule(&bnx2x_fp(bp, 0, napi));
=20
 		status &=3D ~mask;
 	}
@@ -9283,7 +9283,7 @@ static int bnx2x_poll(struct napi_struct *napi, i=
nt budget)
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 321f43d..30e3547 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2506,7 +2506,7 @@ static irqreturn_t cas_interruptN(int irq, void *=
dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(&cp->napi);
+		napi_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, ring, 0);
 #endif
@@ -2557,7 +2557,7 @@ static irqreturn_t cas_interrupt1(int irq, void *=
dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(&cp->napi);
+		napi_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 1, 0);
 #endif
@@ -2613,7 +2613,7 @@ static irqreturn_t cas_interrupt(int irq, void *d=
ev_id)
 	if (status & INTR_RX_DONE) {
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(&cp->napi);
+		napi_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 0, 0);
 #endif
@@ -2691,7 +2691,7 @@ rx_comp:
 #endif
 	spin_unlock_irqrestore(&cp->lock, flags);
 	if (enable_intr) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		cas_unmask_intr(cp);
 	}
 	return credits;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index d984b79..840da83 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1612,7 +1612,7 @@ int t1_poll(struct napi_struct *napi, int budget)
 	int work_done =3D process_responses(adapter, budget);
=20
 	if (likely(work_done < budget)) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
 	}
@@ -1630,7 +1630,7 @@ irqreturn_t t1_interrupt(int irq, void *data)
=20
 		if (napi_schedule_prep(&adapter->napi)) {
 			if (process_pure_responses(adapter))
-				__netif_rx_schedule(&adapter->napi);
+				__napi_schedule(&adapter->napi);
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index f665487..4dad04e 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -428,7 +428,7 @@ static int cpmac_poll(struct napi_struct *napi, int=
 budget)
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
 			       priv->dev->name);
 		spin_unlock(&priv->rx_lock);
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		return 0;
 	}
=20
@@ -514,7 +514,7 @@ static int cpmac_poll(struct napi_struct *napi, int=
 budget)
 	if (processed =3D=3D 0) {
 		/* we ran out of packets to read,
 		 * revert to interrupt-driven mode */
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
 	}
@@ -536,7 +536,7 @@ fatal_error:
 	}
=20
 	spin_unlock(&priv->rx_lock);
-	netif_rx_complete(napi);
+	napi_complete(napi);
 	netif_tx_stop_all_queues(priv->dev);
 	napi_disable(&priv->napi);
=20
@@ -802,9 +802,9 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
=20
 	if (status & MAC_INT_RX) {
 		queue =3D (status >> 8) & 7;
-		if (netif_rx_schedule_prep(&priv->napi)) {
+		if (napi_schedule_prep(&priv->napi)) {
 			cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
-			__netif_rx_schedule(&priv->napi);
+			__napi_schedule(&priv->napi);
 		}
 	}
=20
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 134b2d6..d9fa445 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2049,9 +2049,9 @@ static irqreturn_t e100_intr(int irq, void *dev_i=
d)
 	if (stat_ack & stat_ack_rnr)
 		nic->ru_running =3D RU_SUSPENDED;
=20
-	if (likely(netif_rx_schedule_prep(&nic->napi))) {
+	if (likely(napi_schedule_prep(&nic->napi))) {
 		e100_disable_irq(nic);
-		__netif_rx_schedule(&nic->napi);
+		__napi_schedule(&nic->napi);
 	}
=20
 	return IRQ_HANDLED;
@@ -2067,7 +2067,7 @@ static int e100_poll(struct napi_struct *napi, in=
t budget)
=20
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		e100_enable_irq(nic);
 	}
=20
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 26474c9..ffe466e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3687,12 +3687,12 @@ static irqreturn_t e1000_intr_msi(int irq, void=
 *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
=20
-	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
+	if (likely(napi_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes =3D 0;
 		adapter->total_tx_packets =3D 0;
 		adapter->total_rx_bytes =3D 0;
 		adapter->total_rx_packets =3D 0;
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
=20
@@ -3747,12 +3747,12 @@ static irqreturn_t e1000_intr(int irq, void *da=
ta)
 		ew32(IMC, ~0);
 		E1000_WRITE_FLUSH();
 	}
-	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
+	if (likely(napi_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes =3D 0;
 		adapter->total_tx_packets =3D 0;
 		adapter->total_rx_bytes =3D 0;
 		adapter->total_rx_packets =3D 0;
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
@@ -3793,7 +3793,7 @@ static int e1000_clean(struct napi_struct *napi, =
int budget)
 	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		e1000_irq_enable(adapter);
 	}
=20
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d4639fa..9e7529e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1179,12 +1179,12 @@ static irqreturn_t e1000_intr_msi(int irq, void=
 *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
=20
-	if (netif_rx_schedule_prep(&adapter->napi)) {
+	if (napi_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes =3D 0;
 		adapter->total_tx_packets =3D 0;
 		adapter->total_rx_bytes =3D 0;
 		adapter->total_rx_packets =3D 0;
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	}
=20
 	return IRQ_HANDLED;
@@ -1246,12 +1246,12 @@ static irqreturn_t e1000_intr(int irq, void *da=
ta)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
=20
-	if (netif_rx_schedule_prep(&adapter->napi)) {
+	if (napi_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes =3D 0;
 		adapter->total_tx_packets =3D 0;
 		adapter->total_rx_bytes =3D 0;
 		adapter->total_rx_packets =3D 0;
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	}
=20
 	return IRQ_HANDLED;
@@ -1320,10 +1320,10 @@ static irqreturn_t e1000_intr_msix_rx(int irq, =
void *data)
 		adapter->rx_ring->set_itr =3D 0;
 	}
=20
-	if (netif_rx_schedule_prep(&adapter->napi)) {
+	if (napi_schedule_prep(&adapter->napi)) {
 		adapter->total_rx_bytes =3D 0;
 		adapter->total_rx_packets =3D 0;
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -2028,7 +2028,7 @@ clean_rx:
 	if (work_done < budget) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (adapter->msix_entries)
 			ew32(IMS, adapter->rx_ring->ims_val);
 		else
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index a2f1905..109f90f 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -830,7 +830,7 @@ static int ehea_poll(struct napi_struct *napi, int =
budget)
 	while ((rx !=3D budget) || force_irq) {
 		pr->poll_counter =3D 0;
 		force_irq =3D 0;
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
@@ -841,7 +841,7 @@ static int ehea_poll(struct napi_struct *napi, int =
budget)
 		if (!cqe && !cqe_skb)
 			return rx;
=20
-		if (!netif_rx_reschedule(napi))
+		if (!napi_reschedule(napi))
 			return rx;
=20
 		cqe_skb =3D ehea_proc_cqes(pr, EHEA_POLL_MAX_CQES);
@@ -859,7 +859,7 @@ static void ehea_netpoll(struct net_device *dev)
 	int i;
=20
 	for (i =3D 0; i < port->num_def_qps; i++)
-		netif_rx_schedule(&port->port_res[i].napi);
+		napi_schedule(&port->port_res[i].napi);
 }
 #endif
=20
@@ -867,7 +867,7 @@ static irqreturn_t ehea_recv_irq_handler(int irq, v=
oid *param)
 {
 	struct ehea_port_res *pr =3D param;
=20
-	netif_rx_schedule(&pr->napi);
+	napi_schedule(&pr->napi);
=20
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index d039e16..46d0252 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -411,8 +411,8 @@ static irqreturn_t enic_isr_legacy(int irq, void *d=
ata)
 	}
=20
 	if (ENIC_TEST_INTR(pba, ENIC_INTX_WQ_RQ)) {
-		if (netif_rx_schedule_prep(&enic->napi))
-			__netif_rx_schedule(&enic->napi);
+		if (napi_schedule_prep(&enic->napi))
+			__napi_schedule(&enic->napi);
 	} else {
 		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
 	}
@@ -440,7 +440,7 @@ static irqreturn_t enic_isr_msi(int irq, void *data=
)
 	 * writes).
 	 */
=20
-	netif_rx_schedule(&enic->napi);
+	napi_schedule(&enic->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -450,7 +450,7 @@ static irqreturn_t enic_isr_msix_rq(int irq, void *=
data)
 	struct enic *enic =3D data;
=20
 	/* schedule NAPI polling for RQ cleanup */
-	netif_rx_schedule(&enic->napi);
+	napi_schedule(&enic->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -1068,7 +1068,7 @@ static int enic_poll(struct napi_struct *napi, in=
t budget)
 		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
=20
@@ -1112,7 +1112,7 @@ static int enic_poll_msix(struct napi_struct *nap=
i, int budget)
 		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
=20
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index f9b37c8..0506f62 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1109,9 +1109,9 @@ static irqreturn_t epic_interrupt(int irq, void *=
dev_instance)
=20
 	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
 		spin_lock(&ep->napi_lock);
-		if (netif_rx_schedule_prep(&ep->napi)) {
+		if (napi_schedule_prep(&ep->napi)) {
 			epic_napi_irq_off(dev, ep);
-			__netif_rx_schedule(&ep->napi);
+			__napi_schedule(&ep->napi);
 		} else
 			ep->reschedule_in_poll++;
 		spin_unlock(&ep->napi_lock);
@@ -1288,7 +1288,7 @@ rx_action:
=20
 		more =3D ep->reschedule_in_poll;
 		if (!more) {
-			__netif_rx_complete(napi);
+			__napi_complete(napi);
 			outl(EpicNapiEvent, ioaddr + INTSTAT);
 			epic_napi_irq_on(dev, ep);
 		} else
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 5b68dc2..71e7fa2 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1760,7 +1760,7 @@ static void nv_do_rx_refill(unsigned long data)
 	struct fe_priv *np =3D netdev_priv(dev);
=20
 	/* Just reschedule NAPI rx processing */
-	netif_rx_schedule(&np->napi);
+	napi_schedule(&np->napi);
 }
 #else
 static void nv_do_rx_refill(unsigned long data)
@@ -3403,7 +3403,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data=
)
=20
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(&np->napi);
+			napi_schedule(&np->napi);
=20
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3520,7 +3520,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, =
void *data)
=20
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(&np->napi);
+			napi_schedule(&np->napi);
=20
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3678,7 +3678,7 @@ static int nv_napi_poll(struct napi_struct *napi,=
 int budget)
 		/* re-enable receive interrupts */
 		spin_lock_irqsave(&np->lock, flags);
=20
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
=20
 		np->irqmask |=3D NVREG_IRQ_RX_ALL;
 		if (np->msi_flags & NV_MSI_X_ENABLED)
@@ -3704,7 +3704,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *d=
ata)
 	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
=20
 	if (events) {
-		netif_rx_schedule(&np->napi);
+		napi_schedule(&np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/f=
s_enet-main.c
index 4e6a919..fac4915 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -209,7 +209,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi=
, int budget)
=20
 	if (received < budget) {
 		/* done */
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		(*fep->ops->napi_enable_rx)(dev);
 	}
 	return received;
@@ -478,7 +478,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 				/* NOTE: it is possible for FCCs in NAPI mode    */
 				/* to submit a spurious interrupt while in poll  */
 				if (napi_ok)
-					__netif_rx_schedule(&fep->napi);
+					__napi_schedule(&fep->napi);
 			}
 		}
=20
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c672ecf..f35e6c4 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1607,9 +1607,9 @@ static int gfar_clean_tx_ring(struct net_device *=
dev)
 static void gfar_schedule_cleanup(struct net_device *dev)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
-	if (netif_rx_schedule_prep(&priv->napi)) {
+	if (napi_schedule_prep(&priv->napi)) {
 		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
-		__netif_rx_schedule(&priv->napi);
+		__napi_schedule(&priv->napi);
 	}
 }
=20
@@ -1863,7 +1863,7 @@ static int gfar_poll(struct napi_struct *napi, in=
t budget)
 		return budget;
=20
 	if (rx_cleaned < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 9bc0f17..f4e93be 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1028,10 +1028,10 @@ static int ibmveth_poll(struct napi_struct *nap=
i, int budget)
=20
 		ibmveth_assert(lpar_rc =3D=3D H_SUCCESS);
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		if (ibmveth_rxq_pending_buffer(adapter) &&
-		    netif_rx_reschedule(napi)) {
+		    napi_reschedule(napi)) {
 			lpar_rc =3D h_vio_signal(adapter->vdev->unit_address,
 					       VIO_IRQ_DISABLE);
 			goto restart_poll;
@@ -1047,11 +1047,11 @@ static irqreturn_t ibmveth_interrupt(int irq, v=
oid *dev_instance)
 	struct ibmveth_adapter *adapter =3D netdev_priv(netdev);
 	unsigned long lpar_rc;
=20
-	if (netif_rx_schedule_prep(&adapter->napi)) {
+	if (napi_schedule_prep(&adapter->napi)) {
 		lpar_rc =3D h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_DISABLE);
 		ibmveth_assert(lpar_rc =3D=3D H_SUCCESS);
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 022794e..47e7f81 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3386,8 +3386,8 @@ static irqreturn_t igb_msix_rx(int irq, void *dat=
a)
=20
 	igb_write_itr(rx_ring);
=20
-	if (netif_rx_schedule_prep(&rx_ring->napi))
-		__netif_rx_schedule(&rx_ring->napi);
+	if (napi_schedule_prep(&rx_ring->napi))
+		__napi_schedule(&rx_ring->napi);
=20
 #ifdef CONFIG_IGB_DCA
 	if (rx_ring->adapter->flags & IGB_FLAG_DCA_ENABLED)
@@ -3539,7 +3539,7 @@ static irqreturn_t igb_intr_msi(int irq, void *da=
ta)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
=20
-	netif_rx_schedule(&adapter->rx_ring[0].napi);
+	napi_schedule(&adapter->rx_ring[0].napi);
=20
 	return IRQ_HANDLED;
 }
@@ -3577,7 +3577,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
=20
-	netif_rx_schedule(&adapter->rx_ring[0].napi);
+	napi_schedule(&adapter->rx_ring[0].napi);
=20
 	return IRQ_HANDLED;
 }
@@ -3612,7 +3612,7 @@ static int igb_poll(struct napi_struct *napi, int=
 budget)
 	    !netif_running(netdev)) {
 		if (adapter->itr_setting & 3)
 			igb_set_itr(adapter);
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			igb_irq_enable(adapter);
 		return 0;
@@ -3638,7 +3638,7 @@ static int igb_clean_rx_ring_msix(struct napi_str=
uct *napi, int budget)
=20
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done =3D=3D 0) || !netif_running(netdev)) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		if (adapter->itr_setting & 3) {
 			if (adapter->num_rx_queues =3D=3D 1)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index eee28d3..e2ef16b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1721,14 +1721,14 @@ ixgb_intr(int irq, void *data)
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies);
=20
-	if (netif_rx_schedule_prep(&adapter->napi)) {
+	if (napi_schedule_prep(&adapter->napi)) {
=20
 		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
=20
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
-		__netif_rx_schedule(&adapter->napi);
+		__napi_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -1749,7 +1749,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
=20
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index acef3c6..c2cbe91 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1012,7 +1012,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, v=
oid *data)
 	rx_ring =3D &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	netif_rx_schedule(&q_vector->napi);
+	napi_schedule(&q_vector->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -1053,7 +1053,7 @@ static int ixgbe_clean_rxonly(struct napi_struct =
*napi, int budget)
=20
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1102,7 +1102,7 @@ static int ixgbe_clean_rxonly_many(struct napi_st=
ruct *napi, int budget)
 	rx_ring =3D &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1378,13 +1378,13 @@ static irqreturn_t ixgbe_intr(int irq, void *da=
ta)
=20
 	ixgbe_check_fan_failure(adapter, eicr);
=20
-	if (netif_rx_schedule_prep(&adapter->q_vector[0].napi)) {
+	if (napi_schedule_prep(&adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets =3D 0;
 		adapter->tx_ring[0].total_bytes =3D 0;
 		adapter->rx_ring[0].total_packets =3D 0;
 		adapter->rx_ring[0].total_bytes =3D 0;
 		/* would disable interrupts here but EIAM disabled it */
-		__netif_rx_schedule(&adapter->q_vector[0].napi);
+		__napi_schedule(&adapter->q_vector[0].napi);
 	}
=20
 	return IRQ_HANDLED;
@@ -2310,7 +2310,7 @@ static int ixgbe_poll(struct napi_struct *napi, i=
nt budget)
=20
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.=
c
index 0147457..d3bf2f0 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -141,7 +141,7 @@ static int ixpdev_poll(struct napi_struct *napi, in=
t budget)
 			break;
 	} while (ixp2000_reg_read(IXP2000_IRQ_THD_RAW_STATUS_A_0) & 0x00ff);
=20
-	netif_rx_complete(napi);
+	napi_complete(napi);
 	ixp2000_reg_write(IXP2000_IRQ_THD_ENABLE_SET_A_0, 0x00ff);
=20
 	return rx;
@@ -204,7 +204,7 @@ static irqreturn_t ixpdev_interrupt(int irq, void *=
dev_id)
=20
 		ixp2000_reg_wrb(IXP2000_IRQ_THD_ENABLE_CLEAR_A_0, 0x00ff);
 		if (likely(napi_schedule_prep(&ip->napi))) {
-			__netif_rx_schedule(&ip->napi);
+			__napi_schedule(&ip->napi);
 		} else {
 			printk(KERN_CRIT "ixp2000: irq while polling!!\n");
 		}
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 5154411..e321c67 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -398,15 +398,15 @@ struct jme_ring {
 #define JME_NAPI_WEIGHT(w) int w
 #define JME_NAPI_WEIGHT_VAL(w) w
 #define JME_NAPI_WEIGHT_SET(w, r)
-#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(napis)
+#define JME_RX_COMPLETE(dev, napis) napi_complete(napis)
 #define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
 #define JME_NAPI_DISABLE(priv) \
 	if (!napi_disable_pending(&priv->napi)) \
 		napi_disable(&priv->napi);
 #define JME_RX_SCHEDULE_PREP(priv) \
-	netif_rx_schedule_prep(&priv->napi)
+	napi_schedule_prep(&priv->napi)
 #define JME_RX_SCHEDULE(priv) \
-	__netif_rx_schedule(&priv->napi);
+	__napi_schedule(&priv->napi);
=20
 /*
  * Jmac Adapter Private data
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 4a5580c..a7cc096 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -327,7 +327,7 @@ static irqreturn_t korina_rx_dma_interrupt(int irq,=
 void *dev_id)
=20
 	dmas =3D readl(&lp->rx_dma_regs->dmas);
 	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
-		netif_rx_schedule_prep(&lp->napi);
+		napi_schedule_prep(&lp->napi);
=20
 		dmasm =3D readl(&lp->rx_dma_regs->dmasm);
 		writel(dmasm | (DMA_STAT_DONE |
@@ -466,7 +466,7 @@ static int korina_poll(struct napi_struct *napi, in=
t budget)
=20
 	work_done =3D korina_rx(dev, budget);
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		writel(readl(&lp->rx_dma_regs->dmasm) &
 			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a04da4e..89a2a79 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -519,7 +519,7 @@ static int macb_poll(struct napi_struct *napi, int =
budget)
 		 * this function was called last time, and no packets
 		 * have been received since.
 		 */
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		goto out;
 	}
=20
@@ -530,13 +530,13 @@ static int macb_poll(struct napi_struct *napi, in=
t budget)
 		dev_warn(&bp->pdev->dev,
 			 "No RX buffers complete, status =3D %02lx\n",
 			 (unsigned long)status);
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		goto out;
 	}
=20
 	work_done =3D macb_rx(bp, budget);
 	if (work_done < budget)
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 	/*
 	 * We've done what we can to clean the buffers. Make sure we
@@ -571,7 +571,7 @@ static irqreturn_t macb_interrupt(int irq, void *de=
v_id)
 		}
=20
 		if (status & MACB_RX_INT_FLAGS) {
-			if (netif_rx_schedule_prep(&bp->napi)) {
+			if (napi_schedule_prep(&bp->napi)) {
 				/*
 				 * There's no point taking any more interrupts
 				 * until we have processed the buffers
@@ -579,7 +579,7 @@ static irqreturn_t macb_interrupt(int irq, void *de=
v_id)
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
-				__netif_rx_schedule(&bp->napi);
+				__napi_schedule(&bp->napi);
 			}
 		}
=20
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index c61b0bd..ac55ebd 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -814,7 +814,7 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_priv *priv =3D netdev_priv(cq->dev);
=20
 	if (priv->port_up)
-		netif_rx_schedule(&cq->napi);
+		napi_schedule(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
@@ -834,7 +834,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, in=
t budget)
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
 	else {
 		/* Done for now */
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
 	return done;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 5e70180..99bcb98 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1514,7 +1514,7 @@ static int myri10ge_poll(struct napi_struct *napi=
, int budget)
 	work_done =3D myri10ge_clean_rx_done(ss, budget);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
@@ -1532,7 +1532,7 @@ static irqreturn_t myri10ge_intr(int irq, void *a=
rg)
 	/* an interrupt on a non-zero receive-only slice is implicitly
 	 * valid  since MSI-X irqs are not shared */
 	if ((mgp->dev->real_num_tx_queues =3D=3D 1) && (ss !=3D mgp->ss)) {
-		netif_rx_schedule(&ss->napi);
+		napi_schedule(&ss->napi);
 		return (IRQ_HANDLED);
 	}
=20
@@ -1543,7 +1543,7 @@ static irqreturn_t myri10ge_intr(int irq, void *a=
rg)
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(&ss->napi);
+		napi_schedule(&ss->napi);
=20
 	if (!mgp->msi_enabled && !mgp->msix_enabled) {
 		put_be32(0, mgp->irq_deassert);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 478edb9..d8841e0 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2193,10 +2193,10 @@ static irqreturn_t intr_handler(int irq, void *=
dev_instance)
=20
 	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
=20
-	if (netif_rx_schedule_prep(&np->napi)) {
+	if (napi_schedule_prep(&np->napi)) {
 		/* Disable interrupts and register for poll */
 		natsemi_irq_disable(dev);
-		__netif_rx_schedule(&np->napi);
+		__napi_schedule(&np->napi);
 	} else
 		printk(KERN_WARNING
 	       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
@@ -2248,7 +2248,7 @@ static int natsemi_poll(struct napi_struct *napi,=
 int budget)
 		np->intr_status =3D readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
=20
-	netif_rx_complete(napi);
+	napi_complete(napi);
=20
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index ba01524..ee04080 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1583,7 +1583,7 @@ static int netxen_nic_poll(struct napi_struct *na=
pi, int budget)
 	}
=20
 	if ((work_done < budget) && tx_complete) {
-		netif_rx_complete(&adapter->napi);
+		napi_complete(&adapter->napi);
 		netxen_nic_enable_int(adapter);
 	}
=20
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0c0b752..4a5a089 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3669,7 +3669,7 @@ static int niu_poll(struct napi_struct *napi, int=
 budget)
 	work_done =3D niu_poll_core(np, lp, budget);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		niu_ldg_rearm(np, lp, 1);
 	}
 	return work_done;
@@ -4088,12 +4088,12 @@ static void __niu_fastpath_interrupt(struct niu=
 *np, int ldg, u64 v0)
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
-	if (likely(netif_rx_schedule_prep(&lp->napi))) {
+	if (likely(napi_schedule_prep(&lp->napi))) {
 		lp->v0 =3D v0;
 		lp->v1 =3D v1;
 		lp->v2 =3D v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
-		__netif_rx_schedule(&lp->napi);
+		__napi_schedule(&lp->napi);
 	}
 }
=20
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 5b7a574..dbc32de 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -970,7 +970,7 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void=
 *data)
 	if (*chan->status & PAS_STATUS_ERROR)
 		reg |=3D PAS_IOB_DMA_RXCH_RESET_DINTC;
=20
-	netif_rx_schedule(&mac->napi);
+	napi_schedule(&mac->napi);
=20
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(chan->chno), reg);
=20
@@ -1010,7 +1010,7 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, vo=
id *data)
=20
 	mod_timer(&txring->clean_timer, jiffies + (TX_CLEAN_INTERVAL)*2);
=20
-	netif_rx_schedule(&mac->napi);
+	napi_schedule(&mac->napi);
=20
 	if (reg)
 		write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
@@ -1639,7 +1639,7 @@ static int pasemi_mac_poll(struct napi_struct *na=
pi, int budget)
 	pkts =3D pasemi_mac_clean_rx(rx_ring(mac), budget);
 	if (pkts < budget) {
 		/* all done, no more packets present */
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		pasemi_mac_restart_rx_intr(mac);
 		pasemi_mac_restart_tx_intr(mac);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 044b7b0..0d36751 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1397,7 +1397,7 @@ static int pcnet32_poll(struct napi_struct *napi,=
 int budget)
 	if (work_done < budget) {
 		spin_lock_irqsave(&lp->lock, flags);
=20
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
=20
 		/* clear interrupt masks */
 		val =3D lp->a.read_csr(ioaddr, CSR3);
@@ -2586,14 +2586,14 @@ pcnet32_interrupt(int irq, void *dev_id)
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-		if (netif_rx_schedule_prep(&lp->napi)) {
+		if (napi_schedule_prep(&lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
 			val =3D lp->a.read_csr(ioaddr, CSR3);
 			val |=3D 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
 			mmiowb();
-			__netif_rx_schedule(&lp->napi);
+			__napi_schedule(&lp->napi);
 			break;
 		}
 		csr0 =3D lp->a.read_csr(ioaddr, CSR0);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 189ec29..8b2823c 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2292,7 +2292,7 @@ static int ql_poll(struct napi_struct *napi, int =
budget)
=20
 	if (tx_cleaned + rx_cleaned !=3D budget) {
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		ql_update_small_bufq_prod_index(qdev);
 		ql_update_lrg_bufq_prod_index(qdev);
 		writel(qdev->rsp_consumer_index,
@@ -2351,8 +2351,8 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_=
id)
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(&qdev->napi))) {
-			__netif_rx_schedule(&qdev->napi);
+		if (likely(napi_schedule_prep(&qdev->napi))) {
+			__napi_schedule(&qdev->napi);
 		}
 	} else {
 		return IRQ_NONE;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index 837be72..973dc4d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1657,7 +1657,7 @@ static int ql_napi_poll_msix(struct napi_struct *=
napi, int budget)
 		rx_ring->cq_id);
=20
 	if (work_done < budget) {
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
 	}
 	return work_done;
@@ -1742,7 +1742,7 @@ static irqreturn_t qlge_msix_tx_isr(int irq, void=
 *dev_id)
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring =3D dev_id;
-	netif_rx_schedule(&rx_ring->napi);
+	napi_schedule(&rx_ring->napi);
 	return IRQ_HANDLED;
 }
=20
@@ -1828,7 +1828,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id=
)
 							      &rx_ring->rx_work,
 							      0);
 				else
-					netif_rx_schedule(&rx_ring->napi);
+					napi_schedule(&rx_ring->napi);
 				work_done++;
 			}
 		}
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 53bbddf..070ef93 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -667,7 +667,7 @@ static int r6040_poll(struct napi_struct *napi, int=
 budget)
 	work_done =3D r6040_rx(dev, budget);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		/* Enable RX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) | RX_INTS, ioaddr + MIER);
 	}
@@ -704,7 +704,7 @@ static irqreturn_t r6040_interrupt(int irq, void *d=
ev_id)
=20
 		/* Mask off RX interrupt */
 		misr &=3D ~RX_INTS;
-		netif_rx_schedule(&lp->napi);
+		napi_schedule(&lp->napi);
 	}
=20
 	/* TX interrupt request */
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2c73ca6..1c4a980 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3581,8 +3581,8 @@ static irqreturn_t rtl8169_interrupt(int irq, voi=
d *dev_instance)
 		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 		tp->intr_mask =3D ~tp->napi_event;
=20
-		if (likely(netif_rx_schedule_prep(&tp->napi)))
-			__netif_rx_schedule(&tp->napi);
+		if (likely(napi_schedule_prep(&tp->napi)))
+			__napi_schedule(&tp->napi);
 		else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x in poll\n",
 			       dev->name, status);
@@ -3603,7 +3603,7 @@ static int rtl8169_poll(struct napi_struct *napi,=
 int budget)
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		tp->intr_mask =3D 0xffff;
 		/*
 		 * 20040426: the barrier is not strictly required but the
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index f5c57c0..2a96a10 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2852,7 +2852,7 @@ static int s2io_poll_msix(struct napi_struct *nap=
i, int budget)
 	s2io_chk_rx_buffers(nic, ring);
=20
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		/*Re Enable MSI-Rx Vector*/
 		addr =3D (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr +=3D 7 - ring->ring_no;
@@ -2889,7 +2889,7 @@ static int s2io_poll_inta(struct napi_struct *nap=
i, int budget)
 			break;
 	}
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		/* Re enable the Rx interrupts for the ring */
 		writeq(0, &bar0->rx_traffic_mask);
 		readl(&bar0->rx_traffic_mask);
@@ -4342,7 +4342,7 @@ static irqreturn_t s2io_msix_ring_handle(int irq,=
 void *dev_id)
 		val8 =3D (ring->ring_no =3D=3D 0) ? 0x7f : 0xff;
 		writeb(val8, addr);
 		val8 =3D readb(addr);
-		netif_rx_schedule(&ring->napi);
+		napi_schedule(&ring->napi);
 	} else {
 		rx_intr_handler(ring, 0);
 		s2io_chk_rx_buffers(sp, ring);
@@ -4789,7 +4789,7 @@ static irqreturn_t s2io_isr(int irq, void *dev_id=
)
=20
 		if (config->napi) {
 			if (reason & GEN_INTR_RXTRAFFIC) {
-				netif_rx_schedule(&sp->napi);
+				napi_schedule(&sp->napi);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 				readl(&bar0->rx_traffic_int);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 31e38fa..3e11c1d 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2039,9 +2039,9 @@ static irqreturn_t sbmac_intr(int irq,void *dev_i=
nstance)
 		sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
=20
 	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-		if (netif_rx_schedule_prep(&sc->napi)) {
+		if (napi_schedule_prep(&sc->napi)) {
 			__raw_writeq(0, sc->sbm_imr);
-			__netif_rx_schedule(&sc->napi);
+			__napi_schedule(&sc->napi);
 			/* Depend on the exit from poll to reenable intr */
 		}
 		else {
@@ -2667,7 +2667,7 @@ static int sbmac_poll(struct napi_struct *napi, i=
nt budget)
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 #ifdef CONFIG_SBMAC_COALESCE
 		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_T=
X_CH0) |
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7673fd9..77aca5d 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -225,11 +225,11 @@ static int efx_poll(struct napi_struct *napi, int=
 budget)
=20
 	if (rx_packets < budget) {
 		/* There is no race here; although napi_disable() will
-		 * only wait for netif_rx_complete(), this isn't a problem
+		 * only wait for napi_complete(), this isn't a problem
 		 * since efx_channel_processed() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		efx_channel_processed(channel);
 	}
=20
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 0dd7a53..fb1ac0e 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -77,7 +77,7 @@ static inline void efx_schedule_channel(struct efx_ch=
annel *channel)
 		  channel->channel, raw_smp_processor_id());
 	channel->work_pending =3D true;
=20
-	netif_rx_schedule(&channel->napi_str);
+	napi_schedule(&channel->napi_str);
 }
=20
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index c9dbb06..952d37f 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3214,7 +3214,7 @@ static int skge_poll(struct napi_struct *napi, in=
t to_do)
 		unsigned long flags;
=20
 		spin_lock_irqsave(&hw->hw_lock, flags);
-		__netif_rx_complete(napi);
+		__napi_complete(napi);
 		hw->intr_mask |=3D napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
@@ -3377,7 +3377,7 @@ static irqreturn_t skge_intr(int irq, void *dev_i=
d)
 	if (status & (IS_XA1_F|IS_R1_F)) {
 		struct skge_port *skge =3D netdev_priv(hw->dev[0]);
 		hw->intr_mask &=3D ~(IS_XA1_F|IS_R1_F);
-		netif_rx_schedule(&skge->napi);
+		napi_schedule(&skge->napi);
 	}
=20
 	if (status & IS_PA_TO_TX1)
@@ -3397,7 +3397,7 @@ static irqreturn_t skge_intr(int irq, void *dev_i=
d)
=20
 		if (status & (IS_XA2_F|IS_R2_F)) {
 			hw->intr_mask &=3D ~(IS_XA2_F|IS_R2_F);
-			netif_rx_schedule(&skge->napi);
+			napi_schedule(&skge->napi);
 		}
=20
 		if (status & IS_PA_TO_RX2) {
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index dc3f110..9a45dea 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -983,7 +983,7 @@ static int smsc911x_poll(struct napi_struct *napi, =
int budget)
 			/* We processed all packets available.  Tell NAPI it can
 			 * stop polling then re-enable rx interrupts */
 			smsc911x_reg_write(pdata, INT_STS, INT_STS_RSFL_);
-			netif_rx_complete(napi);
+			napi_complete(napi);
 			temp =3D smsc911x_reg_read(pdata, INT_EN);
 			temp |=3D INT_EN_RSFL_EN_;
 			smsc911x_reg_write(pdata, INT_EN, temp);
@@ -1484,16 +1484,16 @@ static irqreturn_t smsc911x_irqhandler(int irq,=
 void *dev_id)
 	}
=20
 	if (likely(intsts & inten & INT_STS_RSFL_)) {
-		if (likely(netif_rx_schedule_prep(&pdata->napi))) {
+		if (likely(napi_schedule_prep(&pdata->napi))) {
 			/* Disable Rx interrupts */
 			temp =3D smsc911x_reg_read(pdata, INT_EN);
 			temp &=3D (~INT_EN_RSFL_EN_);
 			smsc911x_reg_write(pdata, INT_EN, temp);
 			/* Schedule a NAPI poll */
-			__netif_rx_schedule(&pdata->napi);
+			__napi_schedule(&pdata->napi);
 		} else {
 			SMSC_WARNING(RX_ERR,
-				"netif_rx_schedule_prep failed");
+				"napi_schedule_prep failed");
 		}
 		serviced =3D IRQ_HANDLED;
 	}
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 27e017d..8dd9966 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -666,7 +666,7 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_=
id)
 			smsc9420_pci_flush_write(pd);
=20
 			ints_to_clear |=3D (DMAC_STS_RX_ | DMAC_STS_NIS_);
-			netif_rx_schedule(&pd->napi);
+			napi_schedule(&pd->napi);
 		}
=20
 		if (ints_to_clear)
@@ -889,7 +889,7 @@ static int smsc9420_rx_poll(struct napi_struct *nap=
i, int budget)
 	smsc9420_pci_flush_write(pd);
=20
 	if (work_done < budget) {
-		netif_rx_complete(&pd->napi);
+		napi_complete(&pd->napi);
=20
 		/* re-enable RX DMA interrupts */
 		dma_intr_ena =3D smsc9420_reg_read(pd, DMAC_INTR_ENA);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 88d2c67..7f6b4a4 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1301,7 +1301,7 @@ static int spider_net_poll(struct napi_struct *na=
pi, int budget)
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (packets_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull =3D 0;
 	}
@@ -1528,7 +1528,7 @@ spider_net_handle_error_irq(struct spider_net_car=
d *card, u32 status_reg,
 			spider_net_refill_rx_chain(card);
 			spider_net_enable_rxdmac(card);
 			card->num_rx_ints ++;
-			netif_rx_schedule(&card->napi);
+			napi_schedule(&card->napi);
 		}
 		show_error =3D 0;
 		break;
@@ -1548,7 +1548,7 @@ spider_net_handle_error_irq(struct spider_net_car=
d *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(&card->napi);
+		napi_schedule(&card->napi);
 		show_error =3D 0;
 		break;
=20
@@ -1562,7 +1562,7 @@ spider_net_handle_error_irq(struct spider_net_car=
d *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(&card->napi);
+		napi_schedule(&card->napi);
 		show_error =3D 0;
 		break;
=20
@@ -1656,11 +1656,11 @@ spider_net_interrupt(int irq, void *ptr)
=20
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
-		netif_rx_schedule(&card->napi);
+		napi_schedule(&card->napi);
 		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
-		netif_rx_schedule(&card->napi);
+		napi_schedule(&card->napi);
=20
 	if (status_reg & SPIDER_NET_LINKINT)
 		spider_net_link_reset(netdev);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 57fb1f7..8d151d9 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1332,8 +1332,8 @@ static irqreturn_t intr_handler(int irq, void *de=
v_instance)
 		if (intr_status & (IntrRxDone | IntrRxEmpty)) {
 			u32 enable;
=20
-			if (likely(netif_rx_schedule_prep(&np->napi))) {
-				__netif_rx_schedule(&np->napi);
+			if (likely(napi_schedule_prep(&np->napi))) {
+				__napi_schedule(&np->napi);
 				enable =3D readl(ioaddr + IntrEnable);
 				enable &=3D ~(IntrRxDone | IntrRxEmpty);
 				writel(enable, ioaddr + IntrEnable);
@@ -1577,7 +1577,7 @@ static int netdev_poll(struct napi_struct *napi, =
int budget)
 		intr_status =3D readl(ioaddr + IntrStatus);
 	} while (intr_status & (IntrRxDone | IntrRxEmpty));
=20
-	netif_rx_complete(napi);
+	napi_complete(napi);
 	intr_status =3D readl(ioaddr + IntrEnable);
 	intr_status |=3D IntrRxDone | IntrRxEmpty;
 	writel(intr_status, ioaddr + IntrEnable);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 8a74604..ae78825 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -921,7 +921,7 @@ static int gem_poll(struct napi_struct *napi, int b=
udget)
 		gp->status =3D readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
=20
-	__netif_rx_complete(napi);
+	__napi_complete(napi);
 	gem_enable_ints(gp);
=20
 	spin_unlock_irqrestore(&gp->lock, flags);
@@ -944,7 +944,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev=
_id)
=20
 	spin_lock_irqsave(&gp->lock, flags);
=20
-	if (netif_rx_schedule_prep(&gp->napi)) {
+	if (napi_schedule_prep(&gp->napi)) {
 		u32 gem_status =3D readl(gp->regs + GREG_STAT);
=20
 		if (gem_status =3D=3D 0) {
@@ -954,7 +954,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev=
_id)
 		}
 		gp->status =3D gem_status;
 		gem_disable_ints(gp);
-		__netif_rx_schedule(&gp->napi);
+		__napi_schedule(&gp->napi);
 	}
=20
 	spin_unlock_irqrestore(&gp->lock, flags);
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index bcd0e60..f42c67e 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1609,8 +1609,8 @@ static irqreturn_t tc35815_interrupt(int irq, voi=
d *dev_id)
 	if (!(dmactl & DMA_IntMask)) {
 		/* disable interrupts */
 		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
-		if (netif_rx_schedule_prep(&lp->napi))
-			__netif_rx_schedule(&lp->napi);
+		if (napi_schedule_prep(&lp->napi))
+			__napi_schedule(&lp->napi);
 		else {
 			printk(KERN_ERR "%s: interrupt taken in poll\n",
 			       dev->name);
@@ -1919,7 +1919,7 @@ static int tc35815_poll(struct napi_struct *napi,=
 int budget)
 	spin_unlock(&lp->lock);
=20
 	if (received < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		/* enable interrupts */
 		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
 	}
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index a10a83a..9bcab92 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -265,8 +265,8 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 		bdx_isr_extra(priv, isr);
=20
 	if (isr & (IR_RX_DESC_0 | IR_TX_FREE_0)) {
-		if (likely(netif_rx_schedule_prep(&priv->napi))) {
-			__netif_rx_schedule(&priv->napi);
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			__napi_schedule(&priv->napi);
 			RET(IRQ_HANDLED);
 		} else {
 			/* NOTE: we get here if intr has slipped into window
@@ -302,7 +302,7 @@ static int bdx_poll(struct napi_struct *napi, int b=
udget)
 		 * device lock and allow waiting tasks (eg rmmod) to advance) */
 		priv->napi_stop =3D 0;
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		bdx_enable_interrupts(priv);
 	}
 	return work_done;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5e2dbae..d1a44be 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4460,7 +4460,7 @@ static int tg3_poll(struct napi_struct *napi, int=
 budget)
 			sblk->status &=3D ~SD_STATUS_UPDATED;
=20
 		if (likely(!tg3_has_work(tp))) {
-			netif_rx_complete(napi);
+			napi_complete(napi);
 			tg3_restart_ints(tp);
 			break;
 		}
@@ -4470,7 +4470,7 @@ static int tg3_poll(struct napi_struct *napi, int=
 budget)
=20
 tx_recovery:
 	/* work_done is guaranteed to be less than budget. */
-	netif_rx_complete(napi);
+	napi_complete(napi);
 	schedule_work(&tp->reset_task);
 	return work_done;
 }
@@ -4519,7 +4519,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *d=
ev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
=20
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(&tp->napi);
+		napi_schedule(&tp->napi);
=20
 	return IRQ_HANDLED;
 }
@@ -4544,7 +4544,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(&tp->napi);
+		napi_schedule(&tp->napi);
=20
 	return IRQ_RETVAL(1);
 }
@@ -4586,7 +4586,7 @@ static irqreturn_t tg3_interrupt(int irq, void *d=
ev_id)
 	sblk->status &=3D ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		netif_rx_schedule(&tp->napi);
+		napi_schedule(&tp->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -4632,7 +4632,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, =
void *dev_id)
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (netif_rx_schedule_prep(&tp->napi)) {
+	if (napi_schedule_prep(&tp->napi)) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		/* Update last_tag to mark that this status has been
 		 * seen. Because interrupt may be shared, we may be
@@ -4640,7 +4640,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, =
void *dev_id)
 		 * if tg3_poll() is not scheduled.
 		 */
 		tp->last_tag =3D sblk->status_tag;
-		__netif_rx_schedule(&tp->napi);
+		__napi_schedule(&tp->napi);
 	}
 out:
 	return IRQ_RETVAL(handled);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 75461db..1138782 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -888,7 +888,7 @@ static int tsi108_poll(struct napi_struct *napi, in=
t budget)
=20
 	if (num_received < budget) {
 		data->rxpending =3D 0;
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		TSI_WRITE(TSI108_EC_INTMASK,
 				     TSI_READ(TSI108_EC_INTMASK)
@@ -915,11 +915,11 @@ static void tsi108_rx_int(struct net_device *dev)
 	 *
 	 * This can happen if this code races with tsi108_poll(), which masks
 	 * the interrupts after tsi108_irq_one() read the mask, but before
-	 * netif_rx_schedule is called.  It could also happen due to calls
+	 * napi_schedule is called.  It could also happen due to calls
 	 * from tsi108_check_rxring().
 	 */
=20
-	if (netif_rx_schedule_prep(&data->napi)) {
+	if (napi_schedule_prep(&data->napi)) {
 		/* Mask, rather than ack, the receive interrupts.  The ack
 		 * will happen in tsi108_poll().
 		 */
@@ -930,7 +930,7 @@ static void tsi108_rx_int(struct net_device *dev)
 				     | TSI108_INT_RXTHRESH |
 				     TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR |
 				     TSI108_INT_RXWAIT);
-		__netif_rx_schedule(&data->napi);
+		__napi_schedule(&data->napi);
 	} else {
 		if (!netif_running(dev)) {
 			/* This can happen if an interrupt occurs while the
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrup=
t.c
index 6c3428a..9f946d4 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -103,7 +103,7 @@ void oom_timer(unsigned long data)
 {
         struct net_device *dev =3D (struct net_device *)data;
 	struct tulip_private *tp =3D netdev_priv(dev);
-	netif_rx_schedule(&tp->napi);
+	napi_schedule(&tp->napi);
 }
=20
 int tulip_poll(struct napi_struct *napi, int budget)
@@ -300,7 +300,7 @@ int tulip_poll(struct napi_struct *napi, int budget=
)
=20
          /* Remove us from polling list and enable RX intr. */
=20
-         netif_rx_complete(napi);
+         napi_complete(napi);
          iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+C=
SR7);
=20
          /* The last op happens after poll completion. Which means the=
 following:
@@ -333,10 +333,10 @@ int tulip_poll(struct napi_struct *napi, int budg=
et)
=20
          /* Think: timer_pending() was an explicit signature of bug.
           * Timer can be pending now but fired and completed
-          * before we did netif_rx_complete(). See? We would lose it. =
*/
+          * before we did napi_complete(). See? We would lose it. */
=20
          /* remove ourselves from the polling list */
-         netif_rx_complete(napi);
+         napi_complete(napi);
=20
          return work_done;
 }
@@ -519,7 +519,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_inst=
ance)
 			rxd++;
 			/* Mask RX intrs and add the device to poll list. */
 			iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + C=
SR7);
-			netif_rx_schedule(&tp->napi);
+			napi_schedule(&tp->napi);
=20
 			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
                                break;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0009f4e..8c5964e 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1783,7 +1783,7 @@ typhoon_poll(struct napi_struct *napi, int budget=
)
 	}
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
@@ -1806,10 +1806,10 @@ typhoon_interrupt(int irq, void *dev_instance)
=20
 	iowrite32(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
=20
-	if (netif_rx_schedule_prep(&tp->napi)) {
+	if (napi_schedule_prep(&tp->napi)) {
 		iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(ioaddr);
-		__netif_rx_schedule(&tp->napi);
+		__napi_schedule(&tp->napi);
 	} else {
 		printk(KERN_ERR "%s: Error, poll already scheduled\n",
                        dev->name);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7d5a130..1708f5e 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3288,7 +3288,7 @@ static int ucc_geth_poll(struct napi_struct *napi=
, int budget)
 		struct ucc_fast_private *uccf;
 		u32 uccm;
=20
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		uccf =3D ugeth->uccf;
 		uccm =3D in_be32(uccf->p_uccm);
 		uccm |=3D UCCE_RX_EVENTS;
@@ -3322,10 +3322,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq=
, void *info)
=20
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
-		if (netif_rx_schedule_prep(&ugeth->napi)) {
+		if (napi_schedule_prep(&ugeth->napi)) {
 			uccm &=3D ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
-			__netif_rx_schedule(&ugeth->napi);
+			__napi_schedule(&ugeth->napi);
 		}
 	}
=20
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index ac07cc6..b0aa2fe 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -589,7 +589,7 @@ static int rhine_napipoll(struct napi_struct *napi,=
 int budget)
 	work_done =3D rhine_rx(dev, budget);
=20
 	if (work_done < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
=20
 		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1318,7 +1318,7 @@ static irqreturn_t rhine_interrupt(int irq, void =
*dev_instance)
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
=20
-			netif_rx_schedule(&rp->napi);
+			napi_schedule(&rp->napi);
 		}
=20
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b7004ff..34f4c3e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -374,9 +374,9 @@ static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi =3D rvq->vdev->priv;
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (netif_rx_schedule_prep(&vi->napi)) {
+	if (napi_schedule_prep(&vi->napi)) {
 		rvq->vq_ops->disable_cb(rvq);
-		__netif_rx_schedule(&vi->napi);
+		__napi_schedule(&vi->napi);
 	}
 }
=20
@@ -402,11 +402,11 @@ again:
=20
 	/* Out of packets? */
 	if (received < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		if (unlikely(!vi->rvq->vq_ops->enable_cb(vi->rvq))
 		    && napi_schedule_prep(napi)) {
 			vi->rvq->vq_ops->disable_cb(vi->rvq);
-			__netif_rx_schedule(napi);
+			__napi_schedule(napi);
 			goto again;
 		}
 	}
@@ -580,9 +580,9 @@ static int virtnet_open(struct net_device *dev)
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (netif_rx_schedule_prep(&vi->napi)) {
+	if (napi_schedule_prep(&vi->napi)) {
 		vi->rvq->vq_ops->disable_cb(vi->rvq);
-		__netif_rx_schedule(&vi->napi);
+		__napi_schedule(&vi->napi);
 	}
 	return 0;
 }
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index 08b3536..497b003 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -341,7 +341,7 @@ static int sca_poll(struct napi_struct *napi, int b=
udget)
 		received =3D sca_rx_done(port, budget);
=20
 	if (received < budget) {
-		netif_rx_complete(napi);
+		napi_complete(napi);
 		enable_intr(port);
 	}
=20
@@ -359,7 +359,7 @@ static irqreturn_t sca_intr(int irq, void *dev_id)
 		if (port && (isr0 & (i ? 0x08002200 : 0x00080022))) {
 			handled =3D 1;
 			disable_intr(port);
-			netif_rx_schedule(&port->napi);
+			napi_schedule(&port->napi);
 		}
 	}
=20
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
index 2dc2416..9ea167b 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -622,7 +622,7 @@ static void hss_hdlc_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: hss_hdlc_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(queue_ids[port->id].rx);
-	netif_rx_schedule(dev, &port->napi);
+	napi_schedule(dev, &port->napi);
 }
=20
 static int hss_hdlc_poll(struct napi_struct *napi, int budget)
@@ -649,15 +649,15 @@ static int hss_hdlc_poll(struct napi_struct *napi=
, int budget)
 		if ((n =3D queue_get_desc(rxq, port, 0)) < 0) {
 #if DEBUG_RX
 			printk(KERN_DEBUG "%s: hss_hdlc_poll"
-			       " netif_rx_complete\n", dev->name);
+			       " napi_complete\n", dev->name);
 #endif
-			netif_rx_complete(dev, napi);
+			napi_complete(dev, napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
-			    netif_rx_reschedule(napi)) {
+			    napi_reschedule(napi)) {
 #if DEBUG_RX
 				printk(KERN_DEBUG "%s: hss_hdlc_poll"
-				       " netif_rx_reschedule succeeded\n",
+				       " napi_reschedule succeeded\n",
 				       dev->name);
 #endif
 				qmgr_disable_irq(rxq);
@@ -1069,7 +1069,7 @@ static int hss_hdlc_open(struct net_device *dev)
 	hss_start_hdlc(port);
=20
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	napi_schedule(dev, &port->napi);
 	return 0;
=20
 err_unlock:
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 761635b..91a2b63 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -196,7 +196,7 @@ static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev =3D (struct net_device *)data;
 	struct netfront_info *np =3D netdev_priv(dev);
-	netif_rx_schedule(&np->napi);
+	napi_schedule(&np->napi);
 }
=20
 static int netfront_tx_slot_available(struct netfront_info *np)
@@ -328,7 +328,7 @@ static int xennet_open(struct net_device *dev)
 		xennet_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event =3D np->rx.rsp_cons + 1;
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(&np->napi);
+			napi_schedule(&np->napi);
 	}
 	spin_unlock_bh(&np->rx_lock);
=20
@@ -979,7 +979,7 @@ err:
=20
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
 		if (!more_to_do)
-			__netif_rx_complete(napi);
+			__napi_complete(napi);
=20
 		local_irq_restore(flags);
 	}
@@ -1310,7 +1310,7 @@ static irqreturn_t xennet_interrupt(int irq, void=
 *dev_id)
 		xennet_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(&np->napi);
+			napi_schedule(&np->napi);
 	}
=20
 	spin_unlock_irqrestore(&np->tx_lock, flags);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c28bbba..0045b32 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1568,56 +1568,6 @@ static inline u32 netif_msg_init(int debug_value=
, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
=20
-/* Test if receive needs to be scheduled but only if up */
-static inline int netif_rx_schedule_prep(struct napi_struct *napi)
-{
-	return napi_schedule_prep(napi);
-}
-
-/* Add interface to tail of rx poll list. This assumes that _prep has
- * already been called and returned 1.
- */
-static inline void __netif_rx_schedule(struct napi_struct *napi)
-{
-	__napi_schedule(napi);
-}
-
-/* Try to reschedule poll. Called by irq handler. */
-
-static inline void netif_rx_schedule(struct napi_struct *napi)
-{
-	if (netif_rx_schedule_prep(napi))
-		__netif_rx_schedule(napi);
-}
-
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_comple=
te().  */
-static inline int netif_rx_reschedule(struct napi_struct *napi)
-{
-	if (napi_schedule_prep(napi)) {
-		__netif_rx_schedule(napi);
-		return 1;
-	}
-	return 0;
-}
-
-/* same as netif_rx_complete, except that local_irq_save(flags)
- * has already been issued
- */
-static inline void __netif_rx_complete(struct napi_struct *napi)
-{
-	__napi_complete(napi);
-}
-
-/* Remove interface from poll list: it must be in the poll list
- * on current cpu. This primitive is called by dev->poll(), when
- * it completes the work. The device cannot be out of poll list at thi=
s
- * moment, it is BUG().
- */
-static inline void netif_rx_complete(struct napi_struct *napi)
-{
-	napi_complete(napi);
-}
-
 static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
 {
 	spin_lock(&txq->_xmit_lock);

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

