From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/12] i40e: Tell the stack about our actual number of queues
Date: Mon, 16 Dec 2013 01:38:49 -0800
Message-ID: <1387186738-13666-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10462 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569Ab3LPJjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:07 -0500
In-Reply-To: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Call the netif_set_real* functions in order to make sure
the stack knows about how many queues we have, in order
for RFS/RPS/XFS to work correctly.

Change-Id: Ib7a7b2792f80c5eef210dedf42cc6607d63953d2
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a6291e2..9dc5829 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3966,6 +3966,15 @@ static int i40e_open(struct net_device *netdev)
 	if (err)
 		goto err_setup_rx;
 
+	/* Notify the stack of the actual queue counts. */
+	err = netif_set_real_num_tx_queues(netdev, pf->num_tx_queues);
+	if (err)
+		goto err_set_queues;
+
+	err = netif_set_real_num_rx_queues(netdev, pf->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
 	err = i40e_up_complete(vsi);
 	if (err)
 		goto err_up_complete;
@@ -3982,6 +3991,7 @@ static int i40e_open(struct net_device *netdev)
 
 err_up_complete:
 	i40e_down(vsi);
+err_set_queues:
 	i40e_vsi_free_irq(vsi);
 err_setup_rx:
 	i40e_vsi_free_rx_resources(vsi);
-- 
1.8.3.1
