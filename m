From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: kill netif_copy_real_num_queues()
Date: Tue, 11 Nov 2014 13:29:42 -0800
Message-ID: <1415741382-7851-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:44755 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaKKV3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:29:50 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so10843474pdb.39
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 13:29:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan was the only user of netif_copy_real_num_queues(),
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
