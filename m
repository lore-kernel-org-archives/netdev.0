From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40evf: remove needless min_t() on num_online_cpus()*2
Date: Sun, 30 Apr 2017 06:24:47 -0700
Message-ID: <20170430132451.68494-10-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:53521 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163243AbdD3NZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:25:10 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We already set pairs to the value of adapter->num_active_queues. This
value is limited by vsi_res->num_queue_pairs and num_online_cpus(). This
means that pairs by definition is already smaller than
num_online_cpus()*2, so we don't even need to bother with this check.

Lets just remove it and update the comment.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8e6276d864e6..89035ee01679 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1271,13 +1271,13 @@ static int i40evf_set_interrupt_capability(struct i40evf_adapter *adapter)
 	}
 	pairs = adapter->num_active_queues;
 
-	/* It's easy to be greedy for MSI-X vectors, but it really
-	 * doesn't do us much good if we have a lot more vectors
-	 * than CPU's.  So let's be conservative and only ask for
-	 * (roughly) twice the number of vectors as there are CPU's.
+	/* It's easy to be greedy for MSI-X vectors, but it really doesn't do
+	 * us much good if we have more vectors than CPUs. However, we already
+	 * limit the total number of queues by the number of CPUs so we do not
+	 * need any further limiting here.
 	 */
-	v_budget = min_t(int, pairs, (int)(num_online_cpus() * 2)) + NONQ_VECS;
-	v_budget = min_t(int, v_budget, (int)adapter->vf_res->max_vectors);
+	v_budget = min_t(int, pairs + NONQ_VECS,
+			 (int)adapter->vf_res->max_vectors);
 
 	adapter->msix_entries = kcalloc(v_budget,
 					sizeof(struct msix_entry), GFP_KERNEL);
-- 
2.12.2
