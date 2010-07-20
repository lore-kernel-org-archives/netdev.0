From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ixgbe: fix ethtool stats
Date: Tue, 20 Jul 2010 19:28:26 +0200
Message-ID: <1279646906.2498.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42873 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab0GTR2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 13:28:34 -0400
Received: by wwj40 with SMTP id 40so1119332wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 10:28:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note : I am currently unable to test following patch, could you please
Intel guys test it and Ack (or Nack) it ?

Thanks !

[PATCH net-next-2.6] ixgbe: fix ethtool stats

In latest changes about 64bit stats on 32bit arches,
[commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit arches)],
I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
definition.

IXGBE_NETDEV_STAT() must now assume offsets relative to
rtnl_link_stats64, not relative do dev->stats.

As a bonus, we also get 64bit stats on ethtool -S

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   42 ++++++++++++++--------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index da54b38..dcebc82 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -54,14 +54,14 @@ struct ixgbe_stats {
 				sizeof(((struct ixgbe_adapter *)0)->m), \
 				offsetof(struct ixgbe_adapter, m)
 #define IXGBE_NETDEV_STAT(m)	NETDEV_STATS, \
-				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m) - offsetof(struct net_device, stats)
+				sizeof(((struct rtnl_link_stats64 *)0)->m), \
+				offsetof(struct rtnl_link_stats64, m)
 
 static struct ixgbe_stats ixgbe_gstrings_stats[] = {
-	{"rx_packets", IXGBE_NETDEV_STAT(stats.rx_packets)},
-	{"tx_packets", IXGBE_NETDEV_STAT(stats.tx_packets)},
-	{"rx_bytes", IXGBE_NETDEV_STAT(stats.rx_bytes)},
-	{"tx_bytes", IXGBE_NETDEV_STAT(stats.tx_bytes)},
+	{"rx_packets", IXGBE_NETDEV_STAT(rx_packets)},
+	{"tx_packets", IXGBE_NETDEV_STAT(tx_packets)},
+	{"rx_bytes", IXGBE_NETDEV_STAT(rx_bytes)},
+	{"tx_bytes", IXGBE_NETDEV_STAT(tx_bytes)},
 	{"rx_pkts_nic", IXGBE_STAT(stats.gprc)},
 	{"tx_pkts_nic", IXGBE_STAT(stats.gptc)},
 	{"rx_bytes_nic", IXGBE_STAT(stats.gorc)},
@@ -69,27 +69,27 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"lsc_int", IXGBE_STAT(lsc_int)},
 	{"tx_busy", IXGBE_STAT(tx_busy)},
 	{"non_eop_descs", IXGBE_STAT(non_eop_descs)},
-	{"rx_errors", IXGBE_NETDEV_STAT(stats.rx_errors)},
-	{"tx_errors", IXGBE_NETDEV_STAT(stats.tx_errors)},
-	{"rx_dropped", IXGBE_NETDEV_STAT(stats.rx_dropped)},
-	{"tx_dropped", IXGBE_NETDEV_STAT(stats.tx_dropped)},
-	{"multicast", IXGBE_NETDEV_STAT(stats.multicast)},
+	{"rx_errors", IXGBE_NETDEV_STAT(rx_errors)},
+	{"tx_errors", IXGBE_NETDEV_STAT(tx_errors)},
+	{"rx_dropped", IXGBE_NETDEV_STAT(rx_dropped)},
+	{"tx_dropped", IXGBE_NETDEV_STAT(tx_dropped)},
+	{"multicast", IXGBE_NETDEV_STAT(multicast)},
 	{"broadcast", IXGBE_STAT(stats.bprc)},
 	{"rx_no_buffer_count", IXGBE_STAT(stats.rnbc[0]) },
-	{"collisions", IXGBE_NETDEV_STAT(stats.collisions)},
-	{"rx_over_errors", IXGBE_NETDEV_STAT(stats.rx_over_errors)},
-	{"rx_crc_errors", IXGBE_NETDEV_STAT(stats.rx_crc_errors)},
-	{"rx_frame_errors", IXGBE_NETDEV_STAT(stats.rx_frame_errors)},
+	{"collisions", IXGBE_NETDEV_STAT(collisions)},
+	{"rx_over_errors", IXGBE_NETDEV_STAT(rx_over_errors)},
+	{"rx_crc_errors", IXGBE_NETDEV_STAT(rx_crc_errors)},
+	{"rx_frame_errors", IXGBE_NETDEV_STAT(rx_frame_errors)},
 	{"hw_rsc_aggregated", IXGBE_STAT(rsc_total_count)},
 	{"hw_rsc_flushed", IXGBE_STAT(rsc_total_flush)},
 	{"fdir_match", IXGBE_STAT(stats.fdirmatch)},
 	{"fdir_miss", IXGBE_STAT(stats.fdirmiss)},
-	{"rx_fifo_errors", IXGBE_NETDEV_STAT(stats.rx_fifo_errors)},
-	{"rx_missed_errors", IXGBE_NETDEV_STAT(stats.rx_missed_errors)},
-	{"tx_aborted_errors", IXGBE_NETDEV_STAT(stats.tx_aborted_errors)},
-	{"tx_carrier_errors", IXGBE_NETDEV_STAT(stats.tx_carrier_errors)},
-	{"tx_fifo_errors", IXGBE_NETDEV_STAT(stats.tx_fifo_errors)},
-	{"tx_heartbeat_errors", IXGBE_NETDEV_STAT(stats.tx_heartbeat_errors)},
+	{"rx_fifo_errors", IXGBE_NETDEV_STAT(rx_fifo_errors)},
+	{"rx_missed_errors", IXGBE_NETDEV_STAT(rx_missed_errors)},
+	{"tx_aborted_errors", IXGBE_NETDEV_STAT(tx_aborted_errors)},
+	{"tx_carrier_errors", IXGBE_NETDEV_STAT(tx_carrier_errors)},
+	{"tx_fifo_errors", IXGBE_NETDEV_STAT(tx_fifo_errors)},
+	{"tx_heartbeat_errors", IXGBE_NETDEV_STAT(tx_heartbeat_errors)},
 	{"tx_timeout_count", IXGBE_STAT(tx_timeout_count)},
 	{"tx_restart_queue", IXGBE_STAT(restart_queue)},
 	{"rx_long_length_errors", IXGBE_STAT(stats.roc)},


