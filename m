From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] netpoll: add RCU annotation to npinfo field
Date: Wed, 23 Jan 2013 15:29:39 +0800
Message-ID: <1358926179-7168-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753003Ab3AWH37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 02:29:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

dev->npinfo is protected by RCU.

This fixes the following sparse warnings:

net/core/netpoll.c:177:48: error: incompatible types in comparison expression (different address spaces)
net/core/netpoll.c:200:35: error: incompatible types in comparison expression (different address spaces)
net/core/netpoll.c:221:35: error: incompatible types in comparison expression (different address spaces)
net/core/netpoll.c:327:18: error: incompatible types in comparison expression (different address spaces)

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 549f5ad..85b0949 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1272,7 +1272,7 @@ struct net_device {
 	void (*destructor)(struct net_device *dev);
 
 #ifdef CONFIG_NETPOLL
-	struct netpoll_info	*npinfo;
+	struct netpoll_info __rcu	*npinfo;
 #endif
 
 #ifdef CONFIG_NET_NS
