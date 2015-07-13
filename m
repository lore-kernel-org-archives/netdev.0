From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40evf: Allow for an abundance of vectors
Date: Mon, 13 Jul 2015 02:08:26 -0700
Message-ID: <1436778517-16254-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40574 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbbGMJIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:08:46 -0400
In-Reply-To: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The driver currently only maps TX and RX queues to a single MSI-X vector
per queue pair if there are exactly enough vectors for this.
Unfortunately, if we have too many vectors it will fail and allocate
queues to vectors in a suboptimal manner. Change the condition check to
allow for excess vectors. In this case, the extras just won't be used.

Change-ID: I23e1e2955c64739c86612db88a25583e6a7e0b17
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4ab4ebb..94eff4a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -406,7 +406,7 @@ static int i40evf_map_rings_to_vectors(struct i40evf_adapter *adapter)
 	/* The ideal configuration...
 	 * We have enough vectors to map one per queue.
 	 */
-	if (q_vectors == (rxr_remaining * 2)) {
+	if (q_vectors >= (rxr_remaining * 2)) {
 		for (; rxr_idx < rxr_remaining; v_start++, rxr_idx++)
 			i40evf_map_vector_to_rxq(adapter, v_start, rxr_idx);
 
-- 
2.4.3
