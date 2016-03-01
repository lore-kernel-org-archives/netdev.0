From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] arp: correct return value of arp_rcv
Date: Tue,  1 Mar 2016 07:24:42 +0000
Message-ID: <1456817082-9320-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5357 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcCAHXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 02:23:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, arp_rcv() always return zero on a packet delivery upcall.

To make its behavior more compliant with the way this API should be
used, this patch changes this to let it return NET_RX_SUCCESS when the
packet is proper handled, and NET_RX_DROP otherwise.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/ipv4/arp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c102eb5..ae235a1 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -880,7 +880,7 @@ out:
 	consume_skb(skb);
 out_free_dst:
 	dst_release(reply_dst);
-	return 0;
+	return NET_RX_SUCCESS;
 }
 
 static void parp_redo(struct sk_buff *skb)
@@ -924,11 +924,11 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 consumeskb:
 	consume_skb(skb);
-	return 0;
+	return NET_RX_SUCCESS;
 freeskb:
 	kfree_skb(skb);
 out_of_mem:
-	return 0;
+	return NET_RX_DROP;
 }
 
 /*
-- 
1.8.3.1
