From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] veth: dont release skb->dst in veth_xmit()
Date: Fri, 29 May 2009 11:30:36 +0200
Message-ID: <4A1FAB3C.9090406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38791 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbZE2Jam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:30:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to release skb->dst, its now done by core network.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8e56fcf..87197dd 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -176,8 +176,6 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dev->features & NETIF_F_NO_CSUM)
 		skb->ip_summed = rcv_priv->ip_summed;
 
-	dst_release(skb->dst);
-	skb->dst = NULL;
 	skb->mark = 0;
 	secpath_reset(skb);
 	nf_reset(skb);
