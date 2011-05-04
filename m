From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/8] ipv4: Use flowi4's {saddr,daddr} in igmpv3_newpack()
 and igmp_send_report()
Date: Wed, 04 May 2011 10:15:00 -0700 (PDT)
Message-ID: <20110504.101500.39189344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754784Ab1EDRPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7CBEA24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:15:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{src,dst}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/igmp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7c2ef59..ec03c2f 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -344,8 +344,8 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	pip->tos      = 0xc0;
 	pip->frag_off = htons(IP_DF);
 	pip->ttl      = 1;
-	pip->daddr    = rt->rt_dst;
-	pip->saddr    = rt->rt_src;
+	pip->daddr    = fl4.daddr;
+	pip->saddr    = fl4.saddr;
 	pip->protocol = IPPROTO_IGMP;
 	pip->tot_len  = 0;	/* filled in later */
 	ip_select_ident(pip, &rt->dst, NULL);
@@ -687,7 +687,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	iph->frag_off = htons(IP_DF);
 	iph->ttl      = 1;
 	iph->daddr    = dst;
-	iph->saddr    = rt->rt_src;
+	iph->saddr    = fl4.saddr;
 	iph->protocol = IPPROTO_IGMP;
 	ip_select_ident(iph, &rt->dst, NULL);
 	((u8*)&iph[1])[0] = IPOPT_RA;
-- 
1.7.4.5

