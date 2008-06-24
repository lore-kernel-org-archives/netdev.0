From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3]: netdev: Add addr_list_lock to struct net_device.
Date: Mon, 23 Jun 2008 20:54:16 -0700 (PDT)
Message-ID: <20080623.205416.255425972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753606AbYFXDyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:54:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7F0F0C8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:54:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netdev: Add addr_list_lock to struct net_device.

This will be used to protect the per-device unicast and multicast
address lists, as well as the callbacks into the drivers which
configure such state such as ->set_rx_mode() and ->set_multicast_list().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1304ad2..fb5a0ec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -590,6 +590,7 @@ struct net_device
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
+	spinlock_t		addr_list_lock;
 	struct dev_addr_list	*uc_list;	/* Secondary unicast mac addresses */
 	int			uc_count;	/* Number of installed ucasts	*/
 	int			uc_promisc;
diff --git a/net/core/dev.c b/net/core/dev.c
index f6944ec..7b50e8d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3784,6 +3784,7 @@ int register_netdevice(struct net_device *dev)
 	net = dev_net(dev);
 
 	spin_lock_init(&dev->queue_lock);
+	spin_lock_init(&dev->addr_list_lock);
 	spin_lock_init(&dev->_xmit_lock);
 	netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
 	dev->xmit_lock_owner = -1;
-- 
1.5.6

