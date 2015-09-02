From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/19] ixgbe: fix bounds checking in ixgbe_setup_tc for 82598
Date: Tue,  1 Sep 2015 18:14:00 -0700
Message-ID: <1441156443-33381-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37040 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619AbbIBBON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:13 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves an issue where users were not able to dynamically
set number of queues for 82598 via ethtool -L

Reported-by: Tal Abudi <talabudi@gmail.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index afdc7fb..0853cf0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7848,9 +7848,10 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	bool pools;
 
 	/* Hardware supports up to 8 traffic classes */
-	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs ||
-	    (hw->mac.type == ixgbe_mac_82598EB &&
-	     tc < MAX_TRAFFIC_CLASS))
+	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs)
+		return -EINVAL;
+
+	if (hw->mac.type == ixgbe_mac_82598EB && tc && tc < MAX_TRAFFIC_CLASS)
 		return -EINVAL;
 
 	pools = (find_first_zero_bit(&adapter->fwd_bitmask, 32) > 1);
-- 
2.4.3
