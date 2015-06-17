From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/17] fm10k: remove extraneous NULL check on l2_accel
Date: Wed, 17 Jun 2015 05:54:55 -0700
Message-ID: <1434545704-112470-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756403AbbFQMzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:09 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

l2_accel was checked for NULL at the top of fm10k_dfwd_del_station, and
we return if it is not defined. Due to this, we already know it can't be
null here so a separate check is meaningless. Discovered via cppcheck.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 4c6b511..99228bf 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1333,8 +1333,7 @@ static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
 	dglort.rss_l = fls(interface->ring_feature[RING_F_RSS].mask);
 	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
 	dglort.glort = interface->glort;
-	if (l2_accel)
-		dglort.shared_l = fls(l2_accel->size);
+	dglort.shared_l = fls(l2_accel->size);
 	hw->mac.ops.configure_dglort_map(hw, &dglort);
 
 	/* If table is empty remove it */
-- 
2.4.3
