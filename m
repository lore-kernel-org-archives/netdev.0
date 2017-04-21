From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 2/2] igb: Remove useless argument
Date: Fri, 21 Apr 2017 14:20:12 -0700
Message-ID: <20170421212012.25950-2-bpoirier@suse.com>
References: <20170421212012.25950-1-bpoirier@suse.com>
Cc: Stefan Priebe <s.priebe@profihost.ag>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34436 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161738AbdDUVUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 17:20:40 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so34537711ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 14:20:40 -0700 (PDT)
In-Reply-To: <20170421212012.25950-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given that all callers of igb_update_stats() pass the same two arguments:
(adapter, &adapter->stats64), the second argument can be removed.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c    | 10 +++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index acbc3abe2ddd..3f0c06847fc2 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -593,7 +593,7 @@ void igb_setup_rctl(struct igb_adapter *);
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *, struct igb_ring *);
 void igb_unmap_and_free_tx_resource(struct igb_ring *, struct igb_tx_buffer *);
 void igb_alloc_rx_buffers(struct igb_ring *, u16);
-void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
+void igb_update_stats(struct igb_adapter *);
 bool igb_has_link(struct igb_adapter *adapter);
 void igb_set_ethtool_ops(struct net_device *);
 void igb_power_up_link(struct igb_adapter *);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 737b664d004c..8c913958c2eb 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2287,7 +2287,7 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	char *p;
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, net_stats);
+	igb_update_stats(adapter);
 
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		p = (char *)adapter + igb_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index be456bae8169..20da5e9d9d3c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1815,7 +1815,7 @@ void igb_down(struct igb_adapter *adapter)
 
 	/* record the stats before reset*/
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
 
 	adapter->link_speed = 0;
@@ -4628,7 +4628,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	}
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -5410,7 +5410,7 @@ static void igb_get_stats64(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	memcpy(stats, &adapter->stats64, sizeof(*stats));
 	spin_unlock(&adapter->stats64_lock);
 }
@@ -5459,9 +5459,9 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
  *  igb_update_stats - Update the board statistics counters
  *  @adapter: board private structure
  **/
-void igb_update_stats(struct igb_adapter *adapter,
-		      struct rtnl_link_stats64 *net_stats)
+void igb_update_stats(struct igb_adapter *adapter)
 {
+	struct rtnl_link_stats64 *net_stats = &adapter->stats64;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 reg, mpc;
-- 
2.12.2
