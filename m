From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] ixgb: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:16:59 +0530
Message-ID: <20091007124648.GA30172@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:55356 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932914AbZJGMrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:47:46 -0400
Received: by fxm27 with SMTP id 27so4554277fxm.17
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:47:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the private adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/ixgb/ixgb.h         |    1 -
 drivers/net/ixgb/ixgb_ethtool.c |   44 ++++++++++++++++++++------------------
 drivers/net/ixgb/ixgb_main.c    |   44 ++++++++++++++++++--------------------
 3 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index d85717e..e95d9b6 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -183,7 +183,6 @@ struct ixgb_adapter {
 	struct napi_struct napi;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	/* structs defined in ixgb_hw.h */
 	struct ixgb_hw hw;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 288ee1d..deeb25d 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -42,30 +42,32 @@ struct ixgb_stats {
 
 #define IXGB_STAT(m) FIELD_SIZEOF(struct ixgb_adapter, m), \
 		      offsetof(struct ixgb_adapter, m)
+#define IXGB_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
+		      offsetof(struct net_device, m)
 static struct ixgb_stats ixgb_gstrings_stats[] = {
-	{"rx_packets", IXGB_STAT(net_stats.rx_packets)},
-	{"tx_packets", IXGB_STAT(net_stats.tx_packets)},
-	{"rx_bytes", IXGB_STAT(net_stats.rx_bytes)},
-	{"tx_bytes", IXGB_STAT(net_stats.tx_bytes)},
-	{"rx_errors", IXGB_STAT(net_stats.rx_errors)},
-	{"tx_errors", IXGB_STAT(net_stats.tx_errors)},
-	{"rx_dropped", IXGB_STAT(net_stats.rx_dropped)},
-	{"tx_dropped", IXGB_STAT(net_stats.tx_dropped)},
-	{"multicast", IXGB_STAT(net_stats.multicast)},
-	{"collisions", IXGB_STAT(net_stats.collisions)},
-
-/*	{ "rx_length_errors", IXGB_STAT(net_stats.rx_length_errors) },	*/
-	{"rx_over_errors", IXGB_STAT(net_stats.rx_over_errors)},
-	{"rx_crc_errors", IXGB_STAT(net_stats.rx_crc_errors)},
-	{"rx_frame_errors", IXGB_STAT(net_stats.rx_frame_errors)},
+	{"rx_packets", IXGB_NETDEV_STAT(stats.rx_packets)},
+	{"tx_packets", IXGB_NETDEV_STAT(stats.tx_packets)},
+	{"rx_bytes", IXGB_NETDEV_STAT(stats.rx_bytes)},
+	{"tx_bytes", IXGB_NETDEV_STAT(stats.tx_bytes)},
+	{"rx_errors", IXGB_NETDEV_STAT(stats.rx_errors)},
+	{"tx_errors", IXGB_NETDEV_STAT(stats.tx_errors)},
+	{"rx_dropped", IXGB_NETDEV_STAT(stats.rx_dropped)},
+	{"tx_dropped", IXGB_NETDEV_STAT(stats.tx_dropped)},
+	{"multicast", IXGB_NETDEV_STAT(stats.multicast)},
+	{"collisions", IXGB_NETDEV_STAT(stats.collisions)},
+
+/*	{ "rx_length_errors", IXGB_NETDEV_STAT(stats.rx_length_errors) },	*/
+	{"rx_over_errors", IXGB_NETDEV_STAT(stats.rx_over_errors)},
+	{"rx_crc_errors", IXGB_NETDEV_STAT(stats.rx_crc_errors)},
+	{"rx_frame_errors", IXGB_NETDEV_STAT(stats.rx_frame_errors)},
 	{"rx_no_buffer_count", IXGB_STAT(stats.rnbc)},
-	{"rx_fifo_errors", IXGB_STAT(net_stats.rx_fifo_errors)},
-	{"rx_missed_errors", IXGB_STAT(net_stats.rx_missed_errors)},
-	{"tx_aborted_errors", IXGB_STAT(net_stats.tx_aborted_errors)},
-	{"tx_carrier_errors", IXGB_STAT(net_stats.tx_carrier_errors)},
-	{"tx_fifo_errors", IXGB_STAT(net_stats.tx_fifo_errors)},
-	{"tx_heartbeat_errors", IXGB_STAT(net_stats.tx_heartbeat_errors)},
-	{"tx_window_errors", IXGB_STAT(net_stats.tx_window_errors)},
+	{"rx_fifo_errors", IXGB_NETDEV_STAT(stats.rx_fifo_errors)},
+	{"rx_missed_errors", IXGB_NETDEV_STAT(stats.rx_missed_errors)},
+	{"tx_aborted_errors", IXGB_NETDEV_STAT(stats.tx_aborted_errors)},
+	{"tx_carrier_errors", IXGB_NETDEV_STAT(stats.tx_carrier_errors)},
+	{"tx_fifo_errors", IXGB_NETDEV_STAT(stats.tx_fifo_errors)},
+	{"tx_heartbeat_errors", IXGB_NETDEV_STAT(stats.tx_heartbeat_errors)},
+	{"tx_window_errors", IXGB_NETDEV_STAT(stats.tx_window_errors)},
 	{"tx_deferred_ok", IXGB_STAT(stats.dc)},
 	{"tx_timeout_count", IXGB_STAT(tx_timeout_count) },
 	{"tx_restart_queue", IXGB_STAT(restart_queue) },
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 8aa44dc..f9f633c 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1537,9 +1537,7 @@ ixgb_tx_timeout_task(struct work_struct *work)
 static struct net_device_stats *
 ixgb_get_stats(struct net_device *netdev)
 {
-	struct ixgb_adapter *adapter = netdev_priv(netdev);
-
-	return &adapter->net_stats;
+	return &netdev->stats;
 }
 
 /**
@@ -1676,16 +1674,16 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 
 	/* Fill out the OS statistics structure */
 
-	adapter->net_stats.rx_packets = adapter->stats.gprcl;
-	adapter->net_stats.tx_packets = adapter->stats.gptcl;
-	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
-	adapter->net_stats.tx_bytes = adapter->stats.gotcl;
-	adapter->net_stats.multicast = adapter->stats.mprcl;
-	adapter->net_stats.collisions = 0;
+	netdev->stats.rx_packets = adapter->stats.gprcl;
+	netdev->stats.tx_packets = adapter->stats.gptcl;
+	netdev->stats.rx_bytes = adapter->stats.gorcl;
+	netdev->stats.tx_bytes = adapter->stats.gotcl;
+	netdev->stats.multicast = adapter->stats.mprcl;
+	netdev->stats.collisions = 0;
 
 	/* ignore RLEC as it reports errors for padded (<64bytes) frames
 	 * with a length in the type/len field */
-	adapter->net_stats.rx_errors =
+	netdev->stats.rx_errors =
 	    /* adapter->stats.rnbc + */ adapter->stats.crcerrs +
 	    adapter->stats.ruc +
 	    adapter->stats.roc /*+ adapter->stats.rlec */  +
@@ -1693,21 +1691,21 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 	    adapter->stats.ecbc + adapter->stats.mpc;
 
 	/* see above
-	 * adapter->net_stats.rx_length_errors = adapter->stats.rlec;
+	 * netdev->stats.rx_length_errors = adapter->stats.rlec;
 	 */
 
-	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_fifo_errors = adapter->stats.mpc;
-	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
-	adapter->net_stats.rx_over_errors = adapter->stats.mpc;
-
-	adapter->net_stats.tx_errors = 0;
-	adapter->net_stats.rx_frame_errors = 0;
-	adapter->net_stats.tx_aborted_errors = 0;
-	adapter->net_stats.tx_carrier_errors = 0;
-	adapter->net_stats.tx_fifo_errors = 0;
-	adapter->net_stats.tx_heartbeat_errors = 0;
-	adapter->net_stats.tx_window_errors = 0;
+	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
+	netdev->stats.rx_fifo_errors = adapter->stats.mpc;
+	netdev->stats.rx_missed_errors = adapter->stats.mpc;
+	netdev->stats.rx_over_errors = adapter->stats.mpc;
+
+	netdev->stats.tx_errors = 0;
+	netdev->stats.rx_frame_errors = 0;
+	netdev->stats.tx_aborted_errors = 0;
+	netdev->stats.tx_carrier_errors = 0;
+	netdev->stats.tx_fifo_errors = 0;
+	netdev->stats.tx_heartbeat_errors = 0;
+	netdev->stats.tx_window_errors = 0;
 }
 
 #define IXGB_MAX_INTR 10
-- 
1.6.0.4

