From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] igb: Remove useless argument
Date: Tue,  6 Jun 2017 01:58:07 -0700
Message-ID: <20170606085809.78571-10-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30962 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751431AbdFFI6R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:17 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

Given that all callers of igb_update_stats() pass the same two arguments:
(adapter, &adapter->stats64), the second argument can be removed.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c    | 10 +++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index ff4d9073781a..06ffb2bc713e 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -667,7 +667,7 @@ void igb_setup_tctl(struct igb_adapter *);
 void igb_setup_rctl(struct igb_adapter *);
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *, struct igb_ring *);
 void igb_alloc_rx_buffers(struct igb_ring *, u16);
-void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
+void igb_update_stats(struct igb_adapter *);
 bool igb_has_link(struct igb_adapter *adapter);
 void igb_set_ethtool_ops(struct net_device *);
 void igb_power_up_link(struct igb_adapter *);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 8730f7cbce68..d06a8db514d4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2316,7 +2316,7 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	char *p;
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, net_stats);
+	igb_update_stats(adapter);
 
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		p = (char *)adapter + igb_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0a333509d5d5..7e433344a13c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1818,7 +1818,7 @@ void igb_down(struct igb_adapter *adapter)
 
 	/* record the stats before reset*/
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
 
 	adapter->link_speed = 0;
@@ -4686,7 +4686,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	}
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -5499,7 +5499,7 @@ static void igb_get_stats64(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
 	spin_lock(&adapter->stats64_lock);
-	igb_update_stats(adapter, &adapter->stats64);
+	igb_update_stats(adapter);
 	memcpy(stats, &adapter->stats64, sizeof(*stats));
 	spin_unlock(&adapter->stats64_lock);
 }
@@ -5548,9 +5548,9 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
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
