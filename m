From: David Miller <davem@davemloft.net>
Subject: [PATCH 30/39]: netdev: Add netdev->select_queue() method.
Date: Thu, 03 Jul 2008 00:05:10 -0700 (PDT)
Message-ID: <20080703.000510.80165060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758603AbYGCHFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:11 -0400
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
index f119532..6ba9cd0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -724,6 +724,9 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+	u16			(*select_queue)(struct net_device *dev,
+						struct sk_buff *skb);
+
 #ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ccf016..21f3cc5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1671,6 +1671,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 {
 	u16 queue_index = 0;
 
+	if (dev->select_queue)
+		queue_index = dev->select_queue(dev, skb);
+
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
 }
-- 
1.5.6

