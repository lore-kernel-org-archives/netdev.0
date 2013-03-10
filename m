From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] don't compare skb->network_header with skb->tail
Date: Sun, 10 Mar 2013 16:42:07 +0800
Message-ID: <1362904927-44673-1-git-send-email-honkiko@gmail.com>
Cc: zhiguo.hong@emc.com, Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns12.online.tj.cn ([111.161.70.12]:16394 "EHLO suse.kiko.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752193Ab3CJIm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 04:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in the case of NET_SKBUFF_DATA_USES_OFFSET(on 64-bit arch),
skb->network_header is just offset over skb->head.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 90cee5b..378e0b9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1705,7 +1705,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			skb_reset_mac_header(skb2);
 
 			if (skb_network_header(skb2) < skb2->data ||
-			    skb2->network_header > skb2->tail) {
+			    skb_network_header(skb2) > skb2->tail) {
 				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
 						     ntohs(skb2->protocol),
 						     dev->name);
-- 
1.7.10.4
