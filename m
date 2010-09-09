From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ixgbevf: remove private net_device_stats
Date: Thu, 09 Sep 2010 10:48:31 +0200
Message-ID: <1284022111.2589.4.camel@edumazet-laptop>
References: <20100908073601.789.95153.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49448 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab0IIIsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 04:48:35 -0400
Received: by fxm16 with SMTP id 16so716994fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 01:48:34 -0700 (PDT)
In-Reply-To: <20100908073601.789.95153.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the net_device provided net_device_stats structure.

Remove ixgbevf_get_stats() now its not needed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    1 -
 drivers/net/ixgbevf/ixgbevf_main.c |   26 +++++---------------------
 2 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index f7015ef..da4033c 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -243,7 +243,6 @@ struct ixgbevf_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	/* structs defined in ixgbe_vf.h */
 	struct ixgbe_hw hw;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index bdbd26c..3eda1bd 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -308,8 +308,8 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
 
-	adapter->net_stats.tx_bytes += total_bytes;
-	adapter->net_stats.tx_packets += total_packets;
+	netdev->stats.tx_bytes += total_bytes;
+	netdev->stats.tx_packets += total_packets;
 
 	return (count < tx_ring->work_limit);
 }
@@ -639,8 +639,8 @@ next_desc:
 
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	adapter->netdev->stats.rx_bytes += total_rx_bytes;
+	adapter->netdev->stats.rx_packets += total_rx_packets;
 
 	return cleaned;
 }
@@ -2297,7 +2297,7 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 				adapter->stats.vfmprc);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.vfmprc -
+	adapter->netdev->stats.multicast = adapter->stats.vfmprc -
 		adapter->stats.base_vfmprc;
 }
 
@@ -3181,21 +3181,6 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 }
 
 /**
- * ixgbevf_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-static struct net_device_stats *ixgbevf_get_stats(struct net_device *netdev)
-{
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-
-	/* only return the current stats */
-	return &adapter->net_stats;
-}
-
-/**
  * ixgbevf_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -3272,7 +3257,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= &ixgbevf_open,
 	.ndo_stop		= &ixgbevf_close,
 	.ndo_start_xmit		= &ixgbevf_xmit_frame,
-	.ndo_get_stats		= &ixgbevf_get_stats,
 	.ndo_set_rx_mode	= &ixgbevf_set_rx_mode,
 	.ndo_set_multicast_list	= &ixgbevf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,


