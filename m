From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/15] i40evf: remove redundant code
Date: Tue, 13 Jan 2015 11:58:00 -0800
Message-ID: <1421179093-10932-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52238 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724AbbAMT6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:16 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

These functions are redundant and duplicate functionality found in
i40evf_free_all_[tx|rx]_resources.

Change-ID: Ia199908926d7a1a4b8247f75f89b5da24c9b149c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 27 -------------------------
 1 file changed, 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index cabaf59..ee0db59 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -947,30 +947,6 @@ static int i40evf_up_complete(struct i40evf_adapter *adapter)
 }
 
 /**
- * i40evf_clean_all_rx_rings - Free Rx Buffers for all queues
- * @adapter: board private structure
- **/
-static void i40evf_clean_all_rx_rings(struct i40evf_adapter *adapter)
-{
-	int i;
-
-	for (i = 0; i < adapter->num_active_queues; i++)
-		i40evf_clean_rx_ring(adapter->rx_rings[i]);
-}
-
-/**
- * i40evf_clean_all_tx_rings - Free Tx Buffers for all queues
- * @adapter: board private structure
- **/
-static void i40evf_clean_all_tx_rings(struct i40evf_adapter *adapter)
-{
-	int i;
-
-	for (i = 0; i < adapter->num_active_queues; i++)
-		i40evf_clean_tx_ring(adapter->tx_rings[i]);
-}
-
-/**
  * i40e_down - Shutdown the connection processing
  * @adapter: board private structure
  **/
@@ -1008,9 +984,6 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	i40evf_napi_disable_all(adapter);
 
 	netif_carrier_off(netdev);
-
-	i40evf_clean_all_tx_rings(adapter);
-	i40evf_clean_all_rx_rings(adapter);
 }
 
 /**
-- 
1.9.3
