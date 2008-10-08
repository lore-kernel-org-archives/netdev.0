From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 01/14] ipv6: local dev is actually unused in ip6_fragment
Date: Wed,  8 Oct 2008 15:51:49 +0400
Message-ID: <1223466722-8169-1-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9665 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbYJHLxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:53:54 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/ip6_output.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3df2c44..f22393e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -613,7 +613,6 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
-	struct net_device *dev;
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info*)skb->dst;
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
@@ -624,7 +623,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	int ptr, offset = 0, err=0;
 	u8 *prevhdr, nexthdr = 0;
 
-	dev = rt->u.dst.dev;
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
-- 
1.5.3.rc5

