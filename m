From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] ixgbe: Drop RLPML configuration from x540 RXDCTL register configuration
Date: Wed, 28 Nov 2012 05:06:15 -0800
Message-ID: <1354107978-24731-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab2K1NGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:24 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since we are doing a page based receive there is no point in setting a maximum
packet length on the x540 RXDCTL register.  As such we can drop the code from
the driver entirely.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 80e3cb7..e6e1245 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3170,14 +3170,6 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	ixgbe_configure_srrctl(adapter, ring);
 	ixgbe_configure_rscctl(adapter, ring);
 
-	/* If operating in IOV mode set RLPML for X540 */
-	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
-	    hw->mac.type == ixgbe_mac_X540) {
-		rxdctl &= ~IXGBE_RXDCTL_RLPMLMASK;
-		rxdctl |= ((ring->netdev->mtu + ETH_HLEN +
-			    ETH_FCS_LEN + VLAN_HLEN) | IXGBE_RXDCTL_RLPML_EN);
-	}
-
 	if (hw->mac.type == ixgbe_mac_82598EB) {
 		/*
 		 * enable cache line friendly hardware writes:
-- 
1.7.11.7
