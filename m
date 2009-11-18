From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netsched: Allow var_sk_bound_if meta to work
 on all namespaces
Date: Thu, 19 Nov 2009 00:58:57 +0100
Message-ID: <4B048A41.7090103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60030 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147AbZKRX6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 18:58:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix can probably wait 2.6.33, or should use another patch
if needed in 2.6.32 (no get_dev_by_index_rcu() before 2.6.33)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 8e8d836..24dce8b 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -310,7 +310,8 @@ META_COLLECTOR(var_sk_bound_if)
 		struct net_device *dev;
 
 		rcu_read_lock();
-		dev = dev_get_by_index_rcu(&init_net, skb->sk->sk_bound_dev_if);
+		dev = dev_get_by_index_rcu(sock_net(skb->sk),
+					   skb->sk->sk_bound_dev_if);
 		*err = var_dev(dev, dst);
 		rcu_read_unlock();
 	}
