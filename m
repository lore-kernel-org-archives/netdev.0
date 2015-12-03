From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40evf: don't use atomic allocation
Date: Thu,  3 Dec 2015 05:25:51 -0800
Message-ID: <1449149160-105219-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3437 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757549AbbLCN0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:04 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

These allocations don't need to be at atomic level. GFP_KERNEL is fine
and they'll reduce stress on the allocator when the system is starved
for memory.

Change-ID: I3561d0399a681de0ad25291b6c848b224c1fde12
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 9b55576..3c9c008 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -242,7 +242,7 @@ void i40evf_configure_queues(struct i40evf_adapter *adapter)
 	adapter->current_op = I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES;
 	len = sizeof(struct i40e_virtchnl_vsi_queue_config_info) +
 		       (sizeof(struct i40e_virtchnl_queue_pair_info) * pairs);
-	vqci = kzalloc(len, GFP_ATOMIC);
+	vqci = kzalloc(len, GFP_KERNEL);
 	if (!vqci)
 		return;
 
@@ -353,7 +353,7 @@ void i40evf_map_queues(struct i40evf_adapter *adapter)
 	len = sizeof(struct i40e_virtchnl_irq_map_info) +
 	      (adapter->num_msix_vectors *
 		sizeof(struct i40e_virtchnl_vector_map));
-	vimi = kzalloc(len, GFP_ATOMIC);
+	vimi = kzalloc(len, GFP_KERNEL);
 	if (!vimi)
 		return;
 
@@ -421,7 +421,7 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 		more = true;
 	}
 
-	veal = kzalloc(len, GFP_ATOMIC);
+	veal = kzalloc(len, GFP_KERNEL);
 	if (!veal)
 		return;
 
@@ -483,7 +483,7 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 		      (count * sizeof(struct i40e_virtchnl_ether_addr));
 		more = true;
 	}
-	veal = kzalloc(len, GFP_ATOMIC);
+	veal = kzalloc(len, GFP_KERNEL);
 	if (!veal)
 		return;
 
@@ -547,7 +547,7 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 		      (count * sizeof(u16));
 		more = true;
 	}
-	vvfl = kzalloc(len, GFP_ATOMIC);
+	vvfl = kzalloc(len, GFP_KERNEL);
 	if (!vvfl)
 		return;
 
@@ -609,7 +609,7 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 		      (count * sizeof(u16));
 		more = true;
 	}
-	vvfl = kzalloc(len, GFP_ATOMIC);
+	vvfl = kzalloc(len, GFP_KERNEL);
 	if (!vvfl)
 		return;
 
-- 
2.5.0
