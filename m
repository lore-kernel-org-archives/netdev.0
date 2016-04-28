From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: constify is_skb_forwardable's arguments
Date: Thu, 28 Apr 2016 17:59:28 +0200
Message-ID: <1461859168-6217-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37912 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcD1P7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:59:33 -0400
Received: by mail-wm0-f44.google.com with SMTP id g17so49220780wme.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:59:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

is_skb_forwardable is not supposed to change anything so constify its
arguments

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Hit this while working on the bridge per-vlan stats and needed to pass a
constified skb down. skb_is_gso() already takes a const skb.

 include/linux/netdevice.h | 3 ++-
 net/core/dev.c            | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18d8394f2e5d..f9d573e26db3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3260,7 +3260,8 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
-bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
+bool is_skb_forwardable(const struct net_device *dev,
+			const struct sk_buff *skb);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6324bc9267f7..36f0170a0754 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1741,7 +1741,7 @@ static inline void net_timestamp_set(struct sk_buff *skb)
 			__net_timestamp(SKB);		\
 	}						\
 
-bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb)
+bool is_skb_forwardable(const struct net_device *dev, const struct sk_buff *skb)
 {
 	unsigned int len;
 
-- 
2.4.11
