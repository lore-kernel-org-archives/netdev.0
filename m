From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] don't compare skb->network_header with skb->tail
Date: Sun, 10 Mar 2013 17:15:25 +0800
Message-ID: <1362906925-45308-1-git-send-email-honkiko@gmail.com>
Cc: zhiguo.hong@emc.com, Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:40646 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab3CJJPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 05:15:49 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so2669695pbc.23
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 01:15:48 -0800 (PST)
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
