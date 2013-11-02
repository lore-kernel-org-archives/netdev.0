From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 06/13] driver: net: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:47 +0530
Message-ID: <1383400074-30555-7-git-send-email-govindarajulu90@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_any is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/amd/lance.c                     |  9 +++------
 drivers/net/ethernet/atheros/alx/main.c              |  6 ++----
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |  6 ++----
 drivers/net/ethernet/atheros/atlx/atl1.c             |  6 ++----
 drivers/net/ethernet/cisco/enic/enic_main.c          |  3 +--
 drivers/net/ethernet/freescale/fec_main.c            |  6 ++----
 drivers/net/ethernet/hp/hp100.c                      |  3 +--
 drivers/net/ethernet/intel/e1000/e1000_main.c        |  6 ++----
 drivers/net/ethernet/intel/e1000e/netdev.c           | 12 ++++--------
 drivers/net/ethernet/intel/igb/igb_ptp.c             |  6 ++----
 drivers/net/ethernet/intel/igbvf/netdev.c            |  6 ++----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |  6 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c         |  6 ++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |  6 ++----
 drivers/net/ethernet/korina.c                        | 12 ++++--------
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 12 ++++--------
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |  9 +++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c     |  6 ++----
 drivers/net/ethernet/seeq/sgiseeq.c                  |  6 ++----
 drivers/net/ethernet/sgi/ioc3-eth.c                  |  9 +++------
 drivers/net/ethernet/smsc/smsc9420.c                 |  3 +--
 drivers/net/ethernet/sun/sunbmac.c                   | 12 ++++--------
 drivers/net/ethernet/ti/cpmac.c                      |  6 ++----
 drivers/net/hyperv/netvsc_drv.c                      |  3 +--
 drivers/net/irda/vlsi_ir.c                           | 15 +++++----------
 drivers/net/usb/cdc_mbim.c                           |  3 +--
 drivers/net/usb/cdc_ncm.c                            | 15 +++++----------
 drivers/net/usb/lg-vl600.c                           |  6 ++----
 drivers/net/usb/usbnet.c                             |  3 +--
 drivers/net/vmxnet3/vmxnet3_drv.c                    |  6 ++----
 drivers/net/wireless/ath/ath10k/mac.c                |  6 ++----
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c        |  3 +--
 drivers/net/wireless/ath/ath9k/main.c                |  6 ++----
 drivers/net/wireless/ath/ath9k/recv.c                |  6 ++----
 drivers/net/wireless/ath/wil6210/txrx.c              |  6 ++----
 drivers/net/wireless/b43/main.c                      |  9 +++------
 drivers/net/wireless/b43legacy/main.c                |  9 +++------
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c  |  3 +--
 drivers/net/wireless/brcm80211/brcmsmac/main.c       | 12 ++++--------
 drivers/net/wireless/ipw2x00/ipw2200.c               |  6 ++----
 drivers/net/wireless/ipw2x00/libipw_rx.c             |  3 +--
 drivers/net/wireless/ipw2x00/libipw_tx.c             |  3 +--
 drivers/net/wireless/mwifiex/init.c                  |  3 +--
 43 files changed, 96 insertions(+), 192 deletions(-)

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 256f590..4b8fc50 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -845,14 +845,11 @@ lance_purge_ring(struct net_device *dev)
 		struct sk_buff *skb = lp->rx_skbuff[i];
 		lp->rx_skbuff[i] = NULL;
 		lp->rx_ring[i].base = 0;		/* Not owned by LANCE chip. */
-		if (skb)
-			dev_kfree_skb_any(skb);
+		dev_kfree_skb_any(skb);
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		if (lp->tx_skbuff[i]) {
-			dev_kfree_skb_any(lp->tx_skbuff[i]);
-			lp->tx_skbuff[i] = NULL;
-		}
+		dev_kfree_skb_any(lp->tx_skbuff[i]);
+		lp->tx_skbuff[i] = NULL;
 	}
 }
 
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 5aa5e81..2bee48b 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -64,10 +64,8 @@ static void alx_free_txbuf(struct alx_priv *alx, int entry)
 		dma_unmap_len_set(txb, size, 0);
 	}
 
-	if (txb->skb) {
-		dev_kfree_skb_any(txb->skb);
-		txb->skb = NULL;
-	}
+	dev_kfree_skb_any(txb->skb);
+	txb->skb = NULL;
 }
 
 static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index c3ca8c6..b420ead 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -686,10 +686,8 @@ static void atl1e_clean_tx_ring(struct atl1e_adapter *adapter)
 	/* second free skb */
 	for (index = 0; index < ring_count; index++) {
 		tx_buffer = &tx_ring->tx_buffer[index];
-		if (tx_buffer->skb) {
-			dev_kfree_skb_any(tx_buffer->skb);
-			tx_buffer->skb = NULL;
-		}
+		dev_kfree_skb_any(tx_buffer->skb);
+		tx_buffer->skb = NULL;
 	}
 	/* Zero out Tx-buffers */
 	memset(tx_ring->desc, 0, sizeof(struct atl1e_tpd_desc) *
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index b8cc654..5fd7212 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1205,10 +1205,8 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 
 	for (i = 0; i < tpd_ring->count; i++) {
 		buffer_info = &tpd_ring->buffer_info[i];
-		if (buffer_info->skb) {
-			dev_kfree_skb_any(buffer_info->skb);
-			buffer_info->skb = NULL;
-		}
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
 	}
 
 	size = sizeof(struct atl1_buffer) * tpd_ring->count;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ff78dfa..b436a92 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -107,8 +107,7 @@ static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *buf)
 		pci_unmap_page(enic->pdev, buf->dma_addr,
 			buf->len, PCI_DMA_TODEVICE);
 
-	if (buf->os_buf)
-		dev_kfree_skb_any(buf->os_buf);
+	dev_kfree_skb_any(buf->os_buf);
 }
 
 static void enic_wq_free_buf(struct vnic_wq *wq,
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2793b9..9c6a8a6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -548,10 +548,8 @@ fec_restart(struct net_device *ndev, int duplex)
 
 
 	for (i = 0; i <= TX_RING_MOD_MASK; i++) {
-		if (fep->tx_skbuff[i]) {
-			dev_kfree_skb_any(fep->tx_skbuff[i]);
-			fep->tx_skbuff[i] = NULL;
-		}
+		dev_kfree_skb_any(fep->tx_skbuff[i]);
+		fep->tx_skbuff[i] = NULL;
 	}
 
 	/* Enable MII mode */
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 3786009..240d3adb 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1952,8 +1952,7 @@ static void hp100_rx_bm(struct net_device *dev)
 #ifdef HP100_DEBUG
 			printk("hp100: %s: rx_bm: Received bad packet (length=%d)\n", dev->name, pkt_len);
 #endif
-			if (ptr->skb != NULL)
-				dev_kfree_skb_any(ptr->skb);
+			dev_kfree_skb_any(ptr->skb);
 			dev->stats.rx_errors++;
 		}
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index ad6800a..890dcba 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1968,10 +1968,8 @@ static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 					 DMA_TO_DEVICE);
 		buffer_info->dma = 0;
 	}
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 	buffer_info->time_stamp = 0;
 	/* buffer_info must be completely set up in the transmit path */
 }
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4c22a1a..a562f54 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1057,10 +1057,8 @@ static void e1000_put_txbuf(struct e1000_ring *tx_ring,
 					 buffer_info->length, DMA_TO_DEVICE);
 		buffer_info->dma = 0;
 	}
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 	buffer_info->time_stamp = 0;
 }
 
@@ -6893,10 +6891,8 @@ static void e1000_remove(struct pci_dev *pdev)
 
 	if (adapter->flags & FLAG_HAS_HW_TIMESTAMP) {
 		cancel_work_sync(&adapter->tx_hwtstamp_work);
-		if (adapter->tx_hwtstamp_skb) {
-			dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
-			adapter->tx_hwtstamp_skb = NULL;
-		}
+		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
+		adapter->tx_hwtstamp_skb = NULL;
 	}
 
 	if (!(netdev->flags & IFF_UP))
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 5a54e3d..ed8b232 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -838,10 +838,8 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 	}
 
 	cancel_work_sync(&adapter->ptp_tx_work);
-	if (adapter->ptp_tx_skb) {
-		dev_kfree_skb_any(adapter->ptp_tx_skb);
-		adapter->ptp_tx_skb = NULL;
-	}
+	dev_kfree_skb_any(adapter->ptp_tx_skb);
+	adapter->ptp_tx_skb = NULL;
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 9fadbb2..1220dd1 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -417,10 +417,8 @@ static void igbvf_put_txbuf(struct igbvf_adapter *adapter,
 					 DMA_TO_DEVICE);
 		buffer_info->dma = 0;
 	}
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 	buffer_info->time_stamp = 0;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 9f6b236..468b7c6 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -941,10 +941,8 @@ ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
 		buffer_info->dma = 0;
 	}
 
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 	buffer_info->time_stamp = 0;
 	/* these fields must always be initialized in tx
 	 * buffer_info->length = 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5184e2a..cf4648a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -908,10 +908,8 @@ void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 	ixgbe_ptp_setup_sdp(adapter);
 
 	cancel_work_sync(&adapter->ptp_tx_work);
-	if (adapter->ptp_tx_skb) {
-		dev_kfree_skb_any(adapter->ptp_tx_skb);
-		adapter->ptp_tx_skb = NULL;
-	}
+	dev_kfree_skb_any(adapter->ptp_tx_skb);
+	adapter->ptp_tx_skb = NULL;
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 038bfc8..8d0fb73 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -159,10 +159,8 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
 					 DMA_TO_DEVICE);
 		tx_buffer_info->dma = 0;
 	}
-	if (tx_buffer_info->skb) {
-		dev_kfree_skb_any(tx_buffer_info->skb);
-		tx_buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(tx_buffer_info->skb);
+	tx_buffer_info->skb = NULL;
 	tx_buffer_info->time_stamp = 0;
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 4a5e3b0..5efb977 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -572,10 +572,8 @@ static void korina_tx(struct net_device *dev)
 		}
 
 		/* We must always free the original skb */
-		if (lp->tx_skb[lp->tx_next_done]) {
-			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
-			lp->tx_skb[lp->tx_next_done] = NULL;
-		}
+		dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
+		lp->tx_skb[lp->tx_next_done] = NULL;
 
 		lp->td_ring[lp->tx_next_done].control = DMA_DESC_IOF;
 		lp->td_ring[lp->tx_next_done].devcs = ETH_TX_FD | ETH_TX_LD;
@@ -785,15 +783,13 @@ static void korina_free_ring(struct net_device *dev)
 
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
 		lp->rd_ring[i].control = 0;
-		if (lp->rx_skb[i])
-			dev_kfree_skb_any(lp->rx_skb[i]);
+		dev_kfree_skb_any(lp->rx_skb[i]);
 		lp->rx_skb[i] = NULL;
 	}
 
 	for (i = 0; i < KORINA_NUM_TDS; i++) {
 		lp->td_ring[i].control = 0;
-		if (lp->tx_skb[i])
-			dev_kfree_skb_any(lp->tx_skb[i]);
+		dev_kfree_skb_any(lp->tx_skb[i]);
 		lp->tx_skb[i] = NULL;
 	}
 }
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 5a0f04c..5ed4b92 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -953,10 +953,8 @@ static void pch_gbe_unmap_and_free_tx_resource(
 				 buffer_info->length, DMA_TO_DEVICE);
 		buffer_info->mapped = false;
 	}
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 }
 
 /**
@@ -973,10 +971,8 @@ static void pch_gbe_unmap_and_free_rx_resource(
 				 buffer_info->length, DMA_FROM_DEVICE);
 		buffer_info->mapped = false;
 	}
-	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+	dev_kfree_skb_any(buffer_info->skb);
+	buffer_info->skb = NULL;
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 7692dfd..e9710c0 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -124,8 +124,7 @@ void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 					rx_buf->dma,
 					rds_ring->dma_size,
 					PCI_DMA_FROMDEVICE);
-			if (rx_buf->skb != NULL)
-				dev_kfree_skb_any(rx_buf->skb);
+			dev_kfree_skb_any(rx_buf->skb);
 		}
 	}
 }
@@ -154,10 +153,8 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 				buffrag->dma = 0ULL;
 			}
 		}
-		if (cmd_buf->skb) {
-			dev_kfree_skb_any(cmd_buf->skb);
-			cmd_buf->skb = NULL;
-		}
+		dev_kfree_skb_any(cmd_buf->skb);
+		cmd_buf->skb = NULL;
 		cmd_buf++;
 	}
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 66c26cf..d2c23f5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -151,10 +151,8 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter,
 				buffrag->dma = 0ULL;
 			}
 		}
-		if (cmd_buf->skb) {
-			dev_kfree_skb_any(cmd_buf->skb);
-			cmd_buf->skb = NULL;
-		}
+		dev_kfree_skb_any(cmd_buf->skb);
+		cmd_buf->skb = NULL;
 		cmd_buf++;
 	}
 }
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index c765718..a49ce76 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -486,10 +486,8 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 		sp->tx_old = NEXT_TX(sp->tx_old);
 		td->tdma.cntinfo &= ~(HPCDMA_XIU | HPCDMA_XIE);
 		td->tdma.cntinfo |= HPCDMA_EOX;
-		if (td->skb) {
-			dev_kfree_skb_any(td->skb);
-			td->skb = NULL;
-		}
+		dev_kfree_skb_any(td->skb);
+		td->skb = NULL;
 		dma_sync_desc_dev(dev, td);
 	}
 }
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index ffa7843..6bd90f2 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -856,10 +856,8 @@ static inline void ioc3_clean_tx_ring(struct ioc3_private *ip)
 
 	for (i=0; i < 128; i++) {
 		skb = ip->tx_skbs[i];
-		if (skb) {
-			ip->tx_skbs[i] = NULL;
-			dev_kfree_skb_any(skb);
-		}
+		ip->tx_skbs[i] = NULL;
+		dev_kfree_skb_any(skb);
 		ip->txr[i].cmd = 0;
 	}
 	ip->tx_pi = 0;
@@ -883,8 +881,7 @@ static void ioc3_free_rings(struct ioc3_private *ip)
 
 		while (n_entry != rx_entry) {
 			skb = ip->rx_skbs[n_entry];
-			if (skb)
-				dev_kfree_skb_any(skb);
+			dev_kfree_skb_any(skb);
 
 			n_entry = (n_entry + 1) & 511;
 		}
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 059bcaf..e45d7c7 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -595,8 +595,7 @@ static void smsc9420_free_rx_ring(struct smsc9420_pdata *pd)
 		return;
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		if (pd->rx_buffers[i].skb)
-			dev_kfree_skb_any(pd->rx_buffers[i].skb);
+		dev_kfree_skb_any(pd->rx_buffers[i].skb);
 
 		if (pd->rx_buffers[i].mapping)
 			pci_unmap_single(pd->pdev, pd->rx_buffers[i].mapping,
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 7217ee5..50eb0f1 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -195,17 +195,13 @@ static void bigmac_clean_rings(struct bigmac *bp)
 	int i;
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		if (bp->rx_skbs[i] != NULL) {
-			dev_kfree_skb_any(bp->rx_skbs[i]);
-			bp->rx_skbs[i] = NULL;
-		}
+		dev_kfree_skb_any(bp->rx_skbs[i]);
+		bp->rx_skbs[i] = NULL;
 	}
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		if (bp->tx_skbs[i] != NULL) {
-			dev_kfree_skb_any(bp->tx_skbs[i]);
-			bp->tx_skbs[i] = NULL;
-		}
+		dev_kfree_skb_any(bp->tx_skbs[i]);
+		bp->tx_skbs[i] = NULL;
 	}
 }
 
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 2dc16b6..ba340a8 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -728,10 +728,8 @@ static void cpmac_clear_tx(struct net_device *dev)
 		return;
 	for (i = 0; i < CPMAC_QUEUES; i++) {
 		priv->desc_ring[i].dataflags = 0;
-		if (priv->desc_ring[i].skb) {
-			dev_kfree_skb_any(priv->desc_ring[i].skb);
-			priv->desc_ring[i].skb = NULL;
-		}
+		dev_kfree_skb_any(priv->desc_ring[i].skb);
+		priv->desc_ring[i].skb = NULL;
 	}
 }
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 524f713..b051c45 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -128,8 +128,7 @@ static void netvsc_xmit_completion(void *context)
 
 	kfree(packet);
 
-	if (skb)
-		dev_kfree_skb_any(skb);
+	dev_kfree_skb_any(skb);
 }
 
 static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index c5bd58b..49882f7 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -467,8 +467,7 @@ static int vlsi_free_ring(struct vlsi_ring *r)
 
 	for (i = 0; i < r->size; i++) {
 		rd = r->rd + i;
-		if (rd->skb)
-			dev_kfree_skb_any(rd->skb);
+		dev_kfree_skb_any(rd->skb);
 		busaddr = rd_get_addr(rd);
 		rd_set_addr_status(rd, 0, 0);
 		if (busaddr)
@@ -703,10 +702,8 @@ static void vlsi_unarm_rx(vlsi_irda_dev_t *idev)
 			}
 			rd_set_count(rd, 0);
 			pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
-			if (rd->skb) {
-				dev_kfree_skb_any(rd->skb);
-				rd->skb = NULL;
-			}
+			dev_kfree_skb_any(rd->skb);
+			rd->skb = NULL;
 		}
 		else
 			ret = vlsi_process_rx(r, rd);
@@ -1136,10 +1133,8 @@ static void vlsi_unarm_tx(vlsi_irda_dev_t *idev)
 			rd_set_status(rd, 0);
 			rd_set_count(rd, 0);
 			pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
-			if (rd->skb) {
-				dev_kfree_skb_any(rd->skb);
-				rd->skb = NULL;
-			}
+			dev_kfree_skb_any(rd->skb);
+			rd->skb = NULL;
 			IRDA_DEBUG(0, "%s - dropping tx packet\n", __func__);
 			ret = -VLSI_TX_DROP;
 		}
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index af76aaf..0986ba0 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -180,8 +180,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usbnet *dev, struct sk_buff *skb
 	return skb_out;
 
 error:
-	if (skb)
-		dev_kfree_skb_any(skb);
+	dev_kfree_skb_any(skb);
 
 	return NULL;
 }
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 11c7033..160d854 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -311,15 +311,11 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 	if (ctx == NULL)
 		return;
 
-	if (ctx->tx_rem_skb != NULL) {
-		dev_kfree_skb_any(ctx->tx_rem_skb);
-		ctx->tx_rem_skb = NULL;
-	}
+	dev_kfree_skb_any(ctx->tx_rem_skb);
+	ctx->tx_rem_skb = NULL;
 
-	if (ctx->tx_curr_skb != NULL) {
-		dev_kfree_skb_any(ctx->tx_curr_skb);
-		ctx->tx_curr_skb = NULL;
-	}
+	dev_kfree_skb_any(ctx->tx_curr_skb);
+	ctx->tx_curr_skb = NULL;
 
 	kfree(ctx);
 }
@@ -852,8 +848,7 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	return skb_out;
 
 error:
-	if (skb != NULL)
-		dev_kfree_skb_any(skb);
+	dev_kfree_skb_any(skb);
 
 	return NULL;
 }
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index 808d650..7ecf203 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -238,10 +238,8 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 error:
-	if (s->current_rx_buf) {
-		dev_kfree_skb_any(s->current_rx_buf);
-		s->current_rx_buf = NULL;
-	}
+	dev_kfree_skb_any(s->current_rx_buf);
+	s->current_rx_buf = NULL;
 	dev->net->stats.rx_errors++;
 	return 0;
 }
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 90a429b..b37f812 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1377,8 +1377,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 drop:
 		dev->net->stats.tx_dropped++;
 not_drop:
-		if (skb)
-			dev_kfree_skb_any (skb);
+		dev_kfree_skb_any (skb);
 		if (urb) {
 			kfree(urb->sg);
 			usb_free_urb(urb);
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 64ca248..2fd7034 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -403,10 +403,8 @@ vmxnet3_tq_cleanup(struct vmxnet3_tx_queue *tq,
 		tbi = tq->buf_info + tq->tx_ring.next2comp;
 
 		vmxnet3_unmap_tx_buf(tbi, adapter->pdev);
-		if (tbi->skb) {
-			dev_kfree_skb_any(tbi->skb);
-			tbi->skb = NULL;
-		}
+		dev_kfree_skb_any(tbi->skb);
+		tbi->skb = NULL;
 		vmxnet3_cmd_ring_adv_next2comp(&tq->tx_ring);
 	}
 
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 99a9bad..7918569 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -2067,10 +2067,8 @@ static void ath10k_remove_interface(struct ieee80211_hw *hw,
 	mutex_lock(&ar->conf_mutex);
 
 	spin_lock_bh(&ar->data_lock);
-	if (arvif->beacon) {
-		dev_kfree_skb_any(arvif->beacon);
-		arvif->beacon = NULL;
-	}
+	dev_kfree_skb_any(arvif->beacon);
+	arvif->beacon = NULL;
 	spin_unlock_bh(&ar->data_lock);
 
 	ar->free_vdev_map |= 1 << (arvif->vdev_id);
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index c028df7..69d9b44 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1200,8 +1200,7 @@ void ath9k_rx_cleanup(struct ath9k_htc_priv *priv)
 
 	list_for_each_entry_safe(rxbuf, tbuf, &priv->rx.rxbuf, list) {
 		list_del(&rxbuf->list);
-		if (rxbuf->skb)
-			dev_kfree_skb_any(rxbuf->skb);
+		dev_kfree_skb_any(rxbuf->skb);
 		kfree(rxbuf);
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 20a2fbc..8125b1b 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -871,10 +871,8 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	ath_prepare_reset(sc);
 
-	if (sc->rx.frag) {
-		dev_kfree_skb_any(sc->rx.frag);
-		sc->rx.frag = NULL;
-	}
+	dev_kfree_skb_any(sc->rx.frag);
+	sc->rx.frag = NULL;
 
 	if (!ah->curchan)
 		ah->curchan = ath9k_cmn_get_channel(hw, ah, &hw->conf.chandef);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 8b788ef..679e05d 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1454,10 +1454,8 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		ieee80211_rx(hw, skb);
 
 requeue_drop_frag:
-		if (sc->rx.frag) {
-			dev_kfree_skb_any(sc->rx.frag);
-			sc->rx.frag = NULL;
-		}
+		dev_kfree_skb_any(sc->rx.frag);
+		sc->rx.frag = NULL;
 requeue:
 		list_add_tail(&bf->list, &sc->rx.rxbuf);
 		if (flush)
diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wireless/ath/wil6210/txrx.c
index d505b26..a6a46d7 100644
--- a/drivers/net/wireless/ath/wil6210/txrx.c
+++ b/drivers/net/wireless/ath/wil6210/txrx.c
@@ -130,8 +130,7 @@ static void wil_vring_free(struct wil6210_priv *wil, struct vring *vring,
 				dma_unmap_single(dev, pa, dmalen,
 						 DMA_TO_DEVICE);
 			}
-			if (ctx->skb)
-				dev_kfree_skb_any(ctx->skb);
+			dev_kfree_skb_any(ctx->skb);
 			vring->swtail = wil_vring_next_tail(vring);
 		} else { /* rx */
 			struct vring_rx_desc dd, *d = &dd;
@@ -819,8 +818,7 @@ static int wil_tx_vring(struct wil6210_priv *wil, struct vring *vring,
 		else
 			dma_unmap_single(dev, pa, dmalen, DMA_TO_DEVICE);
 
-		if (ctx->skb)
-			dev_kfree_skb_any(ctx->skb);
+		dev_kfree_skb_any(ctx->skb);
 
 		memset(ctx, 0, sizeof(*ctx));
 	}
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ccd24f0a..449d98d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1755,8 +1755,7 @@ static void b43_update_templates(struct b43_wl *wl)
 	if (unlikely(!beacon))
 		return;
 
-	if (wl->current_beacon)
-		dev_kfree_skb_any(wl->current_beacon);
+	dev_kfree_skb_any(wl->current_beacon);
 	wl->current_beacon = beacon;
 	wl->beacon0_uploaded = false;
 	wl->beacon1_uploaded = false;
@@ -4662,10 +4661,8 @@ static void b43_wireless_core_exit(struct b43_wldev *dev)
 	b43_pio_free(dev);
 	b43_chip_exit(dev);
 	dev->phy.ops->switch_analog(dev, 0);
-	if (dev->wl->current_beacon) {
-		dev_kfree_skb_any(dev->wl->current_beacon);
-		dev->wl->current_beacon = NULL;
-	}
+	dev_kfree_skb_any(dev->wl->current_beacon);
+	dev->wl->current_beacon = NULL;
 
 	b43_device_disable(dev, 0);
 	b43_bus_may_powerdown(dev);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 5726688..4751b22 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -1274,8 +1274,7 @@ static void b43legacy_update_templates(struct b43legacy_wl *wl)
 	if (unlikely(!beacon))
 		return;
 
-	if (wl->current_beacon)
-		dev_kfree_skb_any(wl->current_beacon);
+	dev_kfree_skb_any(wl->current_beacon);
 	wl->current_beacon = beacon;
 	wl->beacon0_uploaded = false;
 	wl->beacon1_uploaded = false;
@@ -3233,10 +3232,8 @@ static void b43legacy_wireless_core_exit(struct b43legacy_wldev *dev)
 		kfree(phy->tssi2dbm);
 	kfree(phy->lo_control);
 	phy->lo_control = NULL;
-	if (dev->wl->current_beacon) {
-		dev_kfree_skb_any(dev->wl->current_beacon);
-		dev->wl->current_beacon = NULL;
-	}
+	dev_kfree_skb_any(dev->wl->current_beacon);
+	dev->wl->current_beacon = NULL;
 
 	ssb_device_disable(dev->dev, 0);
 	ssb_bus_may_powerdown(dev->dev->bus);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 64e9cff..402a642 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -878,8 +878,7 @@ static int brcmf_net_p2p_do_ioctl(struct net_device *ndev,
 static netdev_tx_t brcmf_net_p2p_start_xmit(struct sk_buff *skb,
 					    struct net_device *ndev)
 {
-	if (skb)
-		dev_kfree_skb_any(skb);
+	dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 8138f1c..07f63db 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -449,10 +449,8 @@ static void brcms_c_detach_mfree(struct brcms_c_info *wlc)
 	kfree(wlc->corestate);
 	kfree(wlc->hw->bandstate[0]);
 	kfree(wlc->hw);
-	if (wlc->beacon)
-		dev_kfree_skb_any(wlc->beacon);
-	if (wlc->probe_resp)
-		dev_kfree_skb_any(wlc->probe_resp);
+	dev_kfree_skb_any(wlc->beacon);
+	dev_kfree_skb_any(wlc->probe_resp);
 
 	/* free the wlc */
 	kfree(wlc);
@@ -7470,8 +7468,7 @@ void brcms_c_set_new_beacon(struct brcms_c_info *wlc, struct sk_buff *beacon,
 {
 	if (!beacon)
 		return;
-	if (wlc->beacon)
-		dev_kfree_skb_any(wlc->beacon);
+	dev_kfree_skb_any(wlc->beacon);
 	wlc->beacon = beacon;
 
 	/* add PLCP */
@@ -7486,8 +7483,7 @@ void brcms_c_set_new_probe_resp(struct brcms_c_info *wlc,
 {
 	if (!probe_resp)
 		return;
-	if (wlc->probe_resp)
-		dev_kfree_skb_any(wlc->probe_resp);
+	dev_kfree_skb_any(wlc->probe_resp);
 	wlc->probe_resp = probe_resp;
 
 	/* add PLCP */
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 81903e3..f803ca1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -8538,10 +8538,8 @@ static void ipw_rx(struct ipw_priv *priv)
 		/* For now we just don't re-use anything.  We can tweak this
 		 * later to try and re-use notification packets and SKBs that
 		 * fail to Rx correctly */
-		if (rxb->skb != NULL) {
-			dev_kfree_skb_any(rxb->skb);
-			rxb->skb = NULL;
-		}
+		dev_kfree_skb_any(rxb->skb);
+		rxb->skb = NULL;
 
 		pci_unmap_single(priv->pci_dev, rxb->dma_addr,
 				 IPW_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 9ffe659..4411888 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -113,8 +113,7 @@ static struct sk_buff *libipw_frag_cache_get(struct libipw_device *ieee,
 		if (ieee->frag_next_idx >= LIBIPW_FRAG_CACHE_LEN)
 			ieee->frag_next_idx = 0;
 
-		if (entry->skb != NULL)
-			dev_kfree_skb_any(entry->skb);
+		dev_kfree_skb_any(entry->skb);
 
 		entry->first_frag_time = jiffies;
 		entry->seq = seq;
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index e8c0398..b04243a 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -183,8 +183,7 @@ void libipw_txb_free(struct libipw_txb *txb)
 	if (unlikely(!txb))
 		return;
 	for (i = 0; i < txb->nr_frags; i++)
-		if (txb->fragments[i])
-			dev_kfree_skb_any(txb->fragments[i]);
+		dev_kfree_skb_any(txb->fragments[i]);
 	kfree(txb);
 }
 
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwifiex/init.c
index 6499117..ffd0751 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -395,8 +395,7 @@ mwifiex_adapter_cleanup(struct mwifiex_adapter *adapter)
 
 	dev_dbg(adapter->dev, "info: free scan table\n");
 
-	if (adapter->sleep_cfm)
-		dev_kfree_skb_any(adapter->sleep_cfm);
+	dev_kfree_skb_any(adapter->sleep_cfm);
 }
 
 /*
-- 
1.8.4.2
