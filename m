From: David Miller <davem@davemloft.net>
Subject: [PATCH 35/39]: netdev: Add helpers for operating on all TX queues.
Date: Thu, 03 Jul 2008 00:05:39 -0700 (PDT)
Message-ID: <20080703.000539.114289147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759240AbYGCHFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add netif_tx_{start,stop,wake}_all_queues() and
netif_tx_schedule_all() helper functions.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 79a153f..8b83d1f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -983,6 +983,14 @@ static inline void netif_schedule(struct net_device *dev)
 	netif_schedule_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_schedule_all(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		netif_schedule_queue(netdev_get_tx_queue(dev, i));
+}
+
 /**
  *	netif_start_queue - allow transmit
  *	@dev: network device
@@ -999,6 +1007,16 @@ static inline void netif_start_queue(struct net_device *dev)
 	netif_tx_start_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_start_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_start_queue(txq);
+	}
+}
+
 /**
  *	netif_wake_queue - restart transmit
  *	@dev: network device
@@ -1023,6 +1041,16 @@ static inline void netif_wake_queue(struct net_device *dev)
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_wake_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_wake_queue(txq);
+	}
+}
+
 /**
  *	netif_stop_queue - stop transmitted packets
  *	@dev: network device
@@ -1040,6 +1068,16 @@ static inline void netif_stop_queue(struct net_device *dev)
 	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_stop_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_stop_queue(txq);
+	}
+}
+
 /**
  *	netif_queue_stopped - test if transmit queue is flowblocked
  *	@dev: network device
-- 
1.5.6

