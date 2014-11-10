From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: remove netif_set_real_num_rx_queues()
Date: Mon, 10 Nov 2014 11:35:36 -0800
Message-ID: <1415648136-4167-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:39159 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbaKJTfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:35:54 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so8956913pab.10
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:35:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan was the only user of netif_set_real_num_rx_queues(),
but it no longer calls it after
commit 4af429d29b341bb1735f04c2fb960178 ("vlan: lockless transmit path").
So we can just remove it.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 888d551..4a6f770 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2762,23 +2762,6 @@ static inline int netif_set_real_num_rx_queues(struct net_device *dev,
 }
 #endif
 
-static inline int netif_copy_real_num_queues(struct net_device *to_dev,
-					     const struct net_device *from_dev)
-{
-	int err;
-
-	err = netif_set_real_num_tx_queues(to_dev,
-					   from_dev->real_num_tx_queues);
-	if (err)
-		return err;
-#ifdef CONFIG_SYSFS
-	return netif_set_real_num_rx_queues(to_dev,
-					    from_dev->real_num_rx_queues);
-#else
-	return 0;
-#endif
-}
-
 #ifdef CONFIG_SYSFS
 static inline unsigned int get_netdev_rx_queue_index(
 		struct netdev_rx_queue *queue)
