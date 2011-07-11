From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 1/2] net: introduce __netdev_alloc_skb_ip_align
Date: Mon, 11 Jul 2011 23:52:44 +0200
Message-ID: <1310421164.2860.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44085 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1GKVwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:52:49 -0400
Received: by wyg8 with SMTP id 8so2881191wyg.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 14:52:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX rings should use GFP_KERNEL allocations if possible, add
__netdev_alloc_skb_ip_align() helper to ease this.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 32ada53..a24218c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1579,16 +1579,22 @@ static inline struct sk_buff *netdev_alloc_skb(struct net_device *dev,
 	return __netdev_alloc_skb(dev, length, GFP_ATOMIC);
 }
 
-static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
-		unsigned int length)
+static inline struct sk_buff *__netdev_alloc_skb_ip_align(struct net_device *dev,
+		unsigned int length, gfp_t gfp)
 {
-	struct sk_buff *skb = netdev_alloc_skb(dev, length + NET_IP_ALIGN);
+	struct sk_buff *skb = __netdev_alloc_skb(dev, length + NET_IP_ALIGN, gfp);
 
 	if (NET_IP_ALIGN && skb)
 		skb_reserve(skb, NET_IP_ALIGN);
 	return skb;
 }
 
+static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
+		unsigned int length)
+{
+	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
+}
+
 /**
  *	__netdev_alloc_page - allocate a page for ps-rx on a specific device
  *	@dev: network device to receive on


