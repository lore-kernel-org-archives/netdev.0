From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Drop extra copy of function
Date: Sun,  1 May 2016 17:06:15 -0700
Message-ID: <1462147581-135254-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbcEBAG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:29 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

i40e_release_rx_desc was in two files, but was only used
and needed in txrx.c.  Get rid of the extra copy.

Change-Id: I86e18239aa03531fc198b6c052847475084a9200
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a45748e..d6b1b98 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -397,24 +397,6 @@ static void i40e_tx_timeout(struct net_device *netdev)
 }
 
 /**
- * i40e_release_rx_desc - Store the new tail and head values
- * @rx_ring: ring to bump
- * @val: new head index
- **/
-static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring, u32 val)
-{
-	rx_ring->next_to_use = val;
-
-	/* Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64).
-	 */
-	wmb();
-	writel(val, rx_ring->tail);
-}
-
-/**
  * i40e_get_vsi_stats_struct - Get System Network Statistics
  * @vsi: the VSI we care about
  *
-- 
2.5.5
