From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: Elide use of rt->rt_dst in ip_forward()
Date: Thu, 12 May 2011 19:39:11 -0400 (EDT)
Message-ID: <20110512.193911.269827437433393327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882Ab1ELXjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:39:14 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4CNdCju008097
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 16:39:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No matter what kind of header mangling occurs due to IP options
processing, rt->rt_dst will always equal iph->daddr in the packet.

So we can safely use iph->daddr instead of rt->rt_dst here.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 99461f0..fcbc0c8 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -84,7 +84,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
+	if (opt->is_strictroute && iph->daddr != rt->rt_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-- 
1.7.4.4

