From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40evf: Enable the ndo_set_features netdev op
Date: Wed,  5 Mar 2014 20:21:33 -0800
Message-ID: <1394079704-1108-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51291 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840AbaCFEVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:48 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Set netdev->hw_features to enable the ndo_set_features netdev op.

Change-Id: I5a086fbfa5a089de5adba2800c4d0b3a73747b11
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b2c03bc..3d3ab14 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2036,6 +2036,7 @@ static void i40evf_init_task(struct work_struct *work)
 			    NETIF_F_IPV6_CSUM |
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
+			    NETIF_F_RXCSUM |
 			    NETIF_F_GRO;
 
 	if (adapter->vf_res->vf_offload_flags
@@ -2046,6 +2047,10 @@ static void i40evf_init_task(struct work_struct *work)
 				    NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
+	/* copy netdev features into list of user selectable features */
+	netdev->hw_features |= netdev->features;
+	netdev->hw_features &= ~NETIF_F_RXCSUM;
+
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
 		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using random\n",
 			 adapter->hw.mac.addr);
-- 
1.8.3.1
