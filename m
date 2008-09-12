From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 16/29] ixgbe: lro stats were not counted on
	first ethtool -Scall
Date: Thu, 11 Sep 2008 19:59:29 -0700
Message-ID: <20080912025918.6234.56634.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbYILC7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:59:31 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:59:31 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
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

