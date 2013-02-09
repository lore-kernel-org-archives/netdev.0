From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC PATCH] dma_alloc_consistent: Remove OOM messages after failure
Date: Sat, 09 Feb 2013 13:45:56 -0800
Message-ID: <1360446356.23616.11.camel@joe-AO722>
References: <1360273587.27863.15.camel@joe-AO722>
	 <20130208.174500.1518593039138341685.davem@davemloft.net>
	 <1360369799.13487.5.camel@joe-AO722> <20130209004644.GC31290@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130209004644.GC31290-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-08 at 16:46 -0800, Greg KH wrote:
> On Fri, Feb 08, 2013 at 04:29:59PM -0800, Joe Perches wrote:
> > Does anyone know if all the other alloc's like
> > dma_alloc_coherent, dma_alloc_noncoherent,
> > pci_alloc_consistent always produce OOM messages
> > via page_alloc/warn_alloc_failed for all arches?
> 
> If not, they should, to allow this type of cleanups.

As far as I can tell, the x86 arches do warn.

Maybe all of the OOM messages should just be
deleted and let's see if anyone complains.

Perhaps also the memsets to zero following the
allocs could be removed by adding __GFP_ZERO
instead of introducing new functions/macros
like dma_zalloc_consistent.

For instance, maybe something like this for the
dma_alloc_consistent cases:

-------------------------------------

dma_alloc_consistent for x86 already gets a
standardized OOM message and a dump_stack() which
makes the specific OOM message unnecessary.

Remove those dma_alloc_consistent OOM messages.

For the code involved with the alloc:

Remove unnecessary casts.
Align arguments.
Replace any memset to 0 with __GFP_ZERO.
Miscellaneous whitespace neatening.
---
 drivers/net/ethernet/aeroflex/greth.c              | 24 +++-------
 drivers/net/ethernet/amd/sunlance.c                |  5 +-
 drivers/net/ethernet/apple/macmace.c               | 16 +++----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       | 10 ++--
 drivers/net/ethernet/broadcom/bnx2.c               |  5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  9 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    | 14 +++---
 drivers/net/ethernet/broadcom/tg3.c                | 11 ++---
 drivers/net/ethernet/brocade/bna/bnad.c            |  5 +-
 drivers/net/ethernet/cadence/at91_ether.c          | 18 +++-----
 drivers/net/ethernet/dec/tulip/xircom_cb.c         |  9 ++--
 drivers/net/ethernet/emulex/benet/be_cmds.c        |  4 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |  9 +---
 drivers/net/ethernet/emulex/benet/be_main.c        | 20 +++-----
 drivers/net/ethernet/faraday/ftgmac100.c           |  5 +-
 drivers/net/ethernet/faraday/ftmac100.c            |  8 ++--
 drivers/net/ethernet/freescale/fec.c               |  6 +--
 drivers/net/ethernet/freescale/gianfar.c           | 13 +++---
 drivers/net/ethernet/ibm/emac/mal.c                |  9 +---
 drivers/net/ethernet/ibm/ibmveth.c                 |  6 +--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |  6 +--
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  7 ---
 drivers/net/ethernet/intel/igbvf/netdev.c          |  2 -
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        | 11 +----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  4 --
 drivers/net/ethernet/marvell/mvneta.c              | 14 +-----
 drivers/net/ethernet/marvell/pxa168_eth.c          | 27 +++++------
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  7 ++-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  3 +-
 drivers/net/ethernet/natsemi/jazzsonic.c           | 12 ++---
 drivers/net/ethernet/natsemi/macsonic.c            | 12 ++---
 drivers/net/ethernet/natsemi/xtsonic.c             | 12 ++---
 drivers/net/ethernet/nuvoton/w90p910_ether.c       | 19 +++-----
 drivers/net/ethernet/nxp/lpc_eth.c                 |  2 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 21 ++++-----
 drivers/net/ethernet/pasemi/pasemi_mac.c           |  5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 53 +++++++---------------
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  5 +-
 drivers/net/ethernet/renesas/sh_eth.c              |  9 +---
 drivers/net/ethernet/sfc/nic.c                     |  4 +-
 drivers/net/ethernet/sgi/meth.c                    |  5 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 24 ++++------
 drivers/net/ethernet/sun/sunbmac.c                 |  4 +-
 drivers/net/ethernet/sun/sunhme.c                  | 13 ++----
 drivers/net/ethernet/toshiba/spider_net.c          |  3 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           | 21 ++-------
 drivers/net/ethernet/xilinx/ll_temac_main.c        | 17 ++-----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  | 16 ++-----
 drivers/net/fddi/defxx.c                           |  9 ++--
 drivers/net/irda/ali-ircc.c                        |  6 +--
 drivers/net/irda/bfin_sir.c                        |  3 +-
 drivers/net/irda/nsc-ircc.c                        |  6 +--
 drivers/net/irda/pxaficp_ir.c                      |  4 +-
 drivers/net/irda/smsc-ircc2.c                      | 25 ++++------
 drivers/net/irda/via-ircc.c                        |  6 +--
 drivers/net/irda/w83977af_ir.c                     |  7 +--
 drivers/net/wireless/ath/wil6210/txrx.c            |  2 -
 drivers/net/wireless/b43/dma.c                     |  9 +---
 drivers/net/wireless/b43legacy/dma.c               |  8 +---
 drivers/net/wireless/iwlegacy/3945.c               |  9 ++--
 drivers/net/wireless/iwlegacy/4965-mac.c           |  4 +-
 drivers/net/wireless/iwlegacy/common.c             | 19 ++++----
 drivers/net/wireless/iwlegacy/common.h             |  5 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  5 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |  4 +-
 65 files changed, 227 insertions(+), 448 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 0be2195..2692954 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1464,35 +1464,23 @@ static int greth_of_probe(struct platform_device *ofdev)
 	}
 
 	/* Allocate TX descriptor ring in coherent memory */
-	greth->tx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
-								   1024,
-								   &greth->tx_bd_base_phys,
-								   GFP_KERNEL);
-
+	greth->tx_bd_base = dma_alloc_coherent(greth->dev, 1024,
+					       &greth->tx_bd_base_phys,
+					       GFP_KERNEL | __GFP_ZERO);
 	if (!greth->tx_bd_base) {
-		if (netif_msg_probe(greth))
-			dev_err(&dev->dev, "could not allocate descriptor memory.\n");
 		err = -ENOMEM;
 		goto error3;
 	}
 
-	memset(greth->tx_bd_base, 0, 1024);
-
 	/* Allocate RX descriptor ring in coherent memory */
-	greth->rx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
-								   1024,
-								   &greth->rx_bd_base_phys,
-								   GFP_KERNEL);
-
+	greth->rx_bd_base = dma_alloc_coherent(greth->dev, 1024,
+					       &greth->rx_bd_base_phys,
+					       GFP_KERNEL | __GFP_ZERO);
 	if (!greth->rx_bd_base) {
-		if (netif_msg_probe(greth))
-			dev_err(greth->dev, "could not allocate descriptor memory.\n");
 		err = -ENOMEM;
 		goto error4;
 	}
 
-	memset(greth->rx_bd_base, 0, 1024);
-
 	/* Get MAC address from: module param, OF property or ID prom */
 	for (i = 0; i < 6; i++) {
 		if (macaddr[i] != 0)
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 6a40290..3d17013 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1377,10 +1377,9 @@ static int sparc_lance_probe_one(struct platform_device *op,
 			dma_alloc_coherent(&op->dev,
 					   sizeof(struct lance_init_block),
 					   &lp->init_block_dvma, GFP_ATOMIC);
-		if (!lp->init_block_mem) {
-			printk(KERN_ERR "SunLance: Cannot allocate consistent DMA memory.\n");
+		if (!lp->init_block_mem)
 			goto fail;
-		}
+
 		lp->pio_buffer = 0;
 		lp->init_ring = lance_init_ring_dvma;
 		lp->rx = lance_rx_dvma;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index a206779..4ce8ceb 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -386,20 +386,16 @@ static int mace_open(struct net_device *dev)
 	/* Allocate the DMA ring buffers */
 
 	mp->tx_ring = dma_alloc_coherent(mp->device,
-			N_TX_RING * MACE_BUFF_SIZE,
-			&mp->tx_ring_phys, GFP_KERNEL);
-	if (mp->tx_ring == NULL) {
-		printk(KERN_ERR "%s: unable to allocate DMA tx buffers\n", dev->name);
+					 N_TX_RING * MACE_BUFF_SIZE,
+					 &mp->tx_ring_phys, GFP_KERNEL);
+	if (mp->tx_ring == NULL)
 		goto out1;
-	}
 
 	mp->rx_ring = dma_alloc_coherent(mp->device,
-			N_RX_RING * MACE_BUFF_SIZE,
-			&mp->rx_ring_phys, GFP_KERNEL);
-	if (mp->rx_ring == NULL) {
-		printk(KERN_ERR "%s: unable to allocate DMA rx buffers\n", dev->name);
+					 N_RX_RING * MACE_BUFF_SIZE,
+					 &mp->rx_ring_phys, GFP_KERNEL);
+	if (mp->rx_ring == NULL)
 		goto out2;
-	}
 
 	mace_dma_off(dev);
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 7d81e05..dec19972 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -862,27 +862,25 @@ static int bcm_enet_open(struct net_device *dev)
 
 	/* allocate rx dma ring */
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
+	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma,
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!p) {
-		dev_err(kdev, "cannot allocate rx ring %u\n", size);
 		ret = -ENOMEM;
 		goto out_freeirq_tx;
 	}
 
-	memset(p, 0, size);
 	priv->rx_desc_alloc_size = size;
 	priv->rx_desc_cpu = p;
 
 	/* allocate tx dma ring */
 	size = priv->tx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
+	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma,
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!p) {
-		dev_err(kdev, "cannot allocate tx ring\n");
 		ret = -ENOMEM;
 		goto out_free_rx_ring;
 	}
 
-	memset(p, 0, size);
 	priv->tx_desc_alloc_size = size;
 	priv->tx_desc_cpu = p;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2f0ba8f..e709296 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -854,12 +854,11 @@ bnx2_alloc_mem(struct bnx2 *bp)
 				sizeof(struct statistics_block);
 
 	status_blk = dma_alloc_coherent(&bp->pdev->dev, bp->status_stats_size,
-					&bp->status_blk_mapping, GFP_KERNEL);
+					&bp->status_blk_mapping,
+					GFP_KERNEL | __GFP_ZERO);
 	if (status_blk == NULL)
 		goto alloc_mem_err;
 
-	memset(status_blk, 0, bp->status_stats_size);
-
 	bnapi = &bp->bnx2_napi[0];
 	bnapi->status_blk.msi = status_blk;
 	bnapi->hw_tx_cons_ptr =
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e4605a9..d7a4ae5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1944,12 +1944,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 			    bool is_pf);
 
-#define BNX2X_ILT_ZALLOC(x, y, size) \
-	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
-		if (x) \
-			memset(x, 0, size); \
-	} while (0)
+#define BNX2X_ILT_ZALLOC(x, y, size)				\
+	x = dma_alloc_coherent(&bp->pdev->dev, size, y,		\
+			       GFP_KERNEL | __GFP_ZERO)
 
 #define BNX2X_ILT_FREE(x, y, size) \
 	do { \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index aee7671..3c4854a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -50,13 +50,13 @@ extern int int_mode;
 		} \
 	} while (0)
 
-#define BNX2X_PCI_ALLOC(x, y, size) \
-	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
-		if (x == NULL) \
-			goto alloc_mem_err; \
-		memset((void *)x, 0, size); \
-	} while (0)
+#define BNX2X_PCI_ALLOC(x, y, size)				\
+do {								\
+	x = dma_alloc_coherent(&bp->pdev->dev, size, y,		\
+			       GFP_KERNEL | __GFP_ZERO);	\
+	if (x == NULL)						\
+		goto alloc_mem_err;				\
+} while (0)
 
 #define BNX2X_ALLOC(x, size) \
 	do { \
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b1b3bc0..6d31c1f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8036,11 +8036,9 @@ static int tg3_mem_rx_acquire(struct tg3 *tp)
 		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
 						   TG3_RX_RCB_RING_BYTES(tp),
 						   &tnapi->rx_rcb_mapping,
-						   GFP_KERNEL);
+						   GFP_KERNEL | __GFP_ZERO);
 		if (!tnapi->rx_rcb)
 			goto err_out;
-
-		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	}
 
 	return 0;
@@ -8090,12 +8088,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 	tp->hw_stats = dma_alloc_coherent(&tp->pdev->dev,
 					  sizeof(struct tg3_hw_stats),
 					  &tp->stats_mapping,
-					  GFP_KERNEL);
+					  GFP_KERNEL | __GFP_ZERO);
 	if (!tp->hw_stats)
 		goto err_out;
 
-	memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
-
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		struct tg3_hw_status *sblk;
@@ -8103,11 +8099,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		tnapi->hw_status = dma_alloc_coherent(&tp->pdev->dev,
 						      TG3_HW_STATUS_SIZE,
 						      &tnapi->status_mapping,
-						      GFP_KERNEL);
+						      GFP_KERNEL | __GFP_ZERO);
 		if (!tnapi->hw_status)
 			goto err_out;
 
-		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 		sblk = tnapi->hw_status;
 
 		if (tg3_flag(tp, ENABLE_RSS)) {
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 7cce42d..d588f84 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1264,9 +1264,8 @@ bnad_mem_alloc(struct bnad *bnad,
 			mem_info->mdl[i].len = mem_info->len;
 			mem_info->mdl[i].kva =
 				dma_alloc_coherent(&bnad->pcidev->dev,
-						mem_info->len, &dma_pa,
-						GFP_KERNEL);
-
+						   mem_info->len, &dma_pa,
+						   GFP_KERNEL);
 			if (mem_info->mdl[i].kva == NULL)
 				goto err_return;
 
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3becdb2..b15fafec 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -47,22 +47,18 @@ static int at91ether_start(struct net_device *dev)
 	int i;
 
 	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * sizeof(struct macb_dma_desc),
-					&lp->rx_ring_dma, GFP_KERNEL);
-	if (!lp->rx_ring) {
-		netdev_err(dev, "unable to alloc rx ring DMA buffer\n");
+					 MAX_RX_DESCR * sizeof(struct macb_dma_desc),
+					 &lp->rx_ring_dma, GFP_KERNEL);
+	if (!lp->rx_ring)
 		return -ENOMEM;
-	}
 
 	lp->rx_buffers = dma_alloc_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * MAX_RBUFF_SZ,
-					&lp->rx_buffers_dma, GFP_KERNEL);
+					    MAX_RX_DESCR * MAX_RBUFF_SZ,
+					    &lp->rx_buffers_dma, GFP_KERNEL);
 	if (!lp->rx_buffers) {
-		netdev_err(dev, "unable to alloc rx data DMA buffer\n");
-
 		dma_free_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * sizeof(struct macb_dma_desc),
-					lp->rx_ring, lp->rx_ring_dma);
+				  MAX_RX_DESCR * sizeof(struct macb_dma_desc),
+				  lp->rx_ring, lp->rx_ring_dma);
 		lp->rx_ring = NULL;
 		return -ENOMEM;
 	}
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 88feced..cdbcd16 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -236,17 +236,14 @@ static int xircom_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	private->rx_buffer = dma_alloc_coherent(d, 8192,
 						&private->rx_dma_handle,
 						GFP_KERNEL);
-	if (private->rx_buffer == NULL) {
-		pr_err("%s: no memory for rx buffer\n", __func__);
+	if (private->rx_buffer == NULL)
 		goto rx_buf_fail;
-	}
+
 	private->tx_buffer = dma_alloc_coherent(d, 8192,
 						&private->tx_dma_handle,
 						GFP_KERNEL);
-	if (private->tx_buffer == NULL) {
-		pr_err("%s: no memory for tx buffer\n", __func__);
+	if (private->tx_buffer == NULL)
 		goto tx_buf_fail;
-	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8b04880..b8bec58 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2668,10 +2668,8 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
 	cmd.size = sizeof(struct be_cmd_req_set_mac_list);
 	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size,
 			&cmd.dma, GFP_KERNEL);
-	if (!cmd.va) {
-		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
+	if (!cmd.va)
 		return -ENOMEM;
-	}
 
 	spin_lock_bh(&adapter->mcc_lock);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 76b302f..a50703c 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -719,10 +719,8 @@ be_test_ddr_dma(struct be_adapter *adapter)
 	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
 	ddrdma_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, ddrdma_cmd.size,
 					   &ddrdma_cmd.dma, GFP_KERNEL);
-	if (!ddrdma_cmd.va) {
-		dev_err(&adapter->pdev->dev, "Memory allocation failure\n");
+	if (!ddrdma_cmd.va)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < 2; i++) {
 		ret = be_cmd_ddr_dma_test(adapter, pattern[i],
@@ -845,11 +843,8 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	eeprom_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, eeprom_cmd.size,
 					   &eeprom_cmd.dma, GFP_KERNEL);
 
-	if (!eeprom_cmd.va) {
-		dev_err(&adapter->pdev->dev,
-			"Memory allocation failure. Could not read eeprom\n");
+	if (!eeprom_cmd.va)
 		return -ENOMEM;
-	}
 
 	status = be_cmd_get_seeprom_data(adapter, &eeprom_cmd);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3860888..b8a8da5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -146,10 +146,9 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	q->entry_size = entry_size;
 	mem->size = len * entry_size;
 	mem->va = dma_alloc_coherent(&adapter->pdev->dev, mem->size, &mem->dma,
-				     GFP_KERNEL);
+				     GFP_KERNEL | __GFP_ZERO);
 	if (!mem->va)
 		return -ENOMEM;
-	memset(mem->va, 0, mem->size);
 	return 0;
 }
 
@@ -2562,10 +2561,9 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
 	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
-				    GFP_KERNEL);
+				    GFP_KERNEL | __GFP_ZERO);
 	if (cmd.va == NULL)
 		return -1;
-	memset(cmd.va, 0, cmd.size);
 
 	if (enable) {
 		status = pci_write_config_dword(adapter->pdev,
@@ -3457,11 +3455,9 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	flash_cmd.size = sizeof(struct lancer_cmd_req_write_object)
 				+ LANCER_FW_DOWNLOAD_CHUNK;
 	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
-						&flash_cmd.dma, GFP_KERNEL);
+					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
 		status = -ENOMEM;
-		dev_err(&adapter->pdev->dev,
-			"Memory allocation failure while flashing\n");
 		goto lancer_fw_exit;
 	}
 
@@ -3563,8 +3559,6 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
 		status = -ENOMEM;
-		dev_err(&adapter->pdev->dev,
-			"Memory allocation failure while flashing\n");
 		goto be_fw_exit;
 	}
 
@@ -3783,12 +3777,13 @@ static int be_ctrl_init(struct be_adapter *adapter)
 
 	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
 	rx_filter->va = dma_alloc_coherent(&adapter->pdev->dev, rx_filter->size,
-					&rx_filter->dma, GFP_KERNEL);
+					   &rx_filter->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (rx_filter->va == NULL) {
 		status = -ENOMEM;
 		goto free_mbox;
 	}
-	memset(rx_filter->va, 0, rx_filter->size);
+
 	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
@@ -3830,10 +3825,9 @@ static int be_stats_init(struct be_adapter *adapter)
 		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
 
 	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
-				     GFP_KERNEL);
+				     GFP_KERNEL | __GFP_ZERO);
 	if (cmd->va == NULL)
 		return -1;
-	memset(cmd->va, 0, cmd->size);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 7c361d1..0e817e6 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -780,12 +780,11 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 
 	priv->descs = dma_alloc_coherent(priv->dev,
 					 sizeof(struct ftgmac100_descs),
-					 &priv->descs_dma_addr, GFP_KERNEL);
+					 &priv->descs_dma_addr,
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!priv->descs)
 		return -ENOMEM;
 
-	memset(priv->descs, 0, sizeof(struct ftgmac100_descs));
-
 	/* initialize RX ring */
 	ftgmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
 
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index b5ea8fb..a6eda8d 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -732,13 +732,13 @@ static int ftmac100_alloc_buffers(struct ftmac100 *priv)
 {
 	int i;
 
-	priv->descs = dma_alloc_coherent(priv->dev, sizeof(struct ftmac100_descs),
-					 &priv->descs_dma_addr, GFP_KERNEL);
+	priv->descs = dma_alloc_coherent(priv->dev,
+					 sizeof(struct ftmac100_descs),
+					 &priv->descs_dma_addr,
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!priv->descs)
 		return -ENOMEM;
 
-	memset(priv->descs, 0, sizeof(struct ftmac100_descs));
-
 	/* initialize RX ring */
 	ftmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
 
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0fe68c4..40d751d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1602,11 +1602,9 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* Allocate memory for buffer descriptors. */
 	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
-			GFP_KERNEL);
-	if (!cbd_base) {
-		printk("FEC: allocate descriptor memory failed?\n");
+				      GFP_KERNEL);
+	if (!cbd_base)
 		return -ENOMEM;
-	}
 
 	spin_lock_init(&fep->hw_lock);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index ab32bd0..ff78ff3 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -245,14 +245,13 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 
 	/* Allocate memory for the buffer descriptors */
 	vaddr = dma_alloc_coherent(dev,
-			sizeof(struct txbd8) * priv->total_tx_ring_size +
-			sizeof(struct rxbd8) * priv->total_rx_ring_size,
-			&addr, GFP_KERNEL);
-	if (!vaddr) {
-		netif_err(priv, ifup, ndev,
-			  "Could not allocate buffer descriptors!\n");
+				   (priv->total_tx_ring_size *
+				    sizeof(struct txbd8)) +
+				   (priv->total_rx_ring_size *
+				    sizeof(struct rxbd8)),
+				   &addr, GFP_KERNEL);
+	if (!vaddr)
 		return -ENOMEM;
-	}
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		tx_queue = priv->tx_queue[i];
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 1f7ecf5..610ed223 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -637,17 +637,12 @@ static int mal_probe(struct platform_device *ofdev)
 	bd_size = sizeof(struct mal_descriptor) *
 		(NUM_TX_BUFF * mal->num_tx_chans +
 		 NUM_RX_BUFF * mal->num_rx_chans);
-	mal->bd_virt =
-		dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
-				   GFP_KERNEL);
+	mal->bd_virt = dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
+					  GFP_KERNEL | __GFP_ZERO);
 	if (mal->bd_virt == NULL) {
-		printk(KERN_ERR
-		       "mal%d: out of memory allocating RX/TX descriptors!\n",
-		       index);
 		err = -ENOMEM;
 		goto fail_unmap;
 	}
-	memset(mal->bd_virt, 0, bd_size);
 
 	for (i = 0; i < mal->num_tx_chans; ++i)
 		set_mal_dcrn(mal, MAL_TXCTPR(i), mal->bd_dma +
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index c859771..302d594 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -556,11 +556,9 @@ static int ibmveth_open(struct net_device *netdev)
 	adapter->rx_queue.queue_len = sizeof(struct ibmveth_rx_q_entry) *
 						rxq_entries;
 	adapter->rx_queue.queue_addr =
-	    dma_alloc_coherent(dev, adapter->rx_queue.queue_len,
-			       &adapter->rx_queue.queue_dma, GFP_KERNEL);
-
+		dma_alloc_coherent(dev, adapter->rx_queue.queue_len,
+				   &adapter->rx_queue.queue_dma, GFP_KERNEL);
 	if (!adapter->rx_queue.queue_addr) {
-		netdev_err(netdev, "unable to allocate rx queue pages\n");
 		rc = -ENOMEM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 14e3051..95f02c1 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1021,12 +1021,11 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
 	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!txdr->desc) {
 		ret_val = 2;
 		goto err_nomem;
 	}
-	memset(txdr->desc, 0, txdr->size);
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
 	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
@@ -1076,12 +1075,11 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!rxdr->desc) {
 		ret_val = 5;
 		goto err_nomem;
 	}
-	memset(rxdr->desc, 0, rxdr->size);
 	rxdr->next_to_use = rxdr->next_to_clean = 0;
 
 	rctl = er32(RCTL);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index d947e3a..10782c4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1522,8 +1522,6 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
-		e_err(probe, "Unable to allocate memory for the Tx descriptor "
-		      "ring\n");
 		return -ENOMEM;
 	}
 
@@ -1713,10 +1711,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
 					GFP_KERNEL);
-
 	if (!rxdr->desc) {
-		e_err(probe, "Unable to allocate memory for the Rx descriptor "
-		      "ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
@@ -1735,8 +1730,6 @@ setup_rx_desc_die:
 		if (!rxdr->desc) {
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			e_err(probe, "Unable to allocate memory for the Rx "
-			      "descriptor ring\n");
 			goto setup_rx_desc_die;
 		}
 
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index f53f713..b2c5f0c 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -447,7 +447,6 @@ int igbvf_setup_tx_resources(struct igbvf_adapter *adapter,
 
 	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
 					   &tx_ring->dma, GFP_KERNEL);
-
 	if (!tx_ring->desc)
 		goto err;
 
@@ -488,7 +487,6 @@ int igbvf_setup_rx_resources(struct igbvf_adapter *adapter,
 
 	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
-
 	if (!rx_ring->desc)
 		goto err;
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index ea48083..3e7295c 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -717,14 +717,11 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->size = ALIGN(txdr->size, 4096);
 
 	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
-		netif_err(adapter, probe, adapter->netdev,
-			  "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
-	memset(txdr->desc, 0, txdr->size);
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
@@ -803,15 +800,11 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	rxdr->size = ALIGN(rxdr->size, 4096);
 
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
-					GFP_KERNEL);
-
+					GFP_KERNEL | __GFP_ZERO);
 	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
-		netif_err(adapter, probe, adapter->netdev,
-			  "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->desc, 0, rxdr->size);
 
 	rxdr->next_to_clean = 0;
 	rxdr->next_to_use = 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c3db6cd..d87291a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2415,11 +2415,7 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
 
 	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
-
 	if (!rx_ring->desc) {
-		hw_dbg(&adapter->hw,
-		       "Unable to allocate memory for "
-		       "the receive descriptor ring\n");
 		vfree(rx_ring->rx_buffer_info);
 		rx_ring->rx_buffer_info = NULL;
 		goto alloc_failed;
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b6025c3..c17ab48 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1970,13 +1970,8 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	rxq->descs = dma_alloc_coherent(pp->dev->dev.parent,
 					rxq->size * MVNETA_DESC_ALIGNED_SIZE,
 					&rxq->descs_phys, GFP_KERNEL);
-	if (rxq->descs == NULL) {
-		netdev_err(pp->dev,
-			   "rxq=%d: Can't allocate %d bytes for %d RX descr\n",
-			   rxq->id, rxq->size * MVNETA_DESC_ALIGNED_SIZE,
-			   rxq->size);
+	if (rxq->descs == NULL)
 		return -ENOMEM;
-	}
 
 	BUG_ON(rxq->descs !=
 	       PTR_ALIGN(rxq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));
@@ -2030,13 +2025,8 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 	txq->descs = dma_alloc_coherent(pp->dev->dev.parent,
 					txq->size * MVNETA_DESC_ALIGNED_SIZE,
 					&txq->descs_phys, GFP_KERNEL);
-	if (txq->descs == NULL) {
-		netdev_err(pp->dev,
-			   "txQ=%d: Can't allocate %d bytes for %d TX descr\n",
-			   txq->id, txq->size * MVNETA_DESC_ALIGNED_SIZE,
-			   txq->size);
+	if (txq->descs == NULL)
 		return -ENOMEM;
-	}
 
 	/* Make sure descriptor address is cache line size aligned  */
 	BUG_ON(txq->descs !=
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 037ed86..339bb32 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -584,12 +584,14 @@ static int init_hash_table(struct pxa168_eth_private *pep)
 	 */
 	if (pep->htpr == NULL) {
 		pep->htpr = dma_alloc_coherent(pep->dev->dev.parent,
-					      HASH_ADDR_TABLE_SIZE,
-					      &pep->htpr_dma, GFP_KERNEL);
+					       HASH_ADDR_TABLE_SIZE,
+					       &pep->htpr_dma,
+					       GFP_KERNEL | __GFP_ZERO);
 		if (pep->htpr == NULL)
 			return -ENOMEM;
+	} else {
+		memset(pep->htpr, 0, HASH_ADDR_TABLE_SIZE);
 	}
-	memset(pep->htpr, 0, HASH_ADDR_TABLE_SIZE);
 	wrl(pep, HTPR, pep->htpr_dma);
 	return 0;
 }
@@ -1023,13 +1025,11 @@ static int rxq_init(struct net_device *dev)
 	size = pep->rx_ring_size * sizeof(struct rx_desc);
 	pep->rx_desc_area_size = size;
 	pep->p_rx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						&pep->rx_desc_dma, GFP_KERNEL);
-	if (!pep->p_rx_desc_area) {
-		printk(KERN_ERR "%s: Cannot alloc RX ring (size %d bytes)\n",
-		       dev->name, size);
+						 &pep->rx_desc_dma,
+						 GFP_KERNEL | __GFP_ZERO);
+	if (!pep->p_rx_desc_area)
 		goto out;
-	}
-	memset((void *)pep->p_rx_desc_area, 0, size);
+
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
 	p_rx_desc = pep->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
@@ -1086,13 +1086,10 @@ static int txq_init(struct net_device *dev)
 	size = pep->tx_ring_size * sizeof(struct tx_desc);
 	pep->tx_desc_area_size = size;
 	pep->p_tx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						&pep->tx_desc_dma, GFP_KERNEL);
-	if (!pep->p_tx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-		       dev->name, size);
+						 &pep->tx_desc_dma,
+						 GFP_KERNEL | __GFP_ZERO);
+	if (!pep->p_tx_desc_area)
 		goto out;
-	}
-	memset((void *)pep->p_tx_desc_area, 0, pep->tx_desc_area_size);
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
 	p_tx_desc = pep->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index fdc5f23..c8a80ed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1834,13 +1834,12 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 	}
 
 	if (mlx4_is_mfunc(dev)) {
-		priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
+		priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev),
+						      PAGE_SIZE,
 						      &priv->mfunc.vhcr_dma,
 						      GFP_KERNEL);
-		if (!priv->mfunc.vhcr) {
-			mlx4_err(dev, "Couldn't allocate VHCR.\n");
+		if (!priv->mfunc.vhcr)
 			goto err_hcr;
-		}
 	}
 
 	priv->cmd.pool = pci_pool_create("mlx4_cmd", dev->pdev,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 4f9937e..d5ffdc8 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3592,10 +3592,9 @@ static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
 		bytes = mgp->max_intr_slots * sizeof(*ss->rx_done.entry);
 		ss->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
 						       &ss->rx_done.bus,
-						       GFP_KERNEL);
+						       GFP_KERNEL | __GFP_ZERO);
 		if (ss->rx_done.entry == NULL)
 			goto abort;
-		memset(ss->rx_done.entry, 0, bytes);
 		bytes = sizeof(*ss->fw_stats);
 		ss->fw_stats = dma_alloc_coherent(&pdev->dev, bytes,
 						  &ss->fw_stats_bus,
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index b0b3615..c20766c 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -175,13 +175,13 @@ static int sonic_probe1(struct net_device *dev)
 
 	/* Allocate the entire chunk of memory for the descriptors.
            Note that this cannot cross a 64K boundary. */
-	if ((lp->descriptors = dma_alloc_coherent(lp->device,
-				SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
-				&lp->descriptors_laddr, GFP_KERNEL)) == NULL) {
-		printk(KERN_ERR "%s: couldn't alloc DMA memory for descriptors.\n",
-		       dev_name(lp->device));
+	lp->descriptors = dma_alloc_coherent(lp->device,
+					     SIZEOF_SONIC_DESC *
+					     SONIC_BUS_SCALE(lp->dma_bitmode),
+					     &lp->descriptors_laddr,
+					     GFP_KERNEL);
+	if (lp->descriptors == NULL)
 		goto out;
-	}
 
 	/* Now set up the pointers to point to the appropriate places */
 	lp->cda = lp->descriptors;
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 0ffde69..346a4e0 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -202,13 +202,13 @@ static int macsonic_init(struct net_device *dev)
 
 	/* Allocate the entire chunk of memory for the descriptors.
            Note that this cannot cross a 64K boundary. */
-	if ((lp->descriptors = dma_alloc_coherent(lp->device,
-	            SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
-	            &lp->descriptors_laddr, GFP_KERNEL)) == NULL) {
-		printk(KERN_ERR "%s: couldn't alloc DMA memory for descriptors.\n",
-		       dev_name(lp->device));
+	lp->descriptors = dma_alloc_coherent(lp->device,
+					     SIZEOF_SONIC_DESC *
+					     SONIC_BUS_SCALE(lp->dma_bitmode),
+					     &lp->descriptors_laddr,
+					     GFP_KERNEL);
+	if (lp->descriptors == NULL)
 		return -ENOMEM;
-	}
 
 	/* Now set up the pointers to point to the appropriate places */
 	lp->cda = lp->descriptors;
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 5e4748e..c2e0256 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -197,14 +197,12 @@ static int __init sonic_probe1(struct net_device *dev)
 	 *  We also allocate extra space for a pointer to allow freeing
 	 *  this structure later on (in xtsonic_cleanup_module()).
 	 */
-	lp->descriptors =
-		dma_alloc_coherent(lp->device,
-			SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
-			&lp->descriptors_laddr, GFP_KERNEL);
-
+	lp->descriptors = dma_alloc_coherent(lp->device,
+					     SIZEOF_SONIC_DESC *
+					     SONIC_BUS_SCALE(lp->dma_bitmode),
+					     &lp->descriptors_laddr,
+					     GFP_KERNEL);
 	if (lp->descriptors == NULL) {
-		printk(KERN_ERR "%s: couldn't alloc DMA memory for "
-				" descriptors.\n", dev_name(lp->device));
 		err = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 162da89..6e8b8d5 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -287,23 +287,16 @@ static int w90p910_init_desc(struct net_device *dev)
 	ether = netdev_priv(dev);
 	pdev = ether->pdev;
 
-	ether->tdesc = (struct tran_pdesc *)
-		dma_alloc_coherent(&pdev->dev, sizeof(struct tran_pdesc),
-					&ether->tdesc_phys, GFP_KERNEL);
-
-	if (!ether->tdesc) {
-		dev_err(&pdev->dev, "Failed to allocate memory for tx desc\n");
+	ether->tdesc = dma_alloc_coherent(&pdev->dev, sizeof(struct tran_pdesc),
+					  &ether->tdesc_phys, GFP_KERNEL);
+	if (!ether->tdesc)
 		return -ENOMEM;
-	}
-
-	ether->rdesc = (struct recv_pdesc *)
-		dma_alloc_coherent(&pdev->dev, sizeof(struct recv_pdesc),
-					&ether->rdesc_phys, GFP_KERNEL);
 
+	ether->rdesc = dma_alloc_coherent(&pdev->dev, sizeof(struct recv_pdesc),
+					  &ether->rdesc_phys, GFP_KERNEL);
 	if (!ether->rdesc) {
-		dev_err(&pdev->dev, "Failed to allocate memory for rx desc\n");
 		dma_free_coherent(&pdev->dev, sizeof(struct tran_pdesc),
-					ether->tdesc, ether->tdesc_phys);
+				  ether->tdesc, ether->tdesc_phys);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index c4122c8..9c88c00 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1409,9 +1409,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 			dma_alloc_coherent(&pldat->pdev->dev,
 					   pldat->dma_buff_size, &dma_handle,
 					   GFP_KERNEL);
-
 		if (pldat->dma_buff_base_v == NULL) {
-			dev_err(&pdev->dev, "error getting DMA region.\n");
 			ret = -ENOMEM;
 			goto err_out_free_irq;
 		}
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 39ab4d0..abd5fba 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1469,13 +1469,11 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 
 	size = rx_ring->count * bufsz + PCH_GBE_RESERVE_MEMORY;
 	rx_ring->rx_buff_pool = dma_alloc_coherent(&pdev->dev, size,
-						&rx_ring->rx_buff_pool_logic,
-						GFP_KERNEL);
-	if (!rx_ring->rx_buff_pool) {
-		pr_err("Unable to allocate memory for the receive pool buffer\n");
+						   &rx_ring->rx_buff_pool_logic,
+						   GFP_KERNEL | __GFP_ZERO);
+	if (!rx_ring->rx_buff_pool)
 		return -ENOMEM;
-	}
-	memset(rx_ring->rx_buff_pool, 0, size);
+
 	rx_ring->rx_buff_pool_size = size;
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
@@ -1774,13 +1772,12 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
 	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
-					   &tx_ring->dma, GFP_KERNEL);
+					   &tx_ring->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!tx_ring->desc) {
 		vfree(tx_ring->buffer_info);
-		pr_err("Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(tx_ring->desc, 0, tx_ring->size);
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
@@ -1820,14 +1817,12 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
-					   &rx_ring->dma, GFP_KERNEL);
-
+					   &rx_ring->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!rx_ring->desc) {
-		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		vfree(rx_ring->buffer_info);
 		return -ENOMEM;
 	}
-	memset(rx_ring->desc, 0, rx_ring->size);
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 	for (desNo = 0; desNo < rx_ring->count; desNo++) {
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 0be5844..5b92526 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -441,12 +441,11 @@ static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 
 	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
 					   RX_RING_SIZE * sizeof(u64),
-					   &ring->buf_dma, GFP_KERNEL);
+					   &ring->buf_dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!ring->buffers)
 		goto out_ring_desc;
 
-	memset(ring->buffers, 0, RX_RING_SIZE * sizeof(u64));
-
 	write_dma_reg(PAS_DMA_RXCHAN_BASEL(chno),
 		      PAS_DMA_RXCHAN_BASEL_BRBL(ring->chan.ring_dma));
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 4a3bd64..9363b6f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -401,22 +401,20 @@ int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
 
 	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
 	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
-			&rq_phys_addr, GFP_KERNEL);
+				     &rq_phys_addr, GFP_KERNEL | __GFP_ZERO);
 	if (!rq_addr)
 		return -ENOMEM;
 
 	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
 	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
-			&rsp_phys_addr, GFP_KERNEL);
+				      &rsp_phys_addr, GFP_KERNEL | __GFP_ZERO);
 	if (!rsp_addr) {
 		err = -ENOMEM;
 		goto out_free_rq;
 	}
 
-	memset(rq_addr, 0, rq_size);
 	prq = rq_addr;
 
-	memset(rsp_addr, 0, rsp_size);
 	prsp = rsp_addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
@@ -511,20 +509,15 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 		ptr = (__le32 *)dma_alloc_coherent(&pdev->dev, sizeof(u32),
 						   &tx_ring->hw_cons_phys_addr,
 						   GFP_KERNEL);
-
-		if (ptr == NULL) {
-			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
+		if (ptr == NULL)
 			return -ENOMEM;
-		}
+
 		tx_ring->hw_consumer = ptr;
 		/* cmd desc ring */
 		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
 					  &tx_ring->phys_addr,
 					  GFP_KERNEL);
-
 		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				"failed to allocate tx desc ring\n");
 			err = -ENOMEM;
 			goto err_out_free;
 		}
@@ -535,11 +528,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		addr = dma_alloc_coherent(&adapter->pdev->dev,
-				RCV_DESC_RINGSIZE(rds_ring),
-				&rds_ring->phys_addr, GFP_KERNEL);
+					  RCV_DESC_RINGSIZE(rds_ring),
+					  &rds_ring->phys_addr, GFP_KERNEL);
 		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				"failed to allocate rds ring [%d]\n", ring);
 			err = -ENOMEM;
 			goto err_out_free;
 		}
@@ -551,11 +542,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 		sds_ring = &recv_ctx->sds_rings[ring];
 
 		addr = dma_alloc_coherent(&adapter->pdev->dev,
-				STATUS_DESC_RINGSIZE(sds_ring),
-				&sds_ring->phys_addr, GFP_KERNEL);
+					  STATUS_DESC_RINGSIZE(sds_ring),
+					  &sds_ring->phys_addr, GFP_KERNEL);
 		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				"failed to allocate sds ring [%d]\n", ring);
 			err = -ENOMEM;
 			goto err_out_free;
 		}
@@ -711,10 +700,9 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 	size_t  nic_size = sizeof(struct qlcnic_info_le);
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-				&nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!nic_info_addr)
 		return -ENOMEM;
-	memset(nic_info_addr, 0, nic_size);
 
 	nic_info = nic_info_addr;
 
@@ -762,11 +750,10 @@ int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
 		return err;
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-			&nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
-	memset(nic_info_addr, 0, nic_size);
 	nic_info = nic_info_addr;
 
 	nic_info->pci_func = cpu_to_le16(nic->pci_func);
@@ -812,10 +799,10 @@ int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
 	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
 
 	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
-			&pci_info_dma_t, GFP_KERNEL);
+					   &pci_info_dma_t,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!pci_info_addr)
 		return -ENOMEM;
-	memset(pci_info_addr, 0, pci_size);
 
 	npar = pci_info_addr;
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_PCI_INFO);
@@ -907,12 +894,9 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	}
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
+					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
+	if (!stats_addr)
 		return -ENOMEM;
-	}
-	memset(stats_addr, 0, stats_size);
 
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
 	arg1 |= rx_tx << 15 | stats_size << 16;
@@ -961,13 +945,10 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev,
-			"%s: Unable to allocate memory.\n", __func__);
+					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
+	if (!stats_addr)
 		return -ENOMEM;
-	}
-	memset(stats_addr, 0, stats_size);
+
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_MAC_STATS);
 	cmd.req.arg[1] = stats_size << 16;
 	cmd.req.arg[2] = MSD(stats_dma_t);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index abbd22c..4b9bab1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -810,11 +810,8 @@ static int __qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter,
 
 	tmp_addr = dma_alloc_coherent(&adapter->pdev->dev, temp_size,
 				      &tmp_addr_t, GFP_KERNEL);
-	if (!tmp_addr) {
-		dev_err(&adapter->pdev->dev,
-			"Can't get memory for FW dump template\n");
+	if (!tmp_addr)
 		return -ENOMEM;
-	}
 
 	if (qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_TEMP_HDR)) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33e9617..7a6471d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -908,11 +908,8 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	/* Allocate all Rx descriptors. */
 	rx_ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
 	mdp->rx_ring = dma_alloc_coherent(NULL, rx_ringsize, &mdp->rx_desc_dma,
-			GFP_KERNEL);
-
+					  GFP_KERNEL);
 	if (!mdp->rx_ring) {
-		dev_err(&ndev->dev, "Cannot allocate Rx Ring (size %d bytes)\n",
-			rx_ringsize);
 		ret = -ENOMEM;
 		goto desc_ring_free;
 	}
@@ -922,10 +919,8 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	/* Allocate all Tx descriptors. */
 	tx_ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
 	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
-			GFP_KERNEL);
+					  GFP_KERNEL);
 	if (!mdp->tx_ring) {
-		dev_err(&ndev->dev, "Cannot allocate Tx Ring (size %d bytes)\n",
-			tx_ringsize);
 		ret = -ENOMEM;
 		goto desc_ring_free;
 	}
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 0ad790c..da044c9 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -305,11 +305,11 @@ int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len)
 {
 	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
-					  &buffer->dma_addr, GFP_ATOMIC);
+					  &buffer->dma_addr,
+					  GFP_ATOMIC | __GFP_ZERO);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
-	memset(buffer->addr, 0, len);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 79ad9c9..4bdbaad9 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -213,10 +213,11 @@ static int meth_init_tx_ring(struct meth_private *priv)
 {
 	/* Init TX ring */
 	priv->tx_ring = dma_alloc_coherent(NULL, TX_RING_BUFFER_SIZE,
-	                                   &priv->tx_ring_dma, GFP_ATOMIC);
+	                                   &priv->tx_ring_dma,
+					   GFP_ATOMIC | __GFP_ZERO);
 	if (!priv->tx_ring)
 		return -ENOMEM;
-	memset(priv->tx_ring, 0, TX_RING_BUFFER_SIZE);
+
 	priv->tx_count = priv->tx_read = priv->tx_write = 0;
 	mace->eth.tx_ring_base = priv->tx_ring_dma;
 	/* Now init skb save area */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fd4d659..8328213 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -534,25 +534,17 @@ static void init_dma_desc_rings(struct net_device *dev)
 					    GFP_KERNEL);
 	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
-	priv->dma_rx =
-	    (struct dma_desc *)dma_alloc_coherent(priv->device,
-						  rxsize *
-						  sizeof(struct dma_desc),
-						  &priv->dma_rx_phy,
-						  GFP_KERNEL);
+	priv->dma_rx = dma_alloc_coherent(priv->device,
+					  rxsize * sizeof(struct dma_desc),
+					  &priv->dma_rx_phy, GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
-	priv->dma_tx =
-	    (struct dma_desc *)dma_alloc_coherent(priv->device,
-						  txsize *
-						  sizeof(struct dma_desc),
-						  &priv->dma_tx_phy,
-						  GFP_KERNEL);
-
-	if ((priv->dma_rx == NULL) || (priv->dma_tx == NULL)) {
-		pr_err("%s:ERROR allocating the DMA Tx/Rx desc\n", __func__);
+	priv->dma_tx = dma_alloc_coherent(priv->device,
+					  txsize * sizeof(struct dma_desc),
+					  &priv->dma_tx_phy, GFP_KERNEL);
+
+	if ((priv->dma_rx == NULL) || (priv->dma_tx == NULL))
 		return;
-	}
 
 	DBG(probe, INFO, "stmmac (%s) DMA desc: virt addr (Rx %p, "
 	    "Tx %p)\n\tDMA phy addr (Rx 0x%08x, Tx 0x%08x)\n",
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 5fafca0..0549759 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1169,10 +1169,8 @@ static int bigmac_ether_init(struct platform_device *op,
 	bp->bmac_block = dma_alloc_coherent(&bp->bigmac_op->dev,
 					    PAGE_SIZE,
 					    &bp->bblock_dvma, GFP_ATOMIC);
-	if (bp->bmac_block == NULL || bp->bblock_dvma == 0) {
-		printk(KERN_ERR "BIGMAC: Cannot allocate consistent DMA.\n");
+	if (bp->bmac_block == NULL || bp->bblock_dvma == 0)
 		goto fail_and_cleanup;
-	}
 
 	/* Get the board revision of this BigMAC. */
 	bp->board_rev = of_getintprop_default(bp->bigmac_op->dev.of_node,
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index a1bff49..436fa9d 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2752,10 +2752,8 @@ static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 					     &hp->hblock_dvma,
 					     GFP_ATOMIC);
 	err = -ENOMEM;
-	if (!hp->happy_block) {
-		printk(KERN_ERR "happymeal: Cannot allocate descriptors.\n");
+	if (!hp->happy_block)
 		goto err_out_iounmap;
-	}
 
 	/* Force check of the link first time we are brought up. */
 	hp->linkcheck = 0;
@@ -3068,14 +3066,11 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 	hp->happy_bursts = DMA_BURSTBITS;
 #endif
 
-	hp->happy_block = (struct hmeal_init_block *)
-		dma_alloc_coherent(&pdev->dev, PAGE_SIZE, &hp->hblock_dvma, GFP_KERNEL);
-
+	hp->happy_block = dma_alloc_coherent(&pdev->dev, PAGE_SIZE,
+					     &hp->hblock_dvma, GFP_KERNEL);
 	err = -ENODEV;
-	if (!hp->happy_block) {
-		printk(KERN_ERR "happymeal(PCI): Cannot get hme init block.\n");
+	if (!hp->happy_block)
 		goto err_out_iounmap;
-	}
 
 	hp->linkcheck = 0;
 	hp->timer_state = asleep;
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index f1b91fd..fef6b59 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -352,8 +352,7 @@ spider_net_init_chain(struct spider_net_card *card,
 	alloc_size = chain->num_desc * sizeof(struct spider_net_hw_descr);
 
 	chain->hwring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
-		&chain->dma_addr, GFP_KERNEL);
-
+					   &chain->dma_addr, GFP_KERNEL);
 	if (!chain->hwring)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 8fa947a..3c69a04 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1308,27 +1308,16 @@ static int tsi108_open(struct net_device *dev)
 		       data->id, dev->irq, dev->name);
 	}
 
-	data->rxring = dma_alloc_coherent(NULL, rxring_size,
-			&data->rxdma, GFP_KERNEL);
-
-	if (!data->rxring) {
-		printk(KERN_DEBUG
-		       "TSI108_ETH: failed to allocate memory for rxring!\n");
+	data->rxring = dma_alloc_coherent(NULL, rxring_size, &data->rxdma,
+					  GFP_KERNEL | __GFP_ZERO);
+	if (!data->rxring)
 		return -ENOMEM;
-	} else {
-		memset(data->rxring, 0, rxring_size);
-	}
-
-	data->txring = dma_alloc_coherent(NULL, txring_size,
-			&data->txdma, GFP_KERNEL);
 
+	data->txring = dma_alloc_coherent(NULL, txring_size, &data->txdma,
+					  GFP_KERNEL | __GFP_ZERO);
 	if (!data->txring) {
-		printk(KERN_DEBUG
-		       "TSI108_ETH: failed to allocate memory for txring!\n");
 		pci_free_consistent(0, rxring_size, data->rxring, data->rxdma);
 		return -ENOMEM;
-	} else {
-		memset(data->txring, 0, txring_size);
 	}
 
 	for (i = 0; i < TSI108_RXRING_LEN; i++) {
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 9fc2ada..fb4b75c 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -245,28 +245,21 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	/* returns a virtual address and a physical address. */
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
-					 &lp->tx_bd_p, GFP_KERNEL);
-	if (!lp->tx_bd_v) {
-		dev_err(&ndev->dev,
-				"unable to allocate DMA TX buffer descriptors");
+					 &lp->tx_bd_p, GFP_KERNEL | __GFP_ZERO);
+	if (!lp->tx_bd_v)
 		goto out;
-	}
+
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
-					 &lp->rx_bd_p, GFP_KERNEL);
-	if (!lp->rx_bd_v) {
-		dev_err(&ndev->dev,
-				"unable to allocate DMA RX buffer descriptors");
+					 &lp->rx_bd_p, GFP_KERNEL | __GFP_ZERO);
+	if (!lp->rx_bd_v)
 		goto out;
-	}
 
-	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
 		lp->tx_bd_v[i].next = lp->tx_bd_p +
 				sizeof(*lp->tx_bd_v) * ((i + 1) % TX_BD_NUM);
 	}
 
-	memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NUM);
 	for (i = 0; i < RX_BD_NUM; i++) {
 		lp->rx_bd_v[i].next = lp->rx_bd_p +
 				sizeof(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 278c9db..89d5a17 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -204,31 +204,23 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					 &lp->tx_bd_p,
-					 GFP_KERNEL);
-	if (!lp->tx_bd_v) {
-		dev_err(&ndev->dev, "unable to allocate DMA Tx buffer "
-			"descriptors");
+					 GFP_KERNEL | __GFP_ZERO);
+	if (!lp->tx_bd_v)
 		goto out;
-	}
 
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
 					 &lp->rx_bd_p,
-					 GFP_KERNEL);
-	if (!lp->rx_bd_v) {
-		dev_err(&ndev->dev, "unable to allocate DMA Rx buffer "
-			"descriptors");
+					 GFP_KERNEL | __GFP_ZERO);
+	if (!lp->rx_bd_v)
 		goto out;
-	}
 
-	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
 		lp->tx_bd_v[i].next = lp->tx_bd_p +
 				      sizeof(*lp->tx_bd_v) *
 				      ((i + 1) % TX_BD_NUM);
 	}
 
-	memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NUM);
 	for (i = 0; i < RX_BD_NUM; i++) {
 		lp->rx_bd_v[i].next = lp->rx_bd_p +
 				      sizeof(*lp->rx_bd_v) *
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 502c8ff..4c8ddc9 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -1070,13 +1070,10 @@ static int dfx_driver_init(struct net_device *dev, const char *print_name,
 					(PI_ALIGN_K_DESC_BLK - 1);
 	bp->kmalloced = top_v = dma_alloc_coherent(bp->bus_dev, alloc_size,
 						   &bp->kmalloced_dma,
-						   GFP_ATOMIC);
-	if (top_v == NULL) {
-		printk("%s: Could not allocate memory for host buffers "
-		       "and structures!\n", print_name);
+						   GFP_ATOMIC | __GFP_ZERO);
+	if (top_v == NULL)
 		return DFX_K_FAILURE;
-	}
-	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
+
 	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
 
 	/*
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 8487204..e907572 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -352,21 +352,19 @@ static int ali_ircc_open(int i, chipio_t *info)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index fed4a05..a06fca6 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -389,7 +389,8 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 	set_dma_callback(port->rx_dma_channel, bfin_sir_dma_rx_int, dev);
 	set_dma_callback(port->tx_dma_channel, bfin_sir_dma_tx_int, dev);
 
-	port->rx_dma_buf.buf = (unsigned char *)dma_alloc_coherent(NULL, PAGE_SIZE, &dma_handle, GFP_DMA);
+	port->rx_dma_buf.buf = dma_alloc_coherent(NULL, PAGE_SIZE,
+						  &dma_handle, GFP_DMA);
 	port->rx_dma_buf.head = 0;
 	port->rx_dma_buf.tail = 0;
 	port->rx_dma_nrows = 0;
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 2a4f2f1..9cf836b 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -431,22 +431,20 @@ static int __init nsc_ircc_open(chipio_t *info)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out2;
 
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 858de05..964b116 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -700,12 +700,12 @@ static int pxa_irda_start(struct net_device *dev)
 
 	err = -ENOMEM;
 	si->dma_rx_buff = dma_alloc_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT,
-					     &si->dma_rx_buff_phy, GFP_KERNEL );
+					     &si->dma_rx_buff_phy, GFP_KERNEL);
 	if (!si->dma_rx_buff)
 		goto err_dma_rx_buff;
 
 	si->dma_tx_buff = dma_alloc_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT,
-					     &si->dma_tx_buff_phy, GFP_KERNEL );
+					     &si->dma_tx_buff_phy, GFP_KERNEL);
 	if (!si->dma_tx_buff)
 		goto err_dma_tx_buff;
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 5290952..fbb2253 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -561,26 +561,17 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	self->rx_buff.truesize = SMSC_IRCC2_RX_BUFF_TRUESIZE;
 	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
 
-	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
-	if (self->rx_buff.head == NULL) {
-		IRDA_ERROR("%s, Can't allocate memory for receive buffer!\n",
-			   driver_name);
+	self->rx_buff.head = dma_alloc_coherent(NULL, self->rx_buff.truesize,
+						&self->rx_buff_dma,
+						GFP_KERNEL | __GFP_ZERO);
+	if (self->rx_buff.head == NULL)
 		goto err_out2;
-	}
 
-	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
-	if (self->tx_buff.head == NULL) {
-		IRDA_ERROR("%s, Can't allocate memory for transmit buffer!\n",
-			   driver_name);
+	self->tx_buff.head = dma_alloc_coherent(NULL, self->tx_buff.truesize,
+						&self->tx_buff_dma,
+						GFP_KERNEL | __GFP_ZERO);
+	if (self->tx_buff.head == NULL)
 		goto err_out3;
-	}
-
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index f9033c6..51f2bc3 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -364,21 +364,19 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(&pdev->dev, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 
 	self->tx_buff.head =
 		dma_alloc_coherent(&pdev->dev, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index f5bb92f..bb8857a 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -216,22 +216,19 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out1;
 	}
 
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
-	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wireless/ath/wil6210/txrx.c
index d1315b4..55dd95f 100644
--- a/drivers/net/wireless/ath/wil6210/txrx.c
+++ b/drivers/net/wireless/ath/wil6210/txrx.c
@@ -83,8 +83,6 @@ static int wil_vring_alloc(struct wil6210_priv *wil, struct vring *vring)
 	 */
 	vring->va = dma_alloc_coherent(dev, sz, &vring->pa, GFP_KERNEL);
 	if (!vring->va) {
-		wil_err(wil, "vring_alloc [%d] failed to alloc DMA mem\n",
-			vring->size);
 		kfree(vring->ctx);
 		vring->ctx = NULL;
 		return -ENOMEM;
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 38bc5a7..f73cbb5 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -419,8 +419,6 @@ static inline
 
 static int alloc_ringmemory(struct b43_dmaring *ring)
 {
-	gfp_t flags = GFP_KERNEL;
-
 	/* The specs call for 4K buffers for 30- and 32-bit DMA with 4K
 	 * alignment and 8K buffers for 64-bit DMA with 8K alignment.
 	 * In practice we could use smaller buffers for the latter, but the
@@ -435,12 +433,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 
 	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
 					    ring_mem_size, &(ring->dmabase),
-					    flags);
-	if (!ring->descbase) {
-		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
+					    GFP_KERNEL | __GFP_ZERO);
+	if (!ring->descbase)
 		return -ENOMEM;
-	}
-	memset(ring->descbase, 0, ring_mem_size);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 2d3c664..faeafe2 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -334,13 +334,9 @@ static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
 					    B43legacy_DMA_RINGMEMSIZE,
 					    &(ring->dmabase),
-					    GFP_KERNEL);
-	if (!ring->descbase) {
-		b43legacyerr(ring->dev->wl, "DMA ringmemory allocation"
-			     " failed\n");
+					    GFP_KERNEL | __GFP_ZERO);
+	if (!ring->descbase)
 		return -ENOMEM;
-	}
-	memset(ring->descbase, 0, B43legacy_DMA_RINGMEMSIZE);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index e0b9d7f..9e2857c 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -2377,12 +2377,11 @@ il3945_hw_set_hw_params(struct il_priv *il)
 	memset((void *)&il->hw_params, 0, sizeof(struct il_hw_params));
 
 	il->_3945.shared_virt =
-	    dma_alloc_coherent(&il->pci_dev->dev, sizeof(struct il3945_shared),
-			       &il->_3945.shared_phys, GFP_KERNEL);
-	if (!il->_3945.shared_virt) {
-		IL_ERR("failed to allocate pci memory\n");
+		dma_alloc_coherent(&il->pci_dev->dev,
+				   sizeof(struct il3945_shared),
+				   &il->_3945.shared_phys, GFP_KERNEL);
+	if (!il->_3945.shared_virt)
 		return -ENOMEM;
-	}
 
 	il->hw_params.bcast_id = IL3945_BROADCAST_ID;
 
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 9741ac1..0d5d50e 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -1915,8 +1915,8 @@ drop_unlock:
 static inline int
 il4965_alloc_dma_ptr(struct il_priv *il, struct il_dma_ptr *ptr, size_t size)
 {
-	ptr->addr =
-	    dma_alloc_coherent(&il->pci_dev->dev, size, &ptr->dma, GFP_KERNEL);
+	ptr->addr = dma_alloc_coherent(&il->pci_dev->dev, size, &ptr->dma,
+				       GFP_KERNEL);
 	if (!ptr->addr)
 		return -ENOMEM;
 	ptr->size = size;
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 1f59860..81a470e 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -2568,15 +2568,13 @@ il_rx_queue_alloc(struct il_priv *il)
 	INIT_LIST_HEAD(&rxq->rx_used);
 
 	/* Alloc the circular buffer of Read Buffer Descriptors (RBDs) */
-	rxq->bd =
-	    dma_alloc_coherent(dev, 4 * RX_QUEUE_SIZE, &rxq->bd_dma,
-			       GFP_KERNEL);
+	rxq->bd = dma_alloc_coherent(dev, 4 * RX_QUEUE_SIZE, &rxq->bd_dma,
+				     GFP_KERNEL);
 	if (!rxq->bd)
 		goto err_bd;
 
-	rxq->rb_stts =
-	    dma_alloc_coherent(dev, sizeof(struct il_rb_status),
-			       &rxq->rb_stts_dma, GFP_KERNEL);
+	rxq->rb_stts = dma_alloc_coherent(dev, sizeof(struct il_rb_status),
+					  &rxq->rb_stts_dma, GFP_KERNEL);
 	if (!rxq->rb_stts)
 		goto err_rb;
 
@@ -2941,12 +2939,11 @@ il_tx_queue_alloc(struct il_priv *il, struct il_tx_queue *txq, u32 id)
 
 	/* Circular buffer of transmit frame descriptors (TFDs),
 	 * shared with device */
-	txq->tfds =
-	    dma_alloc_coherent(dev, tfd_sz, &txq->q.dma_addr, GFP_KERNEL);
-	if (!txq->tfds) {
-		IL_ERR("Fail to alloc TFDs\n");
+	txq->tfds = dma_alloc_coherent(dev, tfd_sz, &txq->q.dma_addr,
+				       GFP_KERNEL);
+	if (!txq->tfds)
 		goto error;
-	}
+
 	txq->q.id = id;
 
 	return 0;
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 96f2025..458e699 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -2235,9 +2235,8 @@ il_alloc_fw_desc(struct pci_dev *pci_dev, struct fw_desc *desc)
 		return -EINVAL;
 	}
 
-	desc->v_addr =
-	    dma_alloc_coherent(&pci_dev->dev, desc->len, &desc->p_addr,
-			       GFP_KERNEL);
+	desc->v_addr = dma_alloc_coherent(&pci_dev->dev, desc->len,
+					  &desc->p_addr, GFP_KERNEL);
 	return (desc->v_addr != NULL) ? 0 : -ENOMEM;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
index 041127a..22cc1a9 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -510,10 +510,9 @@ static int iwl_pcie_txq_alloc(struct iwl_trans *trans,
 	 * shared with device */
 	txq->tfds = dma_alloc_coherent(trans->dev, tfd_sz,
 				       &txq->q.dma_addr, GFP_KERNEL);
-	if (!txq->tfds) {
-		IWL_ERR(trans, "dma_alloc_coherent(%zd) failed\n", tfd_sz);
+	if (!txq->tfds)
 		goto error;
-	}
+
 	txq->q.id = txq_id;
 
 	return 0;
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index a0c8cae..696abed 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -124,12 +124,10 @@ static int rt2x00pci_alloc_queue_dma(struct rt2x00_dev *rt2x00dev,
 	 */
 	addr = dma_alloc_coherent(rt2x00dev->dev,
 				  queue->limit * queue->desc_size,
-				  &dma, GFP_KERNEL);
+				  &dma, GFP_KERNEL | __GFP_ZERO);
 	if (!addr)
 		return -ENOMEM;
 
-	memset(addr, 0, queue->limit * queue->desc_size);
