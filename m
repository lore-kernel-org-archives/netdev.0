From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e/i40evf: fix poll weight
Date: Sun,  8 Jun 2014 07:33:55 -0700
Message-ID: <1402238037-20661-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64930 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbaFHOeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:08 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Fix a coding error where during the registration for NAPI
the driver requested 256 budget.  The max recommended
value for this is NAPI_POLL_WEIGHT or 64.

Change-ID: I03ea1e2934a84ff1b5d572988b18315d6d91c5c6
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 566eec1..254bb68 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6255,7 +6255,7 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
 	cpumask_set_cpu(v_idx, &q_vector->affinity_mask);
 	if (vsi->netdev)
 		netif_napi_add(vsi->netdev, &q_vector->napi,
-			       i40e_napi_poll, vsi->work_limit);
+			       i40e_napi_poll, NAPI_POLL_WEIGHT);
 
 	q_vector->rx.latency_range = I40E_LOW_LATENCY;
 	q_vector->tx.latency_range = I40E_LOW_LATENCY;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e32b8c5..edb3b49 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1169,7 +1169,7 @@ static int i40evf_alloc_q_vectors(struct i40evf_adapter *adapter)
 		q_vector->vsi = &adapter->vsi;
 		q_vector->v_idx = q_idx;
 		netif_napi_add(adapter->netdev, &q_vector->napi,
-				       i40evf_napi_poll, 64);
+				       i40evf_napi_poll, NAPI_POLL_WEIGHT);
 		adapter->q_vector[q_idx] = q_vector;
 	}
 
-- 
1.9.3
