From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: shorten wordy fields
Date: Thu,  9 Jan 2014 04:52:20 -0800
Message-ID: <1389271944-26227-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754867AbaAIMwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:38 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The alloc_rx_buff_failed and alloc_rx_page_failed variables
are both part of an rx specific structure so just remove
the _rx part of the name.  No functional changes.

Change-ID: Icffa2f5d13c6f2b1e09cf45b9472b83c9dae8fc6
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 6 +++---
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    | 4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index e227d7cb..0220b18 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -515,10 +515,10 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 rx_ring->stats.bytes,
 			 rx_ring->rx_stats.non_eop_descs);
 		dev_info(&pf->pdev->dev,
-			 "    rx_rings[%i]: rx_stats: alloc_rx_page_failed = %lld, alloc_rx_buff_failed = %lld\n",
+			 "    rx_rings[%i]: rx_stats: alloc_page_failed = %lld, alloc_buff_failed = %lld\n",
 			 i,
-			 rx_ring->rx_stats.alloc_rx_page_failed,
-			rx_ring->rx_stats.alloc_rx_buff_failed);
+			 rx_ring->rx_stats.alloc_page_failed,
+			 rx_ring->rx_stats.alloc_buff_failed);
 		dev_info(&pf->pdev->dev,
 			 "    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
 			 i, rx_ring->size,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4b75de8..e270b61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -786,8 +786,8 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 		} while (u64_stats_fetch_retry_bh(&p->syncp, start));
 		rx_b += bytes;
 		rx_p += packets;
-		rx_buf += p->rx_stats.alloc_rx_buff_failed;
-		rx_page += p->rx_stats.alloc_rx_page_failed;
+		rx_buf += p->rx_stats.alloc_buff_failed;
+		rx_page += p->rx_stats.alloc_page_failed;
 	}
 	rcu_read_unlock();
 	vsi->tx_restart = tx_restart;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index bc72f4e..5245ebb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -774,7 +774,7 @@ void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
 							rx_ring->rx_buf_len);
 			if (!skb) {
-				rx_ring->rx_stats.alloc_rx_buff_failed++;
+				rx_ring->rx_stats.alloc_buff_failed++;
 				goto no_buffers;
 			}
 			/* initialize queue mapping */
@@ -788,7 +788,7 @@ void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
-				rx_ring->rx_stats.alloc_rx_buff_failed++;
+				rx_ring->rx_stats.alloc_buff_failed++;
 				bi->dma = 0;
 				goto no_buffers;
 			}
@@ -798,7 +798,7 @@ void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 			if (!bi->page) {
 				bi->page = alloc_page(GFP_ATOMIC);
 				if (!bi->page) {
-					rx_ring->rx_stats.alloc_rx_page_failed++;
+					rx_ring->rx_stats.alloc_page_failed++;
 					goto no_buffers;
 				}
 			}
@@ -813,7 +813,7 @@ void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 							    DMA_FROM_DEVICE);
 				if (dma_mapping_error(rx_ring->dev,
 						      bi->page_dma)) {
-					rx_ring->rx_stats.alloc_rx_page_failed++;
+					rx_ring->rx_stats.alloc_page_failed++;
 					bi->page_dma = 0;
 					goto no_buffers;
 				}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 7ec744b..6f8506c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -174,8 +174,8 @@ struct i40e_tx_queue_stats {
 
 struct i40e_rx_queue_stats {
 	u64 non_eop_descs;
-	u64 alloc_rx_page_failed;
-	u64 alloc_rx_buff_failed;
+	u64 alloc_page_failed;
+	u64 alloc_buff_failed;
 };
 
 enum i40e_ring_state_t {
-- 
1.8.3.1
