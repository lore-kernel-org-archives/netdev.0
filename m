From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] dev: remove duplicate 'skb->dev = dev' in dev_forward_skb()
Date: Fri, 17 May 2013 11:36:32 +0200
Message-ID: <1368783392-21574-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54423 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab3EQJgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 05:36:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was added by commit 59b9997baba5 (Revert "net: maintain namespace
isolation between vlan and real device").
In fact, before the initial commit - the one that is reverted -, this
statement was not present.
'skb->dev = dev' is already done in eth_type_trans(), which is call just
after.

Spotted-by: Alain Ritoux <alain.ritoux@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..18e9730 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1629,7 +1629,6 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		return NET_RX_DROP;
 	}
 	skb->skb_iif = 0;
-	skb->dev = dev;
 	skb_dst_drop(skb);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
-- 
1.8.2.1
