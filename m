From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: make i40evf_map_rings_to_vectors void
Date: Mon,  2 Oct 2017 12:48:49 -0700
Message-ID: <20171002194852.71970-13-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:36724 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751638AbdJBTtV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:21 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This function cannot fail, so why is it returning a value? And why are
we checking it? Why shouldn't we just make it void? Why is this commit
message made up of only questions?

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8c513ce84345..f2f1e754c2ce 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -430,12 +430,11 @@ i40evf_map_vector_to_txq(struct i40evf_adapter *adapter, int v_idx, int t_idx)
  * group the rings as "efficiently" as possible.  You would add new
  * mapping configurations in here.
  **/
-static int i40evf_map_rings_to_vectors(struct i40evf_adapter *adapter)
+static void i40evf_map_rings_to_vectors(struct i40evf_adapter *adapter)
 {
 	int rings_remaining = adapter->num_active_queues;
 	int ridx = 0, vidx = 0;
 	int q_vectors;
-	int err = 0;
 
 	q_vectors = adapter->num_msix_vectors - NONQ_VECS;
 
@@ -451,8 +450,6 @@ static int i40evf_map_rings_to_vectors(struct i40evf_adapter *adapter)
 	}
 
 	adapter->aq_required |= I40EVF_FLAG_AQ_MAP_VECTORS;
-
-	return err;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1578,9 +1575,7 @@ static int i40evf_reinit_interrupt_scheme(struct i40evf_adapter *adapter)
 
 	set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 
-	err = i40evf_map_rings_to_vectors(adapter);
-	if (err)
-		goto err;
+	i40evf_map_rings_to_vectors(adapter);
 
 	if (RSS_AQ(adapter))
 		adapter->aq_required |= I40EVF_FLAG_AQ_CONFIGURE_RSS;
-- 
2.14.2
