From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] drivers: net: generalize napi_complete_done()
Date: Mon, 30 Jan 2017 08:22:01 -0800
Message-ID: <20170130162201.8459-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33398 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932355AbdA3QWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:22:06 -0500
Received: by mail-pg0-f50.google.com with SMTP id 204so102408666pge.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 08:22:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi_complete_done() allows to opt-in for gro_flush_timeout,
added back in linux-3.19, commit 3b47d30396ba
("net: gro: add a per device gro flush timer")

This allows for more efficient GRO aggregation without
sacrifying latencies.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/can/at91_can.c                          |  2 +-
 drivers/net/can/c_can/c_can.c                       |  2 +-
 drivers/net/can/flexcan.c                           |  2 +-
 drivers/net/can/ifi_canfd/ifi_canfd.c               |  2 +-
 drivers/net/can/janz-ican3.c                        |  2 +-
 drivers/net/can/m_can/m_can.c                       |  2 +-
 drivers/net/can/rcar/rcar_can.c                     |  2 +-
 drivers/net/can/rcar/rcar_canfd.c                   |  2 +-
 drivers/net/can/xilinx_can.c                        |  2 +-
 drivers/net/ethernet/3com/typhoon.c                 |  2 +-
 drivers/net/ethernet/adi/bfin_mac.c                 |  2 +-
 drivers/net/ethernet/agere/et131x.c                 |  2 +-
 drivers/net/ethernet/altera/altera_tse_main.c       |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c    |  2 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c     |  2 +-
 drivers/net/ethernet/arc/emac_main.c                |  2 +-
 drivers/net/ethernet/atheros/alx/main.c             |  2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c     |  2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c     |  2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c            |  2 +-
 drivers/net/ethernet/broadcom/b44.c                 |  2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c        |  2 +-
 drivers/net/ethernet/broadcom/bgmac.c               |  2 +-
 drivers/net/ethernet/broadcom/bnx2.c                |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c           |  2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c          |  2 +-
 drivers/net/ethernet/brocade/bna/bnad.c             |  2 +-
 drivers/net/ethernet/cadence/macb.c                 |  2 +-
 drivers/net/ethernet/calxeda/xgmac.c                |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c     |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c  |  2 +-
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c    |  2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c    |  2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c             |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c            |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c          |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c         |  4 ++--
 drivers/net/ethernet/dec/tulip/interrupt.c          |  6 +++---
 drivers/net/ethernet/dnet.c                         |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c         |  2 +-
 drivers/net/ethernet/ethoc.c                        |  2 +-
 drivers/net/ethernet/ezchip/nps_enet.c              |  2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c      |  2 +-
 drivers/net/ethernet/freescale/fec_main.c           |  2 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c   |  2 +-
 drivers/net/ethernet/freescale/gianfar.c            |  4 ++--
 drivers/net/ethernet/freescale/ucc_geth.c           |  2 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c          |  2 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c         |  2 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c       |  2 +-
 drivers/net/ethernet/ibm/ibmveth.c                  |  2 +-
 drivers/net/ethernet/ibm/ibmvnic.c                  |  2 +-
 drivers/net/ethernet/intel/e100.c                   |  2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c         |  2 +-
 drivers/net/ethernet/korina.c                       |  2 +-
 drivers/net/ethernet/lantiq_etop.c                  | 21 +++++++++------------
 drivers/net/ethernet/marvell/mv643xx_eth.c          |  2 +-
 drivers/net/ethernet/marvell/mvneta.c               |  6 ++----
 drivers/net/ethernet/marvell/mvpp2.c                |  2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c           |  2 +-
 drivers/net/ethernet/moxa/moxart_ether.c            |  2 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c    |  2 +-
 drivers/net/ethernet/natsemi/natsemi.c              |  2 +-
 drivers/net/ethernet/neterion/s2io.c                |  4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-main.c      |  6 +++---
 drivers/net/ethernet/nvidia/forcedeth.c             |  2 +-
 drivers/net/ethernet/nxp/lpc_eth.c                  |  2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c    |  2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c            |  2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c    |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_fp.c          |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c      | 10 +++++-----
 drivers/net/ethernet/qlogic/qlge/qlge_main.c        |  2 +-
 drivers/net/ethernet/qualcomm/emac/emac.c           |  2 +-
 drivers/net/ethernet/realtek/r8169.c                |  2 +-
 drivers/net/ethernet/rocker/rocker_main.c           |  2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c     |  2 +-
 drivers/net/ethernet/sfc/efx.c                      |  2 +-
 drivers/net/ethernet/sfc/falcon/efx.c               |  2 +-
 drivers/net/ethernet/smsc/smsc9420.c                |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c   |  2 +-
 drivers/net/ethernet/sun/niu.c                      |  2 +-
 drivers/net/ethernet/sun/sungem.c                   |  2 +-
 drivers/net/ethernet/sun/sunvnet_common.c           |  2 +-
 drivers/net/ethernet/tehuti/tehuti.c                |  2 +-
 drivers/net/ethernet/ti/cpsw.c                      |  2 +-
 drivers/net/ethernet/ti/davinci_emac.c              |  2 +-
 drivers/net/ethernet/ti/netcp_core.c                |  2 +-
 drivers/net/ethernet/tile/tilegx.c                  |  2 +-
 drivers/net/ethernet/tile/tilepro.c                 |  2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c        |  2 +-
 drivers/net/ethernet/toshiba/spider_net.c           |  2 +-
 drivers/net/ethernet/toshiba/tc35815.c              |  2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c            |  2 +-
 drivers/net/ethernet/via/via-rhine.c                |  2 +-
 drivers/net/ethernet/via/via-velocity.c             |  2 +-
 drivers/net/ethernet/wiznet/w5100.c                 |  2 +-
 drivers/net/ethernet/wiznet/w5300.c                 |  2 +-
 drivers/net/fjes/fjes_main.c                        |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                   |  4 ++--
 drivers/net/wan/fsl_ucc_hdlc.c                      |  2 +-
 drivers/net/wan/hd64572.c                           |  2 +-
 drivers/net/wireless/ath/ath10k/pci.c               |  2 +-
 drivers/net/wireless/ath/wil6210/netdev.c           |  2 +-
 drivers/net/xen-netback/interface.c                 |  2 +-
 drivers/net/xen-netfront.c                          |  2 +-
 drivers/staging/octeon/ethernet-rx.c                |  2 +-
 drivers/staging/unisys/visornic/visornic_main.c     |  2 +-
 109 files changed, 132 insertions(+), 137 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 8f5e93cb79752703c141704011490535664b..0e0df0ba288cadf9cd3cde474284f14ee791 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -813,7 +813,7 @@ static int at91_poll(struct napi_struct *napi, int quota)
 		u32 reg_ier = AT91_IRQ_ERR_FRAME;
 		reg_ier |= get_irq_mb_rx(priv) & ~AT91_MB_MASK(priv->rx_next);
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		at91_write(priv, AT91_IER, reg_ier);
 	}
 
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index e3dccd3200d5d834f13ad036c290c51e3091..606b7d8ffe138f880bfc830eff10b84ba6a0 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1070,7 +1070,7 @@ static int c_can_poll(struct napi_struct *napi, int quota)
 
 end:
 	if (work_done < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* enable all IRQs if we are not in bus off state */
 		if (priv->can.state != CAN_STATE_BUS_OFF)
 			c_can_irq_control(priv, true);
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 16f7cadda5c32b430c0d25aea9746a93a063..43cfce8b076b72ffa4e184c458d8ee2d0fe7 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -703,7 +703,7 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 		work_done += flexcan_poll_bus_err(dev, reg_esr);
 
 	if (work_done < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* enable IRQs */
 		flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
 		flexcan_write(priv->reg_ctrl_default, &regs->ctrl);
diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 368bb0710d8f2157f4d94bd5d332adf9290c..138f5ae75c0bc6fcf912d30975197caedb0e 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -578,7 +578,7 @@ static int ifi_canfd_poll(struct napi_struct *napi, int quota)
 		work_done += ifi_canfd_do_rx_poll(ndev, quota - work_done);
 
 	if (work_done < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		ifi_canfd_irq_enable(ndev, 1);
 	}
 
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index f13bb8d9bb8429e46be9d950df27e016ce45..2ba1a81500c126da0a9aee4333786ec5b9f2 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1475,7 +1475,7 @@ static int ican3_napi(struct napi_struct *napi, int budget)
 	/* We have processed all packets that the adapter had, but it
 	 * was less than our budget, stop polling */
 	if (received < budget)
-		napi_complete(napi);
+		napi_complete_done(napi, received);
 
 	spin_lock_irqsave(&mod->lock, flags);
 
diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 195f15edb32e3cf03b552d7cdb9a98d76f56..7a6554efd42bfb10dbbfdf67d405507fa464 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -730,7 +730,7 @@ static int m_can_poll(struct napi_struct *napi, int quota)
 		work_done += m_can_do_rx_poll(dev, (quota - work_done));
 
 	if (work_done < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		m_can_enable_all_interrupts(priv);
 	}
 
diff --git a/drivers/net/can/rcar/rcar_can.c b/drivers/net/can/rcar/rcar_can.c
index 788459f6bf5cc6a71c5e914d282a0e7bd554..caed4e6960f8c77fdca254f5ed4e7ccbe697 100644
--- a/drivers/net/can/rcar/rcar_can.c
+++ b/drivers/net/can/rcar/rcar_can.c
@@ -695,7 +695,7 @@ static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
 	}
 	/* All packets processed */
 	if (num_pkts < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, num_pkts);
 		priv->ier |= RCAR_CAN_IER_RXFIE;
 		writeb(priv->ier, &priv->regs->ier);
 	}
diff --git a/drivers/net/can/rcar/rcar_canfd.c b/drivers/net/can/rcar/rcar_canfd.c
index 43cdd5544b0c46bfa0741ea6d4977ea7d069..4ef07d97156da838edaad4661f094d2e38d9 100644
--- a/drivers/net/can/rcar/rcar_canfd.c
+++ b/drivers/net/can/rcar/rcar_canfd.c
@@ -1512,7 +1512,7 @@ static int rcar_canfd_rx_poll(struct napi_struct *napi, int quota)
 
 	/* All packets processed */
 	if (num_pkts < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, num_pkts);
 		/* Enable Rx FIFO interrupts */
 		rcar_canfd_set_bit(priv->base, RCANFD_RFCC(ridx),
 				   RCANFD_RFCC_RFIE);
diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index c71a03593595adb24a11e13053e2b3d26be8..89aec07c225f58d26a80ce4795afbaa6c19d 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -726,7 +726,7 @@ static int xcan_rx_poll(struct napi_struct *napi, int quota)
 		can_led_event(ndev, CAN_LED_EVENT_RX);
 
 	if (work_done < quota) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		ier = priv->read_reg(priv, XCAN_IER_OFFSET);
 		ier |= (XCAN_IXR_RXOK_MASK | XCAN_IXR_RXNEMP_MASK);
 		priv->write_reg(priv, XCAN_IER_OFFSET, ier);
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 1986ad17950ae686cb1b592619d7d606a216..084a6d58543a71b35e0aa184cf03a9f9e5af 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1753,7 +1753,7 @@ typhoon_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 88164529b52a2a44207b71b49c86297067b7..a8173130373056b3a245b241f834312ded0f 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1274,7 +1274,7 @@ static int bfin_mac_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (i < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, i);
 		if (test_and_clear_bit(BFIN_MAC_RX_IRQ_DISABLED, &lp->flags))
 			enable_irq(IRQ_MAC_RX);
 	}
diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 831bab352f8e6a99b0ee3ce519e8b7f7cbd4..87a11b9f0ea5beab9a97493e23ae901f6d39 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3575,7 +3575,7 @@ static int et131x_poll(struct napi_struct *napi, int budget)
 	et131x_handle_send_pkts(adapter);
 
 	if (work_done < budget) {
-		napi_complete(&adapter->napi);
+		napi_complete_done(&adapter->napi, work_done);
 		et131x_enable_interrupts(adapter);
 	}
 
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 25864bff25eee4b1038fd7520499ac47ca3f..527908c7e3845d57c2418c8ab17f3c445a09 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -513,7 +513,7 @@ static int tse_poll(struct napi_struct *napi, int budget)
 
 	if (rxcomplete < budget) {
 
-		napi_complete(napi);
+		napi_complete_done(napi, rxcomplete);
 
 		netdev_dbg(priv->dev,
 			   "NAPI Complete, did %d packets with budget %d\n",
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index de59db6c58419667bb84d487aab616492055..ab43c52723dfd3ad7feb7e8f63a6d808f0dd 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -840,7 +840,7 @@ static int xgene_enet_napi(struct napi_struct *napi, const int budget)
 	processed = xgene_enet_process_ring(ring, budget);
 
 	if (processed != budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 		enable_irq(ring->irq);
 	}
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index 140962f23e61ceeaef75838e498b88e5ef0c..cb30a6396a7022eecc5cdf1cc8ed8c5c8a2a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -97,7 +97,7 @@ __acquires(&self->lock)
 			work_done = budget;
 
 		if (work_done < budget) {
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			self->aq_hw_ops->hw_irq_enable(self->aq_hw,
 					1U << self->aq_ring_param.vec_idx);
 		}
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index abc9f2a590546e0be4c5a5dabcf6ff3d219f..23873395f100b06763e03e12b6a91685aba7 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -275,7 +275,7 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
 
 	work_done = arc_emac_rx(ndev, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
 	}
 
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 391bb5c09a6a95e404ea5842c5987b8ae175..6a27c266267587685956b8720cd0a6bc9b3f 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -311,7 +311,7 @@ static int alx_poll(struct napi_struct *napi, int budget)
 	if (!tx_complete || work == budget)
 		return budget;
 
-	napi_complete(&np->napi);
+	napi_complete_done(&np->napi, work);
 
 	/* enable interrupt */
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 773d3b7d8dd5efeee95b14eb1df6b483b9d8..7e913d8331c3082d4720e8a4077a85abd4be 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1892,7 +1892,7 @@ static int atl1c_clean(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 quit_polling:
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		adapter->hw.intr_mask |= ISR_RX_PKT;
 		AT_WRITE_REG(&adapter->hw, REG_IMR, adapter->hw.intr_mask);
 	}
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index e96091b652a7ec1baf42d24fc4bf674aabf3..ef003c522ba24f6065f23e3718902a3b190e 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1526,7 +1526,7 @@ static int atl1e_clean(struct napi_struct *napi, int budget)
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if (work_done < budget) {
 quit_polling:
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		imr_data = AT_READ_REG(&adapter->hw, REG_IMR);
 		AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT);
 		/* test debug */
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 7dad8e4b9d2a8aabdf6a5b8f12d3046e5131..022772e1e24988deec39b46c69a45349d7db 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2457,7 +2457,7 @@ static int atl1_rings_clean(struct napi_struct *napi, int budget)
 	if (work_done >= budget)
 		return work_done;
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	/* re-enable Interrupt */
 	if (likely(adapter->int_enabled))
 		atlx_imr_set(adapter, IMR_NORMAL_MASK);
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 7aef70f7d8ef01a0351de954d9422d5ca22a..5b95bb48ce97dd9c0d02968badb05949f7eb 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -902,7 +902,7 @@ static int b44_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		b44_enable_ints(bp);
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index c483618b57bd7ef93f8522a91814a5dd9d9b..0ee6e208aa07eca9d7111666d89e05e042e9 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -511,7 +511,7 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 
 	/* no more packet in rx/tx queue, remove device from poll
 	 * queue */
-	napi_complete(napi);
+	napi_complete_done(napi, rx_work_done);
 
 	/* restore rx/tx interrupt */
 	enet_dmac_writel(priv, priv->dma_chan_int_mask,
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 0e066dc6b8cc32436f0a5bbcab0505d7af37..9122608df16e7bab1f659f0a614a472fe056 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1148,7 +1148,7 @@ static int bgmac_poll(struct napi_struct *napi, int weight)
 		return weight;
 
 	if (handled < weight) {
-		napi_complete(napi);
+		napi_complete_done(napi, handled);
 		bgmac_chip_intrs_on(bgmac);
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index de1d07c08495691365b24335ca97de0dfbd3..e3af1f3cb61f3f75de64866a4ee9e00fc1e5 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3515,7 +3515,7 @@ static int bnx2_poll_msix(struct napi_struct *napi, int budget)
 		rmb();
 		if (likely(!bnx2_has_fast_work(bnapi))) {
 
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
 				BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 				bnapi->last_status_idx);
@@ -3552,7 +3552,7 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
 				BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 					BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c0dac0e5696d7d01457a42c2c13f1640c2e2..9e8c06130c092d3f061089448797c1da74e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3224,7 +3224,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 		 * has been updated when NAPI was scheduled.
 		 */
 		if (IS_FCOE_FP(fp)) {
-			napi_complete(napi);
+			napi_complete_done(napi, rx_work_done);
 		} else {
 			bnx2x_update_fpsb_idx(fp);
 			/* bnx2x_has_rx_work() reads the status block,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 3d83b90280146c74f95c03b3644ea41d5bf5..aff3dc114a5b7c74ae6d9ea205088b198d83 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1759,7 +1759,7 @@ static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
 	}
 
 	if (!bnxt_has_work(bp, cpr) && rx_pkts < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_pkts);
 		BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
 	}
 	return rx_pkts;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 435a2e4739d16d721918b55cc54c855fd3f5..89d4feba1a9aeafbf639effa3941701c0d9b 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2537,7 +2537,7 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 #ifdef CONFIG_SBMAC_COALESCE
 		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 73a94113db1f776e15d8a43bbec350197044..6e13c937d715e03de7191949b7e685be54d7 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1881,7 +1881,7 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 		return rcvd;
 
 poll_exit:
-	napi_complete(napi);
+	napi_complete_done(napi, rcvd);
 
 	rx_ctrl->rx_complete++;
 
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ff1e648e74c9c4447c9e9b02c1936e6ca2b0..d7d135c95509ac7fc9c6c80303556e3ba1d4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1090,7 +1090,7 @@ static int macb_poll(struct napi_struct *napi, int budget)
 
 	work_done = bp->macbgem_ops.mog_rx(bp, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		/* Packets received while interrupts were disabled */
 		status = macb_readl(bp, RSR);
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index b0540658afad47ba0b5aa70a8d1ed5410e20..2bd7c638b178d5801bf2f3e4525e02734454 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1247,7 +1247,7 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
 	work_done = xgmac_rx(priv, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		__raw_writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 9261ddc0685238ff8882b021ab18bd88c12b..fbe1986b87f6b6cdf7c30e635715a5ae49a9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2446,7 +2446,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if ((work_done < budget) && (tx_done)) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
 		return 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index a6587d7019ed5ad9aa7f73717e0435160816..78cfa8ba1b57e3b9b97abaf66b7a61696bda 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1631,7 +1631,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if ((work_done < budget) && (tx_done)) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
 		return 0;
diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index 21f80f5744ba2f048b4d7e0a8a8862e45977..a2138686c6055d3d18d9294a14d2468b638c 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -501,7 +501,7 @@ static int octeon_mgmt_napi_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		/* We stopped because no more packets were available. */
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		octeon_mgmt_enable_rx_irq(p);
 	}
 	octeon_mgmt_update_rx_stats(netdev);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a25bb6ea2ff44a1d6c3994aa7f9e2109ab57..6feaa24bcfd42bb9647298a0b665e6bf3b11 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -749,7 +749,7 @@ static int nicvf_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		/* Slow packet rate, exit polling */
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* Re-enable interrupts */
 		cq_head = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_HEAD,
 					       cq->cq_idx);
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 86f467a2c4859608cc0337e57534d4a2d5e5..d56142b985349380068a1c313c71b6211059 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1605,7 +1605,7 @@ int t1_poll(struct napi_struct *napi, int budget)
 	int work_done = process_responses(adapter, budget);
 
 	if (likely(work_done < budget)) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index e4b5b057f41786733ea9883de572702aeec7..1b9d154f114923841702ee67af2e0f17d94e 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1843,7 +1843,7 @@ static int ofld_poll(struct napi_struct *napi, int budget)
 		__skb_queue_head_init(&queue);
 		skb_queue_splice_init(&q->rx_queue, &queue);
 		if (skb_queue_empty(&queue)) {
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			spin_unlock_irq(&q->lock);
 			return work_done;
 		}
@@ -2414,7 +2414,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	int work_done = process_responses(adap, qs, budget);
 
 	if (likely(work_done < budget)) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		/*
 		 * Because we don't atomically flush the following
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index f3ed9ce99e5e7023a93aa22fc85398f40571..e37dde2ba97f6d529177d475be2a6d001071 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1889,7 +1889,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	u32 val;
 
 	if (likely(work_done < budget)) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		intr_params = rspq->next_intr_params;
 		rspq->next_intr_params = rspq->intr_params;
 	} else
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index c5842c525eed80ed2d480678489a2b003a70..91e42bea151c3554457fd2e4916e79fd8cfa 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1343,7 +1343,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		 * exit polling
 		 */
 
-		napi_complete(napi);
+		napi_complete_done(napi, rq_work_done);
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_set_int_moderation(enic, &enic->rq[0]);
 		vnic_intr_unmask(&enic->intr[intr]);
@@ -1500,7 +1500,7 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 		 * exit polling
 		 */
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_set_int_moderation(enic, &enic->rq[rq]);
 		vnic_intr_unmask(&enic->intr[intr]);
diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 92306b320840289e710502dcee938282c4a9..ba6ae24acf62238e22c162f9ee294159f41d 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -319,8 +319,8 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
          /* Remove us from polling list and enable RX intr. */
 
-         napi_complete(napi);
-         iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+CSR7);
+	napi_complete_done(napi, work_done);
+	iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+CSR7);
 
          /* The last op happens after poll completion. Which means the following:
           * 1. it can race with disabling irqs in irq handler
@@ -355,7 +355,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
           * before we did napi_complete(). See? We would lose it. */
 
          /* remove ourselves from the polling list */
-         napi_complete(napi);
+         napi_complete_done(napi, work_done);
 
          return work_done;
 }
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 2a17c59f69f9fb0208f7bf6c23b88af1f082..3e77dd863175f7a6c5d5c31cbcb922589c00 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -415,7 +415,7 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 		/* We processed all packets available.  Tell NAPI it can
 		 * stop polling then re-enable rx interrupts.
 		 */
-		napi_complete(napi);
+		napi_complete_done(napi, npackets);
 		int_enable = dnet_readl(bp, INTR_ENB);
 		int_enable |= DNET_INTR_SRC_RX_CMDFIFOAF;
 		dnet_writel(bp, int_enable, INTR_ENB);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0690b57466abb4efdbf5b1efd413b0ee4d72..b3a054026e71ea685d136c5c84be7d0c4500 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3324,7 +3324,7 @@ int be_poll(struct napi_struct *napi, int budget)
 		be_process_mcc(adapter);
 
 	if (max_work < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, max_work);
 
 		/* Skyhawk EQ_DB has a provision to set the rearm to interrupt
 		 * delay via a delay multiplier encoding value
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index c45757af9ade9b88ade0e427d8dbae231821..f18aba05f1c20d6f40cb54fae783fdcb03ab 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -614,7 +614,7 @@ static int ethoc_poll(struct napi_struct *napi, int budget)
 	tx_work_done = ethoc_tx(priv->netdev, budget);
 
 	if (rx_work_done < budget && tx_work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_work_done);
 		ethoc_enable_irq(priv, INT_MASK_TX | INT_MASK_RX);
 	}
 
diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 223f35cc034cf4f9846856d1cbb4c551a001..992ebe973d25bfbccff7b5c42dc1801ea41f 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -192,7 +192,7 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		u32 buf_int_enable_value = 0;
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		/* set tx_done and rx_rdy bits */
 		buf_int_enable_value |= NPS_ENET_ENABLE << RX_RDY_SHIFT;
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index b7cbc26a09113bab5700891c6a2e93ec2759..25a14a3fe784dbafc928dd22e416c86d1483 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2001,7 +2001,7 @@ static int dpaa_eth_poll(struct napi_struct *napi, int budget)
 	int cleaned = qman_p_poll_dqrr(np->p, budget);
 
 	if (cleaned < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, cleaned);
 		qman_p_irqsource_add(np->p, QM_PIRQ_DQRI);
 
 	} else if (np->down) {
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38160c2bebcb33a0214c5add50a2c71fc439..2cc552ddd8f02aba2dd07a78aac05c875232 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1615,7 +1615,7 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 	fec_enet_tx(ndev);
 
 	if (pkts < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, pkts);
 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 	}
 	return pkts;
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 1f98838f32b7772ebb1920f5f5e5644fa7b6..54e3ce9bd94cee4e6e441e24095abd3ff324 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -301,7 +301,7 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 
 	if (received < budget && tx_left) {
 		/* done */
-		napi_complete(napi);
+		napi_complete_done(napi, received);
 		(*fep->ops->napi_enable)(dev);
 
 		return received;
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c1b6716679208a69bc66f017a68e5b6e35c6..d0ebab7052256cd1f1027a5b0b2ab1179cf4 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3183,7 +3183,7 @@ static int gfar_poll_rx_sq(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		u32 imask;
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&regs->rstat, gfargrp->rstat);
 
@@ -3272,7 +3272,7 @@ static int gfar_poll_rx(struct napi_struct *napi, int budget)
 
 	if (!num_act_queues) {
 		u32 imask;
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&regs->rstat, gfargrp->rstat);
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9d660888510f3f007905eaa7f8b5dede6eea..3f7ae9f64cd8771a834b104cec0b395c473a 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3303,7 +3303,7 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
 
 	if (howmany < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, howmany);
 		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS | UCCE_TX_EVENTS);
 	}
 
diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 97b184774784beb603c27d62486e771f3a8a..6e50ec82b3d8ebbfbe51062720c510e8e0c0 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -555,7 +555,7 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
 		priv->reg_inten |= RCV_INT;
 		writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
 	}
-	napi_complete(napi);
+	napi_complete_done(napi, rx);
 done:
 	/* clean up tx descriptors and start a new timer if necessary */
 	tx_remaining = hip04_tx_reclaim(ndev, false);
diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index 979852d56f31ddb7301c7be19f2f91d922ef..2c2808830e95723604b7356514ea64ca123f 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -330,7 +330,7 @@ static int hisi_femac_poll(struct napi_struct *napi, int budget)
 	} while (ints & DEF_INT_MASK);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		hisi_femac_irq_enable(priv, DEF_INT_MASK &
 					(~IRQ_INT_TX_PER_PACKET));
 	}
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 418ca1f3774aabbd1575c934243ac938124b..25a6c8722ecacc981ff8320276c3b41943e8 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -662,7 +662,7 @@ static int hix5hd2_poll(struct napi_struct *napi, int budget)
 	} while (ints & DEF_INT_MASK);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		hix5hd2_irq_enable(priv);
 	}
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index b618be6d14cd2589b0dd183c62cc59c1137b..72ab7b6bf20b7a93eb4a6c18b14f75b2b063 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1326,7 +1326,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	ibmveth_replenish_task(adapter);
 
 	if (frames_processed < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, frames_processed);
 
 		/* We think we are done - reenable interrupts,
 		 * then check once more to make sure we are done.
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 3c2526bde7a444e89b94ff7c56b509423577..c46935d4a3fe99fadbf8b0e220b77ef5e37d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -987,7 +987,7 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 
 	if (frames_processed < budget) {
 		enable_scrq_irq(adapter, adapter->rx_scrq[scrq_num]);
-		napi_complete(napi);
+		napi_complete_done(napi, frames_processed);
 		if (pending_scrq(adapter, adapter->rx_scrq[scrq_num]) &&
 		    napi_reschedule(napi)) {
 			disable_scrq_irq(adapter, adapter->rx_scrq[scrq_num]);
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 04e939226e08eab0df8adab1af27de5dc1f9..2b7323d392dcc542430ced19c4ed5448bc27 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2253,7 +2253,7 @@ static int e100_poll(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		e100_enable_irq(nic);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5826b1ddedcfe1560de83fd5b24a6e36a4ce..fbd220d137b34ed78e059ab4c1473d1129ef 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1817,7 +1817,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 3e415b895d95136cb7231320adffcfaa520b..9fae98caf83a378da959eb0cd70211f3c5d9 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -464,7 +464,7 @@ static int korina_poll(struct napi_struct *napi, int budget)
 
 	work_done = korina_rx(dev, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		writel(readl(&lp->rx_dma_regs->dmasm) &
 			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index faea52da8dae9ea39469116bca09b513bc7e..afc81006944059837b5cbbdaaaa26d9dc87d 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -156,24 +156,21 @@ ltq_etop_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct ltq_etop_chan *ch = container_of(napi,
 				struct ltq_etop_chan, napi);
-	int rx = 0;
-	int complete = 0;
+	int work_done = 0;
 
-	while ((rx < budget) && !complete) {
+	while (work_done < budget) {
 		struct ltq_dma_desc *desc = &ch->dma.desc_base[ch->dma.desc];
 
-		if ((desc->ctl & (LTQ_DMA_OWN | LTQ_DMA_C)) == LTQ_DMA_C) {
-			ltq_etop_hw_receive(ch);
-			rx++;
-		} else {
-			complete = 1;
-		}
+		if ((desc->ctl & (LTQ_DMA_OWN | LTQ_DMA_C)) != LTQ_DMA_C)
+			break;
+		ltq_etop_hw_receive(ch);
+		work_done++;
 	}
-	if (complete || !rx) {
-		napi_complete(&ch->napi);
+	if (work_done < budget) {
+		napi_complete_done(&ch->napi, work_done);
 		ltq_dma_ack_irq(&ch->dma);
 	}
-	return rx;
+	return work_done;
 }
 
 static int
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 1fa7c03edec2fd0aa91f93dd86d7705f4a27..20cb7f0de601af8e6903ed41aaa322fd4bcc 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2319,7 +2319,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		if (mp->oom)
 			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		wrlp(mp, INT_MASK, mp->int_mask);
 	}
 
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 6dcc951af0ffba88a8ac77268879c81a43ef..de6c47744b8eb5826bf5d85e51740884bf31 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2767,11 +2767,9 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 			rx_done = mvneta_rx_swbm(pp, budget, &pp->rxqs[rx_queue]);
 	}
 
-	budget -= rx_done;
-
-	if (budget > 0) {
+	if (rx_done < budget) {
 		cause_rx_tx = 0;
-		napi_complete(napi);
+		napi_complete_done(napi, rx_done);
 
 		if (pp->neta_armada3700) {
 			unsigned long flags;
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 69db40e1a4e14536e2291b1635ba5baaf07e..c2fd7c36f9278842104b6c8a0dcee2147bae 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5405,7 +5405,7 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
 
 	if (budget > 0) {
 		cause_rx = 0;
-		napi_complete(napi);
+		napi_complete_done(napi, rx_done);
 
 		mvpp2_interrupts_enable(port);
 	}
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 3af2814ada235c124fd49f1c72f7d0a5c4af..3376a19f1e19794b90ec4c28c514b208de32 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1261,7 +1261,7 @@ static int pxa168_rx_poll(struct napi_struct *napi, int budget)
 	}
 	work_done = rxq_process(dev, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		wrl(pep, INT_MASK, ALL_INTS);
 	}
 
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 6a6525f7d2eacb91b49c08205c70fb0fc2eb..06c9f4100cb9bd8c0abecada5fa922c7e779 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -269,7 +269,7 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (rx < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx);
 	}
 
 	priv->reg_imr |= RPKT_FINISH_M;
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index db297cfce6f49ec4a44259878f1dbe7f82c8..3d881176a35392cdac0567f6dbdeb3d6b883 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1678,7 +1678,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 
 	myri10ge_ss_unlock_napi(ss);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 90eac63f9606a446f696bf120379f19776b6..8e72679c015f925431befaad716c586d99cc 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -2265,7 +2265,7 @@ static int natsemi_poll(struct napi_struct *napi, int budget)
 		np->intr_status = readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 564f682fa4dc326dba8f5bc142a62c881479..203abcb0c25202099002e7af13846c1d24de 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2783,7 +2783,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	s2io_chk_rx_buffers(nic, ring);
 
 	if (pkts_processed < budget_org) {
-		napi_complete(napi);
+		napi_complete_done(napi, pkts_processed);
 		/*Re Enable MSI-Rx Vector*/
 		addr = (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr += 7 - ring->ring_no;
@@ -2817,7 +2817,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 			break;
 	}
 	if (pkts_processed < budget_org) {
-		napi_complete(napi);
+		napi_complete_done(napi, pkts_processed);
 		/* Re enable the Rx interrupts for the ring */
 		writeq(0, &bar0->rx_traffic_mask);
 		readl(&bar0->rx_traffic_mask);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index f364502229db58a8f6180a2a5b84230a8b7f..6a4310af5d970eae8821357c61701847804d 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -1823,8 +1823,8 @@ static int vxge_poll_msix(struct napi_struct *napi, int budget)
 	vxge_hw_vpath_poll_rx(ring->handle);
 	pkts_processed = ring->pkts_processed;
 
-	if (ring->pkts_processed < budget_org) {
-		napi_complete(napi);
+	if (pkts_processed < budget_org) {
+		napi_complete_done(napi, pkts_processed);
 
 		/* Re enable the Rx interrupts for the vpath */
 		vxge_hw_channel_msix_unmask(
@@ -1863,7 +1863,7 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
 	VXGE_COMPLETE_ALL_TX(vdev);
 
 	if (pkts_processed < budget_org) {
-		napi_complete(napi);
+		napi_complete_done(napi, pkts_processed);
 		/* Re enable the Rx interrupts for the ring */
 		vxge_hw_device_unmask_all(hldev);
 		vxge_hw_device_flush_io(hldev);
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index dfc2c8149d222b789bbf29eaa121bb70b54e..58ba5d3f9e5f7ecb1dba965a203caa4e8472 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3749,7 +3749,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	if (rx_work < budget) {
 		/* re-enable interrupts
 		   (msix not enabled in napi) */
-		napi_complete(napi);
+		napi_complete_done(napi, rx_work);
 
 		writel(np->irqmask, base + NvRegIrqMask);
 	}
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index dd6b0d0f7fa504e33cbb873546137bf1d89e..9c7ffd649e9a460a4519a0cecd7a3e936715 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -999,7 +999,7 @@ static int lpc_eth_poll(struct napi_struct *napi, int budget)
 	rx_done = __lpc_handle_recv(ndev, budget);
 
 	if (rx_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_done);
 		lpc_eth_enable_int(pldat->net_base);
 	}
 
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index d461f419948ea4179c161786047050a44ba4..f9e4e8eca6657e548299774920cb82ecb735 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2385,7 +2385,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 		poll_end_flag = true;
 
 	if (poll_end_flag) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		pch_gbe_irq_enable(adapter);
 	}
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index badfa1d562a41e9860ccd425addf936f78b2..49591d9c2e1b9f4bde7217e750396d99f032 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1575,7 +1575,7 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	pkts = pasemi_mac_clean_rx(rx_ring(mac), budget);
 	if (pkts < budget) {
 		/* all done, no more packets present */
-		napi_complete(napi);
+		napi_complete_done(napi, pkts);
 
 		pasemi_mac_restart_rx_intr(mac);
 		pasemi_mac_restart_tx_intr(mac);
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 86fb9d3df700430ad84ded7b3564816d8a74..0cf8a3703275123e0b93ce2834a4b7ec6414 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2396,7 +2396,7 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 		work_done = budget;
 
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		if (test_bit(__NX_DEV_UP, &adapter->state))
 			netxen_nic_enable_int(sds_ring);
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 445d4d2492c3080cae307e6c95e54de1fbc1..26848eed3bc1d2bc0a19df5d5b0411d49b38 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -1372,7 +1372,7 @@ int qede_poll(struct napi_struct *napi, int budget)
 			qede_rx_int(fp, budget) : 0;
 	if (rx_work_done < budget) {
 		if (!qede_poll_is_more_work(fp)) {
-			napi_complete(napi);
+			napi_complete_done(napi, rx_work_done);
 
 			/* Update and reenable interrupts */
 			qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index fedd7366713cf04da3ceb7fff1704d74fb3e..84dd83031a1bfcc31c0f8a908fef0c1bb3e7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -975,7 +975,7 @@ static int qlcnic_poll(struct napi_struct *napi, int budget)
 		work_done = budget;
 
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 			qlcnic_enable_sds_intr(adapter, sds_ring);
 			qlcnic_enable_tx_intr(adapter, tx_ring);
@@ -1019,7 +1019,7 @@ static int qlcnic_rx_poll(struct napi_struct *napi, int budget)
 	work_done = qlcnic_process_rcv_ring(sds_ring, budget);
 
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 			qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
@@ -1966,7 +1966,7 @@ static int qlcnic_83xx_msix_sriov_vf_poll(struct napi_struct *napi, int budget)
 		work_done = budget;
 
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
 
@@ -1994,7 +1994,7 @@ static int qlcnic_83xx_poll(struct napi_struct *napi, int budget)
 		work_done = budget;
 
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
 
@@ -2032,7 +2032,7 @@ static int qlcnic_83xx_rx_poll(struct napi_struct *napi, int budget)
 	adapter = sds_ring->adapter;
 	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
 	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
+		napi_complete_done(&sds_ring->napi, work_done);
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 			qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 1409412ab39da7a7a58e3100fdd8461b8b87..e9e647072596d5c6e3c6206fb003b66bfe3c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2334,7 +2334,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index f519351ef3a2834c0f858310d24650a4b63f..3387c0a8874634f4caa771837a1167679746 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -129,7 +129,7 @@ static int emac_napi_rtx(struct napi_struct *napi, int budget)
 	emac_mac_rx_process(adpt, rx_q, &work_done, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		irq->mask |= rx_q->intr;
 		writel(irq->mask, adpt->base + EMAC_INT_MASK);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6073f466f6e814102aca5112b811a475a1e0..81f18a8335276495a59fa93219c4607c2b8a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7583,7 +7583,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		rtl_irq_enable(tp, enable_mask);
 		mmiowb();
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 7c450b5a1138e28b41b23bf48d5c5ce65f18..0f63a44a955deb4de7b8da6c69b5dd6125d1 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2517,7 +2517,7 @@ static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
 	}
 
 	if (credits < budget)
-		napi_complete(napi);
+		napi_complete_done(napi, credits);
 
 	rocker_dma_ring_credits_set(rocker, &rocker_port->rx_ring, credits);
 
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 07074d9bc45dff59e1b84c33b3993d59ae3d..d54490d3f7ad3228dc561fb58a51b1420422 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1563,7 +1563,7 @@ static int sxgbe_poll(struct napi_struct *napi, int budget)
 
 	work_done = sxgbe_rx(priv, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		priv->hw->dma->enable_dma_irq(priv->ioaddr, qnum);
 	}
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index f2ec853e356d9cb27b331ae3880155cf1758..466c02805f72a7d1d19a6a342cd8026f20e4 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -331,7 +331,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		 * since efx_nic_eventq_read_ack() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		napi_complete(napi);
+		napi_complete_done(napi, spent);
 		efx_nic_eventq_read_ack(channel);
 	}
 
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index 8cfbe01e1ddf9f86ac0993ced8104dcb264d..c4ff3bb1a1ef48724f851b571fd206ae72d2 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -327,7 +327,7 @@ static int ef4_poll(struct napi_struct *napi, int budget)
 		 * since ef4_nic_eventq_read_ack() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		napi_complete(napi);
+		napi_complete_done(napi, spent);
 		ef4_nic_eventq_read_ack(channel);
 	}
 
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 3174aebb322fe98e00a93466840aae2de7db..2fa3c1d03abc591f70ac857f2f3665e5e0ee 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -861,7 +861,7 @@ static int smsc9420_rx_poll(struct napi_struct *napi, int budget)
 	smsc9420_pci_flush_write(pd);
 
 	if (work_done < budget) {
-		napi_complete(&pd->napi);
+		napi_complete_done(&pd->napi, work_done);
 
 		/* re-enable RX DMA interrupts */
 		dma_intr_ena = smsc9420_reg_read(pd, DMAC_INTR_ENA);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 38e1fb75490ef95776fdc117ae651aaaf989..26a2185fc8a9ba4a6d25d081ddbbec94e51d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2684,7 +2684,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 
 	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		stmmac_enable_dma_irq(priv);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index e557a3290a2544b51ec7b23f1c612d251cd3..57978056b3366f0ecb0410f96dbfbde228ea 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3786,7 +3786,7 @@ static int niu_poll(struct napi_struct *napi, int budget)
 	work_done = niu_poll_core(np, lp, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		niu_ldg_rearm(np, lp, 1);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index d277e410797694f3e8dd8cd40430cd23e114..5c5952e782cd223c0aee844d414ee6c749c3 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -922,7 +922,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	gem_enable_ints(gp);
 
 	return work_done;
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 8878b75d68b4ddec99fb014e0e51cd910813..191c8ade6155b20769fb07167e1d770adfb1 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -860,7 +860,7 @@ int sunvnet_poll_common(struct napi_struct *napi, int budget)
 	int processed = vnet_event_napi(port, budget);
 
 	if (processed < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 		port->rx_event &= ~LDC_EVENT_DATA_READY;
 		vio_set_intr(vio->vdev->rx_ino, HV_INTR_ENABLED);
 	}
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index baa3e4a5731c7388c3f97a4e2e7be31a7df6..f864fd0663dbf830bd94b1db4daa7a7b5ad3 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -303,7 +303,7 @@ static int bdx_poll(struct napi_struct *napi, int budget)
 		 * device lock and allow waiting tasks (eg rmmod) to advance) */
 		priv->napi_stop = 0;
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		bdx_enable_interrupts(priv);
 	}
 	return work_done;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 897ebbe502251b6b9392e2930639cc224878..67b7323b69074018d52bd51a5db1c44a97d0 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -942,7 +942,7 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 	}
 
 	if (num_rx < budget) {
-		napi_complete(napi_rx);
+		napi_complete_done(napi_rx, num_rx);
 		writel(0xff, &cpsw->wr_regs->rx_en);
 		if (cpsw->quirk_irq && cpsw->rx_irq_disabled) {
 			cpsw->rx_irq_disabled = false;
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 481c7bf0395bfcdc3add56da8b01b6143241..64d5527feb2ac20c3229c667d806039050f0 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1295,7 +1295,7 @@ static int emac_poll(struct napi_struct *napi, int budget)
 					&emac_rxhost_errcodes[cause][0], ch);
 		}
 	} else if (num_rx_pkts < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, num_rx_pkts);
 		emac_int_enable(priv);
 	}
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 2b56eed249f7108e7cd584df796720c4a4c9..ebab1473f36609da6c9f1da30acd3e7c03c0 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -969,7 +969,7 @@ static int netcp_rx_poll(struct napi_struct *napi, int budget)
 
 	netcp_rxpool_refill(netcp);
 	if (packets < budget) {
-		napi_complete(&netcp->rx_napi);
+		napi_complete_done(&netcp->rx_napi, packets);
 		knav_queue_enable_notify(netcp->rx_queue);
 	}
 
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 2255f9a6f3bc28ee0d712b464137ecc7784e..7c634bc75615870e33c50ad0c514c9339333 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -681,7 +681,7 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 	}
 
 	/* There are no packets left. */
-	napi_complete(&info_mpipe->napi);
+	napi_complete_done(&info_mpipe->napi, work);
 
 	md = &mpipe_data[instance];
 	/* Re-enable hypervisor interrupts. */
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 44f1537137912676e1149054bb1858a57e17..49ccee4b9aeccc3b6cd165b461d448f0aba7 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -842,7 +842,7 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	napi_complete(&info->napi);
+	napi_complete_done(&info->napi, work);
 
 	if (!priv->active)
 		goto done;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 345316c749e761a168d4364362770f90441e..72013314bba81fbbbb0f7d37da6143a9b075 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1109,7 +1109,7 @@ static int gelic_net_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (packets_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, packets_done);
 		gelic_card_rx_irq_on(card);
 	}
 	return packets_done;
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index cb341dfe65ad562d78ad9ac4ad0bade83e2b..cec9e70ab9955d4c3f7cef2219aa56593ac3 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -1270,7 +1270,7 @@ static int spider_net_poll(struct napi_struct *napi, int budget)
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (packets_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, packets_done);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull = 0;
 	}
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 3be61ed28741ae7d763322c7d28c81cc69f2..a45f98fa4aa70a6ce0c693bef2fda248754a 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -1638,7 +1638,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	spin_unlock(&lp->rx_lock);
 
 	if (received < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, received);
 		/* enable interrupts */
 		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
 	}
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index f153ad729ce5b20cefe8c98ffb6f82761062..c5583991da4aa462652b5236992c77315294 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -887,7 +887,7 @@ static int tsi108_poll(struct napi_struct *napi, int budget)
 
 	if (num_received < budget) {
 		data->rxpending = 0;
-		napi_complete(napi);
+		napi_complete_done(napi, num_received);
 
 		TSI_WRITE(TSI108_EC_INTMASK,
 				     TSI_READ(TSI108_EC_INTMASK)
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 453a1fad560c73fb89f72d2b7b9e2af5566e..c068c58428f7611ddcd526010cb07f8ada61 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -861,7 +861,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		iowrite16(enable_mask, ioaddr + IntrEnable);
 		mmiowb();
 	}
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4716e60e2ccbbc7c9aae9c168638a70c07ed..d088788b27a751286f7556b7f478b210c0ab 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2160,7 +2160,7 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	velocity_tx_srv(vptr);
 	/* If budget not fully consumed, exit the polling mode */
 	if (rx_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_done);
 		mac_enable_int(vptr->mac_regs);
 	}
 	spin_unlock_irqrestore(&vptr->lock, flags);
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index e1296ef2cf66183d7c8596184c69f122f7d5..f90267f0519feebb7c9d944535cb81f53c6b 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -915,7 +915,7 @@ static int w5100_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (rx_count < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_count);
 		w5100_enable_intr(priv);
 	}
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 724fabd38a23edd6473cdf7ab712c0c54e4a..56ae573001e8e76c8cbd5300ad4fca4873cb 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -417,7 +417,7 @@ static int w5300_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (rx_count < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rx_count);
 		w5300_write(priv, W5300_IMR, IR_S0);
 		mmiowb();
 	}
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 5028001429c7a47affcf76fd534dde3f26d2..b75d9cdcfb0c415c7abeaa97cebeacbc917e 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1155,7 +1155,7 @@ static int fjes_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		if (adapter->unset_rx_last) {
 			adapter->rx_last_jiffies = jiffies;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index e34b1297c96af96e6a9d6a6841c4bbc24e74..25bc764ae7dc4c4dc9a5e6cb4f17f89f6246 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1851,7 +1851,7 @@ vmxnet3_poll(struct napi_struct *napi, int budget)
 	rxd_done = vmxnet3_do_poll(rx_queue->adapter, budget);
 
 	if (rxd_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rxd_done);
 		vmxnet3_enable_all_intrs(rx_queue->adapter);
 	}
 	return rxd_done;
@@ -1882,7 +1882,7 @@ vmxnet3_poll_rx_only(struct napi_struct *napi, int budget)
 	rxd_done = vmxnet3_rq_rx_complete(rq, adapter, budget);
 
 	if (rxd_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, rxd_done);
 		vmxnet3_enable_intr(adapter, rq->comp_ring.intr_idx);
 	}
 	return rxd_done;
diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index e38ce4da3efbf8af30c89556e8a896e1c531..d869533d2e79e893ddec7b6c7c32a0c3e112 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -573,7 +573,7 @@ static int ucc_hdlc_poll(struct napi_struct *napi, int budget)
 	howmany += hdlc_rx_done(priv, budget - howmany);
 
 	if (howmany < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, howmany);
 		qe_setbits32(priv->uccf->p_uccm,
 			     (UCCE_HDLC_RX_EVENTS | UCCE_HDLC_TX_EVENTS) << 16);
 	}
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index 7ef49dab68556b9309293383844a530a18db..cff0cfadd650cbc7472a03d9baba6ca55013 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -341,7 +341,7 @@ static int sca_poll(struct napi_struct *napi, int budget)
 		received = sca_rx_done(port, budget);
 
 	if (received < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, received);
 		enable_intr(port);
 	}
 
diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 93b9790cfe8dc1e4c7c619d56ee3a88d3a99..e757c514e2b7f4b129b34a4b10fbe18e64f0 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -2799,7 +2799,7 @@ static int ath10k_pci_napi_poll(struct napi_struct *ctx, int budget)
 	done = ath10k_htt_txrx_compl_task(ar, budget);
 
 	if (done < budget) {
-		napi_complete(ctx);
+		napi_complete_done(ctx, done);
 		/* In case of MSI, it is possible that interrupts are received
 		 * while NAPI poll is inprogress. So pending interrupts that are
 		 * received after processing all copy engine pipes by NAPI poll
diff --git a/drivers/net/wireless/ath/wil6210/netdev.c b/drivers/net/wireless/ath/wil6210/netdev.c
index 6676001dcbcadcd689099a42658640c2a2b8..cab5334e4f9d46a6394181988a69c25183c6 100644
--- a/drivers/net/wireless/ath/wil6210/netdev.c
+++ b/drivers/net/wireless/ath/wil6210/netdev.c
@@ -68,7 +68,7 @@ static int wil6210_netdev_poll_rx(struct napi_struct *napi, int budget)
 	done = budget - quota;
 
 	if (done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, done);
 		wil6210_unmask_irq_rx(wil);
 		wil_dbg_txrx(wil, "NAPI RX complete\n");
 	}
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 579521327b0357d87dcc1baa4e0ff801e140..1073b27e54aab04bc2a32590fd9d1fc35fe5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -104,7 +104,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	work_done = xenvif_tx_action(queue, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		xenvif_napi_schedule_or_enable_events(queue);
 	}
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 2c7c29fa268d6eb1e7a865590edd5c01f087..cf82b5b42056ed03c86fb9d675efb0fbb2f0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1051,7 +1051,7 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		int more_to_do = 0;
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
 		if (more_to_do)
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index f0900d1c4d7b5fe63a04a917b60b37d0dba9..fc849d4a1b5d201cbedb7d718fa551990367 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -429,7 +429,7 @@ static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
 
 	if (rx_count < budget) {
 		/* No more work */
-		napi_complete(napi);
+		napi_complete_done(napi, rx_count);
 		enable_irq(rx_group->irq);
 	}
 	return rx_count;
diff --git a/drivers/staging/unisys/visornic/visornic_main.c b/drivers/staging/unisys/visornic/visornic_main.c
index c1f674f5268c2421c7f925d45f150a139264..ca3743d273e0862e45324d155a8cc3960e3f 100644
--- a/drivers/staging/unisys/visornic/visornic_main.c
+++ b/drivers/staging/unisys/visornic/visornic_main.c
@@ -1657,7 +1657,7 @@ static int visornic_poll(struct napi_struct *napi, int budget)
 
 	/* If there aren't any more packets to receive stop the poll */
 	if (rx_count < budget)
-		napi_complete(napi);
+		napi_complete_done(napi, rx_count);
 
 	return rx_count;
 }
-- 
2.11.0.483.g087da7b7c-goog
