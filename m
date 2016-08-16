From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] ixgbe: Re-enable ability to toggle VLAN filtering
Date: Tue, 16 Aug 2016 13:40:13 -0700
Message-ID: <1471380014-134435-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815AbcHPUkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:18 -0400
In-Reply-To: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Back when I submitted the GSO code I messed up and dropped the support for
disabling the VLAN tag filtering via the feature bit.  This patch
re-enables the use of the NETIF_F_HW_VLAN_CTAG_FILTER to enable/disable the
VLAN filtering independent of toggling promiscuous mode.

Fixes: b83e30104b ("ixgbe/ixgbevf: Add support for GSO partial")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e0fdef8..ee57a89 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9523,6 +9523,7 @@ skip_sriov:
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features |
+			       NETIF_F_HW_VLAN_CTAG_FILTER |
 			       NETIF_F_HW_VLAN_CTAG_RX |
 			       NETIF_F_HW_VLAN_CTAG_TX |
 			       NETIF_F_RXALL |
-- 
2.7.4
