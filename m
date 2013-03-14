From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers:net: Remove
	dma_alloc_coherent OOM messages
Date: Thu, 14 Mar 2013 16:07:21 -0700
Message-ID: <1363302441.2146.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-wireless@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, wil6210@qca.qualcomm.com,
	b43-dev <b43-dev@lists.infradead.org>, linux-arm-kernel@lists.infradead.org
To: netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I believe these error messages are already logged
on allocation failure by warn_alloc_failed and so
get a dump_stack on OOM.

Remove the unnecessary additional error logging.

Around these deletions:

o Alignment neatening.
o Remove unnecessary casts of dma_alloc_coherent.
o Hoist assigns from ifs.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/aeroflex/greth.c              | 20 ++++-------
 drivers/net/ethernet/amd/sunlance.c                |  5 ++-
 drivers/net/ethernet/apple/macmace.c               | 16 ++++-----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  2 --
 drivers/net/ethernet/cadence/at91_ether.c          | 19 +++++-----
 drivers/net/ethernet/dec/tulip/xircom_cb.c         |  9 ++---
 drivers/net/ethernet/emulex/benet/be_cmds.c        |  4 +--
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |  9 ++---
 drivers/net/ethernet/emulex/benet/be_main.c        |  6 +---
 drivers/net/ethernet/freescale/fec.c               |  6 ++--
 drivers/net/ethernet/freescale/gianfar.c           | 13 ++++---
 drivers/net/ethernet/ibm/emac/mal.c                |  8 ++---
 drivers/net/ethernet/ibm/ibmveth.c                 |  6 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  7 ----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  4 ---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  3 --
 drivers/net/ethernet/marvell/mvneta.c              | 14 ++------
 drivers/net/ethernet/marvell/pxa168_eth.c          | 11 ++----
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  4 +--
 drivers/net/ethernet/natsemi/jazzsonic.c           | 12 +++----
 drivers/net/ethernet/natsemi/macsonic.c            | 12 +++----
 drivers/net/ethernet/natsemi/xtsonic.c             | 12 +++----
 drivers/net/ethernet/nuvoton/w90p910_ether.c       | 19 ++++------
 drivers/net/ethernet/nxp/lpc_eth.c                 |  2 --
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 12 +++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 40 ++++++++--------------
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  5 +--
 drivers/net/ethernet/renesas/sh_eth.c              |  9 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 24 +++++--------
 drivers/net/ethernet/sun/sunbmac.c                 |  4 +--
 drivers/net/ethernet/sun/sunhme.c                  | 13 +++----
 drivers/net/ethernet/tundra/tsi108_eth.c           | 10 ++----
 drivers/net/ethernet/xilinx/ll_temac_main.c        | 11 ++----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  | 10 ++----
 drivers/net/fddi/defxx.c                           |  6 ++--
 drivers/net/irda/bfin_sir.c                        |  3 +-
 drivers/net/irda/smsc-ircc2.c                      | 10 ++----
 drivers/net/wireless/ath/wil6210/txrx.c            |  2 --
 drivers/net/wireless/b43legacy/dma.c               |  5 +--
 drivers/net/wireless/iwlegacy/3945.c               |  4 +--
 drivers/net/wireless/iwlegacy/common.c             |  5 ++-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  4 +--
 42 files changed, 122 insertions(+), 278 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 0be2195..3a9fbac 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1464,14 +1464,10 @@ static int greth_of_probe(struct platform_device *ofdev)
 	}
 
 	/* Allocate TX descriptor ring in coherent memory */
-	greth->tx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
-								   1024,
-								   &greth->tx_bd_base_phys,
-								   GFP_KERNEL);
-
+	greth->tx_bd_base = dma_alloc_coherent(greth->dev, 1024,
+					       &greth->tx_bd_base_phys,
+					       GFP_KERNEL);
 	if (!greth->tx_bd_base) {
-		if (netif_msg_probe(greth))
-			dev_err(&dev->dev, "could not allocate descriptor memory.\n");
 		err = -ENOMEM;
 		goto error3;
 	}
@@ -1479,14 +1475,10 @@ static int greth_of_probe(struct platform_device *ofdev)
 	memset(greth->tx_bd_base, 0, 1024);
 
 	/* Allocate RX descriptor ring in coherent memory */
-	greth->rx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
-								   1024,
-								   &greth->rx_bd_base_phys,
-								   GFP_KERNEL);
-
+	greth->rx_bd_base = dma_alloc_coherent(greth->dev, 1024,
+					       &greth->rx_bd_base_phys,
+					       GFP_KERNEL);
 	if (!greth->rx_bd_base) {
-		if (netif_msg_probe(greth))
-			dev_err(greth->dev, "could not allocate descriptor memory.\n");
 		err = -ENOMEM;
 		goto error4;
 	}
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 70d5430..f47b780 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1373,10 +1373,9 @@ static int sparc_lance_probe_one(struct platform_device *op,
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
index db343a1..79cf620 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -864,7 +864,6 @@ static int bcm_enet_open(struct net_device *dev)
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
 	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
 	if (!p) {
-		dev_err(kdev, "cannot allocate rx ring %u\n", size);
 		ret = -ENOMEM;
 		goto out_freeirq_tx;
 	}
@@ -877,7 +876,6 @@ static int bcm_enet_open(struct net_device *dev)
 	size = priv->tx_ring_size * sizeof(struct bcm_enet_desc);
 	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
 	if (!p) {
-		dev_err(kdev, "cannot allocate tx ring\n");
 		ret = -ENOMEM;
 		goto out_free_rx_ring;
 	}
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 5bd7786..c6e40d6 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -47,22 +47,19 @@ static int at91ether_start(struct net_device *dev)
 	int i;
 
 	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * sizeof(struct macb_dma_desc),
-					&lp->rx_ring_dma, GFP_KERNEL);
-	if (!lp->rx_ring) {
-		netdev_err(dev, "unable to alloc rx ring DMA buffer\n");
+					 (MAX_RX_DESCR *
+					  sizeof(struct macb_dma_desc)),
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
index 6ed4639..6fc1fe59 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2667,10 +2667,8 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
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
index 053f00d..07b7f27 100644
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
index b8e5019..bc919be 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3457,11 +3457,9 @@ static int lancer_fw_download(struct be_adapter *adapter,
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
 
@@ -3563,8 +3561,6 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
 		status = -ENOMEM;
-		dev_err(&adapter->pdev->dev,
-			"Memory allocation failure while flashing\n");
 		goto be_fw_exit;
 	}
 
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index e622494..69a4ade 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1594,11 +1594,9 @@ static int fec_enet_init(struct net_device *ndev)
 
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
index d2c5441..1b468a8 100644
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
index 1f7ecf5..cc2db5c 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -637,13 +637,9 @@ static int mal_probe(struct platform_device *ofdev)
 	bd_size = sizeof(struct mal_descriptor) *
 		(NUM_TX_BUFF * mal->num_tx_chans +
 		 NUM_RX_BUFF * mal->num_rx_chans);
-	mal->bd_virt =
-		dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
-				   GFP_KERNEL);
+	mal->bd_virt = dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
+					  GFP_KERNEL);
 	if (mal->bd_virt == NULL) {
-		printk(KERN_ERR
-		       "mal%d: out of memory allocating RX/TX descriptors!\n",
-		       index);
 		err = -ENOMEM;
 		goto fail_unmap;
 	}
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
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 8502c62..d98e1d09 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1516,8 +1516,6 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
-		e_err(probe, "Unable to allocate memory for the Tx descriptor "
-		      "ring\n");
 		return -ENOMEM;
 	}
 
@@ -1707,10 +1705,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
 					GFP_KERNEL);
-
 	if (!rxdr->desc) {
-		e_err(probe, "Unable to allocate memory for the Rx descriptor "
-		      "ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
@@ -1729,8 +1724,6 @@ setup_rx_desc_die:
 		if (!rxdr->desc) {
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			e_err(probe, "Unable to allocate memory for the Rx "
-			      "descriptor ring\n");
 			goto setup_rx_desc_die;
 		}
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index ea48083..e23f023 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -720,8 +720,6 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 					GFP_KERNEL);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
-		netif_err(adapter, probe, adapter->netdev,
-			  "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -807,8 +805,6 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 
 	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
-		netif_err(adapter, probe, adapter->netdev,
-			  "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2635b83..ac0c315 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2423,9 +2423,6 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
 					   &rx_ring->dma, GFP_KERNEL);
 
 	if (!rx_ring->desc) {
-		hw_dbg(&adapter->hw,
-		       "Unable to allocate memory for "
-		       "the receive descriptor ring\n");
 		vfree(rx_ring->rx_buffer_info);
 		rx_ring->rx_buffer_info = NULL;
 		goto alloc_failed;
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index cd345b8..e48261e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1969,13 +1969,8 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
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
@@ -2029,13 +2024,8 @@ static int mvneta_txq_init(struct mvneta_port *pp,
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
index 037ed86..3ae4c7f 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1024,11 +1024,9 @@ static int rxq_init(struct net_device *dev)
 	pep->rx_desc_area_size = size;
 	pep->p_rx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
 						&pep->rx_desc_dma, GFP_KERNEL);
-	if (!pep->p_rx_desc_area) {
-		printk(KERN_ERR "%s: Cannot alloc RX ring (size %d bytes)\n",
-		       dev->name, size);
+	if (!pep->p_rx_desc_area)
 		goto out;
-	}
+
 	memset((void *)pep->p_rx_desc_area, 0, size);
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
 	p_rx_desc = pep->p_rx_desc_area;
@@ -1087,11 +1085,8 @@ static int txq_init(struct net_device *dev)
 	pep->tx_desc_area_size = size;
 	pep->p_tx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
 						&pep->tx_desc_dma, GFP_KERNEL);
-	if (!pep->p_tx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-		       dev->name, size);
+	if (!pep->p_tx_desc_area)
 		goto out;
-	}
 	memset((void *)pep->p_tx_desc_area, 0, pep->tx_desc_area_size);
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
 	p_tx_desc = pep->p_tx_desc_area;
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index fdc5f23..05267d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1837,10 +1837,8 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 		priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
 						      &priv->mfunc.vhcr_dma,
 						      GFP_KERNEL);
-		if (!priv->mfunc.vhcr) {
-			mlx4_err(dev, "Couldn't allocate VHCR.\n");
+		if (!priv->mfunc.vhcr)
 			goto err_hcr;
-		}
 	}
 
 	priv->cmd.pool = pci_pool_create("mlx4_cmd", dev->pdev,
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
index 539d202..3df8287 100644
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
index 39ab4d0..4bdca9e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1469,12 +1469,11 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 
 	size = rx_ring->count * bufsz + PCH_GBE_RESERVE_MEMORY;
 	rx_ring->rx_buff_pool = dma_alloc_coherent(&pdev->dev, size,
-						&rx_ring->rx_buff_pool_logic,
-						GFP_KERNEL);
-	if (!rx_ring->rx_buff_pool) {
-		pr_err("Unable to allocate memory for the receive pool buffer\n");
+						   &rx_ring->rx_buff_pool_logic,
+						   GFP_KERNEL);
+	if (!rx_ring->rx_buff_pool)
 		return -ENOMEM;
-	}
+
 	memset(rx_ring->rx_buff_pool, 0, size);
 	rx_ring->rx_buff_pool_size = size;
 	for (i = 0; i < rx_ring->count; i++) {
@@ -1777,7 +1776,6 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 					   &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc) {
 		vfree(tx_ring->buffer_info);
-		pr_err("Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(tx_ring->desc, 0, tx_ring->size);
@@ -1821,9 +1819,7 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
-
 	if (!rx_ring->desc) {
-		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		vfree(rx_ring->buffer_info);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index a69097c..a0649ec 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -532,20 +532,15 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
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
@@ -556,11 +551,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
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
@@ -572,11 +565,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
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
@@ -753,7 +744,7 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 	size_t  nic_size = sizeof(struct qlcnic_info_le);
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-				&nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 	memset(nic_info_addr, 0, nic_size);
@@ -804,7 +795,7 @@ int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
 		return err;
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-			&nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
@@ -949,11 +940,10 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	}
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
+					&stats_dma_t, GFP_KERNEL);
+	if (!stats_addr)
 		return -ENOMEM;
-	}
+
 	memset(stats_addr, 0, stats_size);
 
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
@@ -1003,12 +993,10 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev,
-			"%s: Unable to allocate memory.\n", __func__);
+					&stats_dma_t, GFP_KERNEL);
+	if (!stats_addr)
 		return -ENOMEM;
-	}
+
 	memset(stats_addr, 0, stats_size);
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_MAC_STATS);
 	cmd.req.arg[1] = stats_size << 16;
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
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 39c6c55..d02b446 100644
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
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 8fa947a..99fe3c6 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1309,22 +1309,16 @@ static int tsi108_open(struct net_device *dev)
 	}
 
 	data->rxring = dma_alloc_coherent(NULL, rxring_size,
-			&data->rxdma, GFP_KERNEL);
-
+					  &data->rxdma, GFP_KERNEL);
 	if (!data->rxring) {
-		printk(KERN_DEBUG
-		       "TSI108_ETH: failed to allocate memory for rxring!\n");
 		return -ENOMEM;
 	} else {
 		memset(data->rxring, 0, rxring_size);
 	}
 
 	data->txring = dma_alloc_coherent(NULL, txring_size,
-			&data->txdma, GFP_KERNEL);
-
+					  &data->txdma, GFP_KERNEL);
 	if (!data->txring) {
-		printk(KERN_DEBUG
-		       "TSI108_ETH: failed to allocate memory for txring!\n");
 		pci_free_consistent(0, rxring_size, data->rxring, data->rxdma);
 		return -ENOMEM;
 	} else {
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 5ac43e4..a64a6d7 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -246,19 +246,14 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					 &lp->tx_bd_p, GFP_KERNEL);
-	if (!lp->tx_bd_v) {
-		dev_err(&ndev->dev,
-				"unable to allocate DMA TX buffer descriptors");
+	if (!lp->tx_bd_v)
 		goto out;
-	}
+
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
 					 &lp->rx_bd_p, GFP_KERNEL);
-	if (!lp->rx_bd_v) {
-		dev_err(&ndev->dev,
-				"unable to allocate DMA RX buffer descriptors");
+	if (!lp->rx_bd_v)
 		goto out;
-	}
 
 	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 397d4a6..c238f98 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -205,21 +205,15 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					 &lp->tx_bd_p,
 					 GFP_KERNEL);
-	if (!lp->tx_bd_v) {
-		dev_err(&ndev->dev, "unable to allocate DMA Tx buffer "
-			"descriptors");
+	if (!lp->tx_bd_v)
 		goto out;
-	}
 
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
 					 &lp->rx_bd_p,
 					 GFP_KERNEL);
-	if (!lp->rx_bd_v) {
-		dev_err(&ndev->dev, "unable to allocate DMA Rx buffer "
-			"descriptors");
+	if (!lp->rx_bd_v)
 		goto out;
-	}
 
 	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 502c8ff..f116e51 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -1071,11 +1071,9 @@ static int dfx_driver_init(struct net_device *dev, const char *print_name,
 	bp->kmalloced = top_v = dma_alloc_coherent(bp->bus_dev, alloc_size,
 						   &bp->kmalloced_dma,
 						   GFP_ATOMIC);
-	if (top_v == NULL) {
-		printk("%s: Could not allocate memory for host buffers "
-		       "and structures!\n", print_name);
+	if (top_v == NULL)
 		return DFX_K_FAILURE;
-	}
+
 	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
 	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
 
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
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 5290952..59b45c1 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -564,20 +564,14 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
 				   &self->rx_buff_dma, GFP_KERNEL);
-	if (self->rx_buff.head == NULL) {
-		IRDA_ERROR("%s, Can't allocate memory for receive buffer!\n",
-			   driver_name);
+	if (self->rx_buff.head == NULL)
 		goto err_out2;
-	}
 
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
 				   &self->tx_buff_dma, GFP_KERNEL);
-	if (self->tx_buff.head == NULL) {
-		IRDA_ERROR("%s, Can't allocate memory for transmit buffer!\n",
-			   driver_name);
+	if (self->tx_buff.head == NULL)
 		goto err_out3;
-	}
 
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
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
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 2d3c664..07d7e92 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -335,11 +335,8 @@ static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 					    B43legacy_DMA_RINGMEMSIZE,
 					    &(ring->dmabase),
 					    GFP_KERNEL);
-	if (!ring->descbase) {
-		b43legacyerr(ring->dev->wl, "DMA ringmemory allocation"
-			     " failed\n");
+	if (!ring->descbase)
 		return -ENOMEM;
-	}
 	memset(ring->descbase, 0, B43legacy_DMA_RINGMEMSIZE);
 
 	return 0;
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index e0b9d7f..dc1e6da 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -2379,10 +2379,8 @@ il3945_hw_set_hw_params(struct il_priv *il)
 	il->_3945.shared_virt =
 	    dma_alloc_coherent(&il->pci_dev->dev, sizeof(struct il3945_shared),
 			       &il->_3945.shared_phys, GFP_KERNEL);
-	if (!il->_3945.shared_virt) {
-		IL_ERR("failed to allocate pci memory\n");
+	if (!il->_3945.shared_virt)
 		return -ENOMEM;
-	}
 
 	il->hw_params.bcast_id = IL3945_BROADCAST_ID;
 
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index e006ea8..bd4c188 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -2941,10 +2941,9 @@ il_tx_queue_alloc(struct il_priv *il, struct il_tx_queue *txq, u32 id)
 	 * shared with device */
 	txq->tfds =
 	    dma_alloc_coherent(dev, tfd_sz, &txq->q.dma_addr, GFP_KERNEL);
-	if (!txq->tfds) {
-		IL_ERR("Fail to alloc TFDs\n");
+	if (!txq->tfds)
 		goto error;
-	}
+
 	txq->q.id = id;
 
 	return 0;
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
index 8595c16..7a508d8 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -501,10 +501,8 @@ static int iwl_pcie_txq_alloc(struct iwl_trans *trans,
 	 * shared with device */
 	txq->tfds = dma_alloc_coherent(trans->dev, tfd_sz,
 				       &txq->q.dma_addr, GFP_KERNEL);
-	if (!txq->tfds) {
-		IWL_ERR(trans, "dma_alloc_coherent(%zd) failed\n", tfd_sz);
+	if (!txq->tfds)
 		goto error;
-	}
 
 	BUILD_BUG_ON(IWL_HCMD_SCRATCHBUF_SIZE != sizeof(*txq->scratchbufs));
 	BUILD_BUG_ON(offsetof(struct iwl_pcie_txq_scratch_buf, scratch) !=
-- 
1.8.1.2.459.gbcd45b4.dirty




------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
