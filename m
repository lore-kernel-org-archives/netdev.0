From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 02/13] driver: net: remove unnecessary skb NULL check before calling dev_kfree_skb_irq
Date: Sat,  2 Nov 2013 19:17:43 +0530
Message-ID: <1383400074-30555-3-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:62293 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3KBNsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 09:48:13 -0400
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_kfree_skb_irq is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/amd/ni65.c                   |  6 ++----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   | 10 ++++------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   |  6 ++----
 drivers/net/ethernet/atheros/atlx/atl1.c          |  6 ++----
 drivers/net/ethernet/icplus/ipg.c                 |  6 ++----
 drivers/net/ethernet/intel/e1000e/netdev.c        |  3 +--
 drivers/net/ethernet/marvell/pxa168_eth.c         |  3 +--
 drivers/net/ethernet/xilinx/ll_temac_main.c       |  3 +--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |  6 ++----
 drivers/net/hamradio/scc.c                        | 10 +++-------
 drivers/net/vmxnet3/vmxnet3_drv.c                 |  3 +--
 drivers/net/wireless/ath/ar5523/ar5523.c          |  6 ++----
 12 files changed, 23 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 1cf33ad..0695ce2 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1030,10 +1030,8 @@ static void ni65_xmit_intr(struct net_device *dev,int csr0)
 		}
 
 #ifdef XMT_VIA_SKB
-		if(p->tmd_skb[p->tmdlast]) {
-			 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
-			 p->tmd_skb[p->tmdlast] = NULL;
-		}
+		 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
+		 p->tmd_skb[p->tmdlast] = NULL;
 #endif
 
 		p->tmdlast = (p->tmdlast + 1) & (TMDNUM-1);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index a36a760..cf89008 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -848,12 +848,10 @@ static inline void atl1c_clean_buffer(struct pci_dev *pdev,
 			pci_unmap_page(pdev, buffer_info->dma,
 					buffer_info->length, pci_driection);
 	}
-	if (buffer_info->skb) {
-		if (in_irq)
-			dev_kfree_skb_irq(buffer_info->skb);
-		else
-			dev_kfree_skb(buffer_info->skb);
-	}
+	if (in_irq)
+		dev_kfree_skb_irq(buffer_info->skb);
+	else
+		dev_kfree_skb(buffer_info->skb);
 	buffer_info->dma = 0;
 	buffer_info->skb = NULL;
 	ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 7a73f3a..c3ca8c6 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1257,10 +1257,8 @@ static bool atl1e_clean_tx_irq(struct atl1e_adapter *adapter)
 			tx_buffer->dma = 0;
 		}
 
-		if (tx_buffer->skb) {
-			dev_kfree_skb_irq(tx_buffer->skb);
-			tx_buffer->skb = NULL;
-		}
+		dev_kfree_skb_irq(tx_buffer->skb);
+		tx_buffer->skb = NULL;
 
 		if (++next_to_clean == tx_ring->count)
 			next_to_clean = 0;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..b8cc654 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2082,10 +2082,8 @@ static int atl1_intr_tx(struct atl1_adapter *adapter)
 			buffer_info->dma = 0;
 		}
 
-		if (buffer_info->skb) {
-			dev_kfree_skb_irq(buffer_info->skb);
-			buffer_info->skb = NULL;
-		}
+		dev_kfree_skb_irq(buffer_info->skb);
+		buffer_info->skb = NULL;
 
 		if (++sw_tpd_next_to_clean == tpd_ring->count)
 			sw_tpd_next_to_clean = 0;
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 25045ae..d3a5e1f 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -823,10 +823,8 @@ static void init_tfdlist(struct net_device *dev)
 
 		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
 
-		if (sp->tx_buff[i]) {
-			dev_kfree_skb_irq(sp->tx_buff[i]);
-			sp->tx_buff[i] = NULL;
-		}
+		dev_kfree_skb_irq(sp->tx_buff[i]);
+		sp->tx_buff[i] = NULL;
 
 		txfd->next_desc = cpu_to_le64(sp->txd_map +
 			sizeof(struct ipg_tx)*(i + 1));
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4ef7867..4c22a1a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1526,8 +1526,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 			/* recycle both page and skb */
 			buffer_info->skb = skb;
 			/* an error means any chain goes out the window too */
-			if (rx_ring->rx_skb_top)
-				dev_kfree_skb_irq(rx_ring->rx_skb_top);
+			dev_kfree_skb_irq(rx_ring->rx_skb_top);
 			rx_ring->rx_skb_top = NULL;
 			goto next_desc;
 		}
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index fff6246..7443b11 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -749,8 +749,7 @@ static int txq_reclaim(struct net_device *dev, int force)
 			dev->stats.tx_errors++;
 		}
 		dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
-		if (skb)
-			dev_kfree_skb_irq(skb);
+		dev_kfree_skb_irq(skb);
 		released++;
 	}
 txq_reclaim_end:
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 0029148..3d21741 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -629,8 +629,7 @@ static void temac_start_xmit_done(struct net_device *ndev)
 	while (stat & STS_CTRL_APP0_CMPLT) {
 		dma_unmap_single(ndev->dev.parent, cur_p->phys, cur_p->len,
 				 DMA_TO_DEVICE);
-		if (cur_p->app4)
-			dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
+		dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
 		cur_p->app0 = 0;
 		cur_p->app1 = 0;
 		cur_p->app2 = 0;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b2ff038..f3bcabb 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -589,8 +589,7 @@ static void axienet_start_xmit_done(struct net_device *ndev)
 		dma_unmap_single(ndev->dev.parent, cur_p->phys,
 				(cur_p->cntrl & XAXIDMA_BD_CTRL_LENGTH_MASK),
 				DMA_TO_DEVICE);
-		if (cur_p->app4)
-			dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
+		dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
 		/*cur_p->phys = 0;*/
 		cur_p->app0 = 0;
 		cur_p->app1 = 0;
@@ -1367,8 +1366,7 @@ static void axienet_dma_err_handler(unsigned long data)
 					 (cur_p->cntrl &
 					  XAXIDMA_BD_CTRL_LENGTH_MASK),
 					 DMA_TO_DEVICE);
-		if (cur_p->app4)
-			dev_kfree_skb_irq((struct sk_buff *) cur_p->app4);
+		dev_kfree_skb_irq((struct sk_buff *) cur_p->app4);
 		cur_p->phys = 0;
 		cur_p->cntrl = 0;
 		cur_p->status = 0;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 4bc6ee8..0abd1e3 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -496,11 +496,8 @@ static inline void scc_exint(struct scc_channel *scc)
 		scc->stat.tx_under++;	  /* oops, an underrun! count 'em */
 		Outb(scc->ctrl, RES_EXT_INT);	/* reset ext/status interrupts */
 
-		if (scc->tx_buff != NULL)
-		{
-			dev_kfree_skb_irq(scc->tx_buff);
-			scc->tx_buff = NULL;
-		}
+		dev_kfree_skb_irq(scc->tx_buff);
+		scc->tx_buff = NULL;
 		
 		or(scc,R10,ABUNDER);
 		scc_start_tx_timer(scc, t_txdelay, 0);	/* restart transmission */
@@ -577,8 +574,7 @@ static inline void scc_spint(struct scc_channel *scc)
 		scc->stat.rx_over++;             /* count them */
 		or(scc,R3,ENT_HM);               /* enter hunt mode for next flag */
 		
-		if (skb != NULL) 
-			dev_kfree_skb_irq(skb);
+		dev_kfree_skb_irq(skb);
 		scc->rx_buff = skb = NULL;
 	}
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e2788c..64ca248 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1142,8 +1142,7 @@ vmxnet3_rx_error(struct vmxnet3_rx_queue *rq, struct Vmxnet3_RxCompDesc *rcd,
 	 * ctx->skb may be NULL if this is the first and the only one
 	 * desc for the pkt
 	 */
-	if (ctx->skb)
-		dev_kfree_skb_irq(ctx->skb);
+	dev_kfree_skb_irq(ctx->skb);
 
 	ctx->skb = NULL;
 }
diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index 280fc3d..cb0dd61 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -601,10 +601,8 @@ static void ar5523_data_rx_cb(struct urb *urb)
 	data->skb = NULL;
 
 skip:
-	if (data->skb) {
-		dev_kfree_skb_irq(data->skb);
-		data->skb = NULL;
-	}
+	dev_kfree_skb_irq(data->skb);
+	data->skb = NULL;
 
 	ar5523_rx_data_put(ar, data);
 	if (atomic_inc_return(&ar->rx_data_free_cnt) >=
-- 
1.8.4.2
