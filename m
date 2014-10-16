From: roy.qing.li@gmail.com
Subject: [PATCH] vxlan: using pskb_may_pull as early as possible
Date: Thu, 16 Oct 2014 09:17:18 +0800
Message-ID: <1413422238-2562-1-git-send-email-roy.qing.li@gmail.com>
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38994 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbaJPBRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:17:25 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so2360229pab.37
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 18:17:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull should be used to check if skb->data has enough space,
skb->len can not ensure that.

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index faf1bd1..77ab844 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1437,9 +1437,6 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	if (!in6_dev)
 		goto out;
 
-	if (!pskb_may_pull(skb, skb->len))
-		goto out;
-
 	iphdr = ipv6_hdr(skb);
 	saddr = &iphdr->saddr;
 	daddr = &iphdr->daddr;
@@ -1880,7 +1877,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 			return arp_reduce(dev, skb);
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
-			 skb->len >= sizeof(struct ipv6hdr) + sizeof(struct nd_msg) &&
+			 pskb_may_pull(skb, sizeof(struct ipv6hdr)
+				       + sizeof(struct nd_msg)) &&
 			 ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6) {
 				struct nd_msg *msg;
 
-- 
1.7.10.4
