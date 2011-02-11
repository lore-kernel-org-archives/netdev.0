From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 11/15] ixgbe: DCB, use hardware independent routines
Date: Fri, 11 Feb 2011 09:20:58 -0800
Message-ID: <1297444862-32091-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26609 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757883Ab1BKRVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:25 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This consolidates hardware specifics to ixgbe_dcb.c this simplifies
code that was previously branching based on hardware type.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index c94adec..a977df3 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -405,11 +405,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (adapter->dcb_set_bitmap & BIT_PFC) {
 		u8 pfc_en;
 		ixgbe_dcb_unpack_pfc(&adapter->dcb_cfg, &pfc_en);
-
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-			ixgbe_dcb_config_pfc_82598(&adapter->hw, pfc_en);
-		else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			ixgbe_dcb_config_pfc_82599(&adapter->hw, pfc_en);
+		ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc_en);
 		ret = DCB_HW_CHG;
 	}
 
-- 
1.7.4

