From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 10/15] netpoll: convert several functions to bool
Date: Fri, 10 Aug 2012 19:24:46 +0800
Message-ID: <1344597891-32242-11-git-send-email-amwang@redhat.com>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654Ab2HJLZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:25:46 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are just boolean, let them return
bool instead of int.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/netpoll.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 61aee86..66d5379 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -66,7 +66,7 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 
 #ifdef CONFIG_NETPOLL
-static inline int netpoll_rx_on(struct sk_buff *skb)
+static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
@@ -125,7 +125,7 @@ static inline void netpoll_poll_unlock(void *have)
 	}
 }
 
-static inline int netpoll_tx_running(struct net_device *dev)
+static inline bool netpoll_tx_running(struct net_device *dev)
 {
 	return irqs_disabled();
 }
@@ -133,11 +133,11 @@ static inline int netpoll_tx_running(struct net_device *dev)
 #else
 static inline bool netpoll_rx(struct sk_buff *skb)
 {
-	return 0;
+	return false;
 }
-static inline int netpoll_rx_on(struct sk_buff *skb)
+static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
-	return 0;
+	return false;
 }
 static inline int netpoll_receive_skb(struct sk_buff *skb)
 {
@@ -153,9 +153,9 @@ static inline void netpoll_poll_unlock(void *have)
 static inline void netpoll_netdev_init(struct net_device *dev)
 {
 }
-static inline int netpoll_tx_running(struct net_device *dev)
+static inline bool netpoll_tx_running(struct net_device *dev)
 {
-	return 0;
+	return false;
 }
 #endif
 
-- 
1.7.7.6
