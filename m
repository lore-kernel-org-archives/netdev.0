From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: replace reference to CONFIG_FCOE with IXGBE_FCOE
Date: Fri, 19 Aug 2011 06:11:25 -0700
Message-ID: <1313759486-23575-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9896 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab1HSNLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:11:31 -0400
In-Reply-To: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

CONFIG_FCOE is not the correct define to check since it is possible for it
to be CONFIG_FCOE_MODULE, as such the reference to it should be replaced
with IXGBE_FCOE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 0ace6ce..da6d53e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -414,7 +414,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		u8 prio_tc[MAX_TRAFFIC_CLASS] = {0, 1, 2, 3, 4, 5, 6, 7};
 		int max_frame = adapter->netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
-#ifdef CONFIG_FCOE
+#ifdef IXGBE_FCOE
 		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
 			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d9c1625..9a2d2d4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3615,7 +3615,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 
 	/* reconfigure the hardware */
 	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
-#ifdef CONFIG_FCOE
+#ifdef IXGBE_FCOE
 		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
 			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
 #endif
-- 
1.7.6

