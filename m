From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/8] sctp: Use flowi4's {saddr,daddr} in
 sctp_v4_dst_saddr() and sctp_v4_get_dst()
Date: Wed, 04 May 2011 10:15:02 -0700 (PDT)
Message-ID: <20110504.101502.59687502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754784Ab1EDRPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2E74F24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:15:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{src,dst}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/protocol.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 9d3f159..69fbc55 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -339,13 +339,12 @@ static int sctp_v4_to_addr_param(const union sctp_addr *addr,
 }
 
 /* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v4_dst_saddr(union sctp_addr *saddr, struct dst_entry *dst,
+static void sctp_v4_dst_saddr(union sctp_addr *saddr, struct flowi4 *fl4,
 			      __be16 port)
 {
-	struct rtable *rt = (struct rtable *)dst;
 	saddr->v4.sin_family = AF_INET;
 	saddr->v4.sin_port = port;
-	saddr->v4.sin_addr.s_addr = rt->rt_src;
+	saddr->v4.sin_addr.s_addr = fl4->saddr;
 }
 
 /* Compare two addresses exactly. */
@@ -508,7 +507,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		/* Walk through the bind address list and look for a bind
 		 * address that matches the source address of the returned dst.
 		 */
-		sctp_v4_dst_saddr(&dst_saddr, dst, htons(bp->port));
+		sctp_v4_dst_saddr(&dst_saddr, fl4, htons(bp->port));
 		rcu_read_lock();
 		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
 			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
@@ -550,7 +549,7 @@ out:
 	t->dst = dst;
 	if (dst)
 		SCTP_DEBUG_PRINTK("rt_dst:%pI4, rt_src:%pI4\n",
-				  &rt->rt_dst, &rt->rt_src);
+				  &fl4->daddr, &fl4->saddr);
 	else
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");
 }
-- 
1.7.4.5

