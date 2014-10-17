From: roy.qing.li@gmail.com
Subject: [PATCH v2] vxlan: fix a free after use
Date: Fri, 17 Oct 2014 14:06:16 +0800
Message-ID: <1413525976-2624-1-git-send-email-roy.qing.li@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:45274 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaJQGGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 02:06:22 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so194805pdb.7
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 23:06:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull maybe change skb->data and make eth pointer oboslete,
so eth needs to reload

Fixes: 91269e390d062 ("vxlan: using pskb_may_pull as early as possible")
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 855a81d..fabd514 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1885,6 +1885,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
 					return neigh_reduce(dev, skb);
 		}
+		eth = eth_hdr(skb);
 #endif
 	}
 
-- 
1.7.10.4
