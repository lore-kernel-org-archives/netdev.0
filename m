From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/3] ixgbe: Fix up some ethtool results when adapter is removed
Date: Wed, 19 Feb 2014 20:45:20 -0800
Message-ID: <1392871521-7731-3-git-send-email-aaron.f.brown@intel.com>
References: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30889 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500AbaBTEsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 23:48:11 -0500
In-Reply-To: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Some ethtool tests returned apparently good results when the
adapter was in a removed state. Fix that by checking for removal.
This also fixes two paths that could return uninitialized memory
in data[4].

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 0433070..f2d35c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -1247,6 +1247,11 @@ static int ixgbe_link_test(struct ixgbe_adapter *adapter, u64 *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	bool link_up;
 	u32 link_speed = 0;
+
+	if (ixgbe_removed(hw->hw_addr)) {
+		*data = 1;
+		return 1;
+	}
 	*data = 0;
 
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, true);
@@ -1969,6 +1974,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		data[1] = 1;
 		data[2] = 1;
 		data[3] = 1;
+		data[4] = 1;
 		eth_test->flags |= ETH_TEST_FL_FAILED;
 		return;
 	}
@@ -1988,6 +1994,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 					data[1] = 1;
 					data[2] = 1;
 					data[3] = 1;
+					data[4] = 1;
 					eth_test->flags |= ETH_TEST_FL_FAILED;
 					clear_bit(__IXGBE_TESTING,
 						  &adapter->state);
-- 
1.8.5.GIT
