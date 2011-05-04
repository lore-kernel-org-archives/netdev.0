From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/8] pptp: Use flowi4's daddr/saddr in pptp_xmit().
Date: Wed, 04 May 2011 10:14:55 -0700 (PDT)
Message-ID: <20110504.101455.112591846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754724Ab1EDRP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8313724C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{src,dst}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/pptp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index e771e8d..1286fe2 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -271,8 +271,8 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		iph->frag_off	=	0;
 	iph->protocol = IPPROTO_GRE;
 	iph->tos      = 0;
-	iph->daddr    = rt->rt_dst;
-	iph->saddr    = rt->rt_src;
+	iph->daddr    = fl4.daddr;
+	iph->saddr    = fl4.saddr;
 	iph->ttl      = ip4_dst_hoplimit(&rt->dst);
 	iph->tot_len  = htons(skb->len);
 
-- 
1.7.4.5

