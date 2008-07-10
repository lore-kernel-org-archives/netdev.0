From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/13]: netdev: Add netdev->select_queue() method.
Date: Thu, 10 Jul 2008 03:57:01 -0700 (PDT)
Message-ID: <20080710.035701.71601535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753927AbYGJK5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:57:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6BE95C8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:57:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Devices or device layers can set this to control the
queue selection performed by dev_pick_tx().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b580331..17a81d0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -723,6 +723,9 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+	u16			(*select_queue)(struct net_device *dev,
+						struct sk_buff *skb);
+
 #ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
diff --git a/net/core/dev.c b/net/core/dev.c
index 0c088b5..db95b49 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1670,6 +1670,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 {
 	u16 queue_index = 0;
 
+	if (dev->select_queue)
+		queue_index = dev->select_queue(dev, skb);
+
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
 }
-- 
1.5.6.2.255.gbed62

