From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] ixgbe: disable LRO by default
Date: Thu, 15 Oct 2015 02:39:48 -0700
Message-ID: <1444902004-14433-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbbJOJm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:26 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch disables LRO by default in favor of GRO.

LRO is incompatible with forwarding and is disabled when forwarding
is turned on which makes the default offloads of the driver
inconsistent. LRO can still be enabled via ethtool.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4608f8..1b2ad39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5307,7 +5307,6 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	rss = min_t(int, ixgbe_max_rss_indices(adapter), num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].limit = rss;
 	adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
-	adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 	adapter->max_q_vectors = MAX_Q_VECTORS_82599;
 	adapter->atr_sample_rate = 20;
 	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, num_online_cpus());
@@ -5333,7 +5332,6 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		adapter->flags2 &= ~IXGBE_FLAG2_RSC_CAPABLE;
-		adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
 
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
 			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
-- 
2.4.3
