From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Wed, 9 Feb 2011 11:56:09 +1100
Message-ID: <20110209115609.79932942.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e1000e/netdev.c between commit
463342741222c79469303cdab8ce99c8bc2d80e8 ("e1000e: tx_timeout should not
increment for non-hang events") from the net-current tree and commit
90da06692532541a38f9857972e1fd6b1cdfb45a ("e1000e: reduce scope of some
variables, remove unnecessary ones") from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e1000e/netdev.c
index 3065870,5b916b0..0000000
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@@ -4299,20 -4303,18 +4303,17 @@@ link_up
  
  	e1000e_update_adaptive(&adapter->hw);
  
- 	if (!netif_carrier_ok(netdev)) {
- 		tx_pending = (e1000_desc_unused(tx_ring) + 1 <
- 			       tx_ring->count);
- 		if (tx_pending) {
- 			/*
- 			 * We've lost link, so the controller stops DMA,
- 			 * but we've got queued Tx work that's never going
- 			 * to get done, so reset controller to flush Tx.
- 			 * (Do the reset outside of interrupt context).
- 			 */
- 			schedule_work(&adapter->reset_task);
- 			/* return immediately since reset is imminent */
- 			return;
- 		}
+ 	if (!netif_carrier_ok(netdev) &&
+ 	    (e1000_desc_unused(tx_ring) + 1 < tx_ring->count)) {
+ 		/*
+ 		 * We've lost link, so the controller stops DMA,
+ 		 * but we've got queued Tx work that's never going
+ 		 * to get done, so reset controller to flush Tx.
+ 		 * (Do the reset outside of interrupt context).
+ 		 */
 -		adapter->tx_timeout_count++;
+ 		schedule_work(&adapter->reset_task);
+ 		/* return immediately since reset is imminent */
+ 		return;
  	}
  
  	/* Simple mode for Interrupt Throttle Rate (ITR) */
