From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40e: Drop unused completed stat
Date: Wed,  9 Oct 2013 23:41:00 -0700
Message-ID: <1381387271-29605-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46635 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab3JJGlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:17 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The Tx "completed" stat was part of the original rewrite for detecting
Tx hangs.  However some time ago in ixgbe I determined that we could
just use the packets stat instead.  Since then this stat was
removed from ixgbe and it serves no purpose in i40e so it can be
dropped.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    | 1 -
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 8dbd91f..0b01c61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -560,10 +560,9 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 				 vsi->tx_rings[i].tx_stats.bytes,
 				 vsi->tx_rings[i].tx_stats.restart_queue);
 			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: tx_stats: tx_busy = %lld, completed = %lld, tx_done_old = %lld\n",
+				 "    tx_rings[%i]: tx_stats: tx_busy = %lld, tx_done_old = %lld\n",
 				 i,
 				 vsi->tx_rings[i].tx_stats.tx_busy,
-				 vsi->tx_rings[i].tx_stats.completed,
 				 vsi->tx_rings[i].tx_stats.tx_done_old);
 			dev_info(&pf->pdev->dev,
 				 "    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 49d2cfa..32c9aeb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -346,8 +346,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		      cpu_to_le64(I40E_TX_DESC_DTYPE_DESC_DONE)))
 			break;
 
-		/* count the packet as being completed */
-		tx_ring->tx_stats.completed++;
+		/* clear next_to_watch to prevent false hangs */
 		tx_buf->next_to_watch = NULL;
 		tx_buf->time_stamp = 0;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index b1d7722..2fbacaf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -134,7 +134,6 @@ struct i40e_tx_queue_stats {
 	u64 bytes;
 	u64 restart_queue;
 	u64 tx_busy;
-	u64 completed;
 	u64 tx_done_old;
 };
 
-- 
1.8.3.1
