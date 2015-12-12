From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] i40evf: check rings before freeing resources
Date: Sat, 12 Dec 2015 00:33:26 -0800
Message-ID: <1449909213-33795-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52824 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbbLLIdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:41 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the driver gets unloaded during reset recovery, it's possible
that it will attempt to free resources when they're already free.

Add a check to make sure that the Tx and Rx rings actually exist
before dereferencing them to free resources.

Change-ID: I4d2b7e9ede49f634d421a4c5deaa5446bc755eee
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b4c632f..98091b4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2034,6 +2034,9 @@ void i40evf_free_all_tx_resources(struct i40evf_adapter *adapter)
 {
 	int i;
 
+	if (!adapter->tx_rings)
+		return;
+
 	for (i = 0; i < adapter->num_active_queues; i++)
 		if (adapter->tx_rings[i].desc)
 			i40evf_free_tx_resources(&adapter->tx_rings[i]);
@@ -2102,6 +2105,9 @@ void i40evf_free_all_rx_resources(struct i40evf_adapter *adapter)
 {
 	int i;
 
+	if (!adapter->rx_rings)
+		return;
+
 	for (i = 0; i < adapter->num_active_queues; i++)
 		if (adapter->rx_rings[i].desc)
 			i40evf_free_rx_resources(&adapter->rx_rings[i]);
-- 
2.5.0
