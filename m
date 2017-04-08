From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] i40e: remove extraneous loop in i40e_vsi_wait_queues_disabled
Date: Sat,  8 Apr 2017 02:55:48 -0700
Message-ID: <20170408095553.78307-8-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26215 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751447AbdDHJ4G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:06 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We can simply check both Tx and Rx queues in a single loop, rather than
repeating the loop twice.

Change-ID: Ic06f26b0e3c2620e0e33c1a2999edda488e647ad
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2111f120865a..0e1240b704ef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4440,7 +4440,7 @@ static void i40e_pf_unquiesce_all_vsi(struct i40e_pf *pf)
  * i40e_vsi_wait_queues_disabled - Wait for VSI's queues to be disabled
  * @vsi: the VSI being configured
  *
- * This function waits for the given VSI's queues to be disabled.
+ * Wait until all queues on a given VSI have been disabled.
  **/
 static int i40e_vsi_wait_queues_disabled(struct i40e_vsi *vsi)
 {
@@ -4449,7 +4449,7 @@ static int i40e_vsi_wait_queues_disabled(struct i40e_vsi *vsi)
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
-		/* Check and wait for the disable status of the queue */
+		/* Check and wait for the Tx queue */
 		ret = i40e_pf_txq_wait(pf, pf_q, false);
 		if (ret) {
 			dev_info(&pf->pdev->dev,
@@ -4457,11 +4457,7 @@ static int i40e_vsi_wait_queues_disabled(struct i40e_vsi *vsi)
 				 vsi->seid, pf_q);
 			return ret;
 		}
-	}
-
-	pf_q = vsi->base_queue;
-	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
-		/* Check and wait for the disable status of the queue */
+		/* Check and wait for the Tx queue */
 		ret = i40e_pf_rxq_wait(pf, pf_q, false);
 		if (ret) {
 			dev_info(&pf->pdev->dev,
-- 
2.12.2
