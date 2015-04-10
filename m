From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER from hw_features
Date: Fri, 10 Apr 2015 00:53:17 -0700
Message-ID: <1428652398-10147-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:33743 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbbDJHxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:22 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change makes it so that the HW_VLAN_CTAG_FILTER bit is not falsely
advertised as being a feature that can be toggled on ixgbe parts.  The
driver was setting the bit in features and letting it be inherited by
hw_features, however the driver was actually ignoring the value of the bit
and just assuming it was always set.  As a result VLAN filtering was always
enabled which is a requirement for SR-IOV, VMDq, DCB, FCoE, and possibly
other features within the adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c696ad72..0b38be8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8455,7 +8455,6 @@ skip_sriov:
 			   NETIF_F_IPV6_CSUM |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
-			   NETIF_F_HW_VLAN_CTAG_FILTER |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
@@ -8477,6 +8476,7 @@ skip_sriov:
 	}
 
 	netdev->hw_features |= NETIF_F_RXALL;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
-- 
1.9.3
