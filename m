From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/6] e1000e: update netstats traffic counters realtime
Date: Tue, 13 Nov 2007 15:11:10 -0800
Message-ID: <20071113231110.13177.27339.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39179 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762968AbXKMXQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 18:16:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

formerly e1000/e1000e only updated traffic counters once every
2 seconds with the register values of bytes/packets. With newer
code however in the interrupt and polling code we can real-time
fill in these values in the netstats struct for users to see.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a271112..6c99703 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -458,6 +458,8 @@ next_desc:
 
 	adapter->total_rx_packets += total_rx_packets;
 	adapter->total_rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
 	return cleaned;
 }
 
@@ -593,6 +595,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
+	adapter->net_stats.tx_packets += total_tx_packets;
+	adapter->net_stats.tx_bytes += total_tx_bytes;
 	return cleaned;
 }
 
@@ -755,6 +759,8 @@ next_desc:
 
 	adapter->total_rx_packets += total_rx_packets;
 	adapter->total_rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
 	return cleaned;
 }
 
@@ -2537,10 +2543,6 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	}
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.rx_packets = adapter->stats.gprc;
-	adapter->net_stats.tx_packets = adapter->stats.gptc;
-	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
-	adapter->net_stats.tx_bytes = adapter->stats.gotcl;
 	adapter->net_stats.multicast = adapter->stats.mprc;
 	adapter->net_stats.collisions = adapter->stats.colc;
 
