From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 1/2] net: Allow modules to use is_skb_forwardable
Date: Wed, 26 Mar 2014 12:00:26 -0400
Message-ID: <1395849627-15711-3-git-send-email-vyasevic@redhat.com>
References: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755634AbaCZQVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 12:21:15 -0400
In-Reply-To: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e8eeebd..d855794 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2551,6 +2551,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
+bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..a98f7fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1645,7 +1645,7 @@ static inline void net_timestamp_set(struct sk_buff *skb)
 			__net_timestamp(SKB);		\
 	}						\
 
-static inline bool is_skb_forwardable(struct net_device *dev,
+bool is_skb_forwardable(struct net_device *dev,
 				      struct sk_buff *skb)
 {
 	unsigned int len;
@@ -1665,6 +1665,7 @@ static inline bool is_skb_forwardable(struct net_device *dev,
 
 	return false;
 }
+EXPORT_SYMBOL_GPL(is_skb_forwardable);
 
 /**
  * dev_forward_skb - loopback an skb to another netif
-- 
1.8.5.3
