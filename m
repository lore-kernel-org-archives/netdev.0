From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 4/7] net: constify is_skb_forwardable's arguments
Date: Wed, 27 Apr 2016 18:18:19 +0200
Message-ID: <1461773902-13528-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35599 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbcD0QSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:35 -0400
Received: by mail-wm0-f44.google.com with SMTP id e201so46300757wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:35 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

is_skb_forwardable is not supposed to change anything so constify its
arguments

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/netdevice.h | 3 ++-
 net/core/dev.c            | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1f6d5db471a2..85d56e7cd46b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3263,7 +3263,8 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
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
