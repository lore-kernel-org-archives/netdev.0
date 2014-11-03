From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] i40e: avoid disable of interrupt when changing ITR
Date: Mon,  3 Nov 2014 06:56:33 -0800
Message-ID: <1415026599-16232-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44881 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbaKCO4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:55 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The call to irq_dynamic_disable was turning off the interrupt completely
when trying to set ITR to 0 (for lowest moderation).  Just remove the
call as setting the values to 0 later in this function will suffice.

Change-ID: I47caf1ecbe65653cf63ec833db93094cd83fd84d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 12adc08..b6e745f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1574,7 +1574,6 @@ static int i40e_set_coalesce(struct net_device *netdev,
 		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
 	} else if (ec->rx_coalesce_usecs == 0) {
 		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
-		i40e_irq_dynamic_disable(vsi, vector);
 		if (ec->use_adaptive_rx_coalesce)
 			netif_info(pf, drv, netdev,
 				   "Rx-secs=0, need to disable adaptive-Rx for a complete disable\n");
@@ -1589,7 +1588,6 @@ static int i40e_set_coalesce(struct net_device *netdev,
 		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
 	} else if (ec->tx_coalesce_usecs == 0) {
 		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
-		i40e_irq_dynamic_disable(vsi, vector);
 		if (ec->use_adaptive_tx_coalesce)
 			netif_info(pf, drv, netdev,
 				   "Tx-secs=0, need to disable adaptive-Tx for a complete disable\n");
-- 
1.9.3
