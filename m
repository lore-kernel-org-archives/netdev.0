From: David Miller <davem@davemloft.net>
Subject: [PATCH 27/39]: netdev: netif_tx_disable() needs to operate on all
 TX queues.
Date: Thu, 03 Jul 2008 00:04:52 -0700 (PDT)
Message-ID: <20080703.000452.10956036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758255AbYGCHEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:04:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8558046..510a420 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1513,8 +1513,13 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 
 static inline void netif_tx_disable(struct net_device *dev)
 {
+	unsigned int i;
+
 	netif_tx_lock_bh(dev);
-	netif_stop_queue(dev);
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_stop_queue(txq);
+	}
 	netif_tx_unlock_bh(dev);
 }
 
-- 
1.5.6

