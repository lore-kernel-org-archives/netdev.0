From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/15]: net/core/dev.c: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:10 -0700 (PDT)
Message-ID: <20090609.050210.266476784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759337AbZFIMCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 47F7EC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1f38401..4913089 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1820,7 +1820,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	if (netif_needs_gso(dev, skb))
 		goto gso;
 
-	if (skb_shinfo(skb)->frag_list &&
+	if (skb_has_frags(skb) &&
 	    !(dev->features & NETIF_F_FRAGLIST) &&
 	    __skb_linearize(skb))
 		goto out_kfree_skb;
@@ -2407,7 +2407,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
-	if (skb_is_gso(skb) || skb_shinfo(skb)->frag_list)
+	if (skb_is_gso(skb) || skb_has_frags(skb))
 		goto normal;
 
 	rcu_read_lock();
-- 
1.6.3.2

