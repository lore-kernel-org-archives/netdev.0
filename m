From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e/i40evf: use logical operators, not bitwise
Date: Wed, 17 Feb 2016 19:38:55 -0800
Message-ID: <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:1599 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424883AbcBRDjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:07 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Mr. Spock would certainly raise an eyebrow to see us using bitwise
operators, when we should clearly be relying on logic. Fascinating.

Change-ID: Ie338010c016f93e9faa2002c07c90b15134b7477
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 +++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1abef01..0ffa9a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1996,7 +1996,8 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
 	i40e_for_each_ring(ring, q_vector->tx) {
-		clean_complete &= i40e_clean_tx_irq(ring, vsi->work_limit);
+		clean_complete = clean_complete &&
+				 i40e_clean_tx_irq(ring, vsi->work_limit);
 		arm_wb = arm_wb || ring->arm_wb;
 		ring->arm_wb = false;
 	}
@@ -2020,7 +2021,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 
 		work_done += cleaned;
 		/* if we didn't clean as many as budgeted, we must be done */
-		clean_complete &= (budget_per_ring != cleaned);
+		clean_complete = clean_complete && (budget_per_ring > cleaned);
 	}
 
 	/* If work not completed, return budget and polling will return */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 6f739a7..76bad75 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1432,7 +1432,8 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
 	i40e_for_each_ring(ring, q_vector->tx) {
-		clean_complete &= i40e_clean_tx_irq(ring, vsi->work_limit);
+		clean_complete = clean_complete &&
+				 i40e_clean_tx_irq(ring, vsi->work_limit);
 		arm_wb = arm_wb || ring->arm_wb;
 		ring->arm_wb = false;
 	}
@@ -1456,7 +1457,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 
 		work_done += cleaned;
 		/* if we didn't clean as many as budgeted, we must be done */
-		clean_complete &= (budget_per_ring != cleaned);
+		clean_complete = clean_complete && (budget_per_ring > cleaned);
 	}
 
 	/* If work not completed, return budget and polling will return */
-- 
2.5.0
