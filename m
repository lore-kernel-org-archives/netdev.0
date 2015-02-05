From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] ixgbevf: set vlan_features in a single write instead of several ORs
Date: Thu,  5 Feb 2015 01:35:45 -0800
Message-ID: <1423128950-12388-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55122 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756838AbbBEJgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:07 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Clean up the setting of vlan_features by enabling all features at once.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 41fca1b..b1d25fd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3873,11 +3873,11 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_IP_CSUM;
-	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
-	netdev->vlan_features |= NETIF_F_SG;
+	netdev->vlan_features |= NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_IP_CSUM |
+				 NETIF_F_IPV6_CSUM |
+				 NETIF_F_SG;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
-- 
1.9.3
