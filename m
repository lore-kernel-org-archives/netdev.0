From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 16/24] ixgbe: lro stats were not counted on first
	ethtool -Scall
Date: Mon, 08 Sep 2008 21:48:15 -0700
Message-ID: <20080909044815.18904.34125.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:34551 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbYIIEsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:18 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1027470yxm.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:16 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 928b97c..4701abf 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -774,6 +774,14 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	int j, k;
 	int i;
 	u64 aggregated = 0, flushed = 0, no_desc = 0;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
+		flushed += adapter->rx_ring[i].lro_mgr.stats.flushed;
+		no_desc += adapter->rx_ring[i].lro_mgr.stats.no_desc;
+	}
+	adapter->lro_aggregated = aggregated;
+	adapter->lro_flushed = flushed;
+	adapter->lro_no_desc = no_desc;
 
 	ixgbe_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
@@ -788,17 +796,11 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		i += k;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		aggregated += adapter->rx_ring[j].lro_mgr.stats.aggregated;
-		flushed += adapter->rx_ring[j].lro_mgr.stats.flushed;
-		no_desc += adapter->rx_ring[j].lro_mgr.stats.no_desc;
 		queue_stat = (u64 *)&adapter->rx_ring[j].stats;
 		for (k = 0; k < stat_count; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
-	adapter->lro_aggregated = aggregated;
-	adapter->lro_flushed = flushed;
-	adapter->lro_no_desc = no_desc;
 }
 
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,

