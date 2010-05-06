From: David Miller <davem@davemloft.net>
Subject: [PATCH] netpoll: Use 'bool' for netpoll_rx() return type.
Date: Thu, 06 May 2010 01:20:51 -0700 (PDT)
Message-ID: <20100506.012051.149835101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754004Ab0EFIUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:20:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B458824C090
	for <netdev@vger.kernel.org>; Thu,  6 May 2010 01:20:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

I noticed this while validating and auditing Eric Dumazet's vnet
fix...  applied to net-next-2.6

 include/linux/netpoll.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 017e604..3688c83 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -55,19 +55,19 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
 
 
 #ifdef CONFIG_NETPOLL
-static inline int netpoll_rx(struct sk_buff *skb)
+static inline bool netpoll_rx(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = skb->dev->npinfo;
 	unsigned long flags;
-	int ret = 0;
+	int ret = false;
 
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
-		return 0;
+		return false;
 
 	spin_lock_irqsave(&npinfo->rx_lock, flags);
 	/* check rx_flags again with the lock held */
 	if (npinfo->rx_flags && __netpoll_rx(skb))
-		ret = 1;
+		ret = true;
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
 	return ret;
-- 
1.7.0.4

