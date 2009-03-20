From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] skb: expose and constify hash primitives
Date: Thu, 19 Mar 2009 23:34:04 -0700
Message-ID: <20090319233404.6697768b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44918 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbZCTGgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 02:36:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some minor changes to queue hashing:
 1. Use const on accessor functions
 2. Export skb_tx_hash for use in drivers (see ixgbe)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/skbuff.h |    9 ++++++---
 net/core/dev.c         |    3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

--- a/include/linux/skbuff.h	2009-03-19 22:57:01.041090287 -0700
+++ b/include/linux/skbuff.h	2009-03-19 22:59:00.951841088 -0700
@@ -1969,7 +1969,7 @@ static inline void skb_set_queue_mapping
 	skb->queue_mapping = queue_mapping;
 }
 
-static inline u16 skb_get_queue_mapping(struct sk_buff *skb)
+static inline u16 skb_get_queue_mapping(const struct sk_buff *skb)
 {
 	return skb->queue_mapping;
 }
@@ -1984,16 +1984,19 @@ static inline void skb_record_rx_queue(s
 	skb->queue_mapping = rx_queue + 1;
 }
 
-static inline u16 skb_get_rx_queue(struct sk_buff *skb)
+static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
 {
 	return skb->queue_mapping - 1;
 }
 
-static inline bool skb_rx_queue_recorded(struct sk_buff *skb)
+static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 {
 	return (skb->queue_mapping != 0);
 }
 
+extern u16 skb_tx_hash(const struct net_device *dev,
+		       const struct sk_buff *skb);
+
 #ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 {
--- a/net/core/dev.c	2009-03-19 22:57:01.031089784 -0700
+++ b/net/core/dev.c	2009-03-19 22:58:16.794089571 -0700
@@ -1725,7 +1725,7 @@ out_kfree_skb:
 
 static u32 skb_tx_hashrnd;
 
-static u16 skb_tx_hash(struct net_device *dev, struct sk_buff *skb)
+u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
 	u32 hash;
 
@@ -1740,6 +1740,7 @@ static u16 skb_tx_hash(struct net_device
 
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
+EXPORT_SYMBOL(skb_tx_hash);
 
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
