From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbe: Two minor fixes for RSS and FDIR set queues functions
Date: Mon, 19 Mar 2012 14:22:34 -0700
Message-ID: <1332192158-14771-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889Ab2CSVWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:44 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes two minor issues. The first was the fact that we were
setting the return value to false twice in the set_rss_queues function.
The second is the fact that we should have been using "min_t(int," instead
of "min((int)" in set_fdir_queues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6259619..eb58f13 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4332,8 +4332,6 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 		adapter->num_rx_queues = f->indices;
 		adapter->num_tx_queues = f->indices;
 		ret = true;
-	} else {
-		ret = false;
 	}
 
 	return ret;
@@ -4354,7 +4352,7 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
 	bool ret = false;
 	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
 
-	f_fdir->indices = min((int)num_online_cpus(), f_fdir->indices);
+	f_fdir->indices = min_t(int, num_online_cpus(), f_fdir->indices);
 	f_fdir->mask = 0;
 
 	/*
-- 
1.7.7.6
