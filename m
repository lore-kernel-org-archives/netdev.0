From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] i40e/i40evf: Fix use after free in Rx cleanup path
Date: Sat, 25 Mar 2017 01:12:57 -0700
Message-ID: <20170325081305.31835-4-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:32490 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdCYINJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:09 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We need to reset skb back to NULL when we have freed it in the Rx cleanup
path.  I found one spot where this wasn't occurring so this patch fixes it.

Change-ID: Iaca68934200732cd4a63eb0bd83b539c95f8c4dd
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e5c89770cbc2..9f2c9f1b8e06 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1941,6 +1941,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		 */
 		if (unlikely(i40e_test_staterr(rx_desc, BIT(I40E_RXD_QW1_ERROR_SHIFT)))) {
 			dev_kfree_skb_any(skb);
+			skb = NULL;
 			continue;
 		}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d892922a2ed9..38f93075f496 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1299,6 +1299,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		 */
 		if (unlikely(i40e_test_staterr(rx_desc, BIT(I40E_RXD_QW1_ERROR_SHIFT)))) {
 			dev_kfree_skb_any(skb);
+			skb = NULL;
 			continue;
 		}
 
-- 
2.12.0
