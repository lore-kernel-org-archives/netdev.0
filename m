From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] e1000e: Remove special case for 82573/82574 ASPM L1 disablement
Date: Thu,  3 May 2012 02:56:29 -0700
Message-ID: <1336038992-3144-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Chris Boot <bootc@bootc.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab2ECJ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:36 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Boot <bootc@bootc.net>

For the 82573, ASPM L1 gets disabled wholesale so this special-case code
is not required. For the 82574 the previous patch does the same as for
the 82573, disabling L1 on the adapter. Thus, this code is no longer
required and can be removed.

Signed-off-by: Chris Boot <bootc@bootc.net>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ab4505c..9c4576e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5272,14 +5272,6 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
-	/* 82573 Errata 17 */
-	if (((adapter->hw.mac.type == e1000_82573) ||
-	     (adapter->hw.mac.type == e1000_82574)) &&
-	    (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN)) {
-		adapter->flags2 |= FLAG2_DISABLE_ASPM_L1;
-		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L1);
-	}
-
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
-- 
1.7.7.6
