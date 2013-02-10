From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: don't let node/interface scoped multicast traffic escape on the wire
Date: Sun, 10 Feb 2013 13:33:35 +0100
Message-ID: <20130210123335.GA18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, erik.hugne@ericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55319 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab3BJMdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 07:33:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c953825..155eccf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -120,6 +120,13 @@ static int ip6_finish_output2(struct sk_buff *skb)
 
 		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
 				skb->len);
+
+		if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
+		    IPV6_ADDR_SCOPE_NODELOCAL &&
+		    !(dev->flags & IFF_LOOPBACK)) {
+			kfree_skb(skb);
+			return 0;
+		}
 	}
 
 	rcu_read_lock_bh();
-- 
1.8.1.2
