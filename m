From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 07/13] ipv6: drop metadata dst in ip6_route_input
Date: Wed, 19 Aug 2015 12:09:57 +0200
Message-ID: <da9ffa03a9260042f5f325b1e7d56ded32d846b5.1439978875.git.jbenc@redhat.com>
References: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, Wei-Chun Chao <weichunc@plumgrid.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753691AbbHSKLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:40 -0400
In-Reply-To: <cover.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fix in commit 48fb6b554501 is incomplete, as now ip6_route_input can be
called with non-NULL dst if it's a metadata dst and the reference is leaked.
Drop the reference.

Fixes: 48fb6b554501 ("ipv6: fix crash over flow-based vxlan device")
Fixes: ee122c79d422 ("vxlan: Flow based tunneling")
CC: Wei-Chun Chao <weichunc@plumgrid.com>
CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e6bbcdee7707..0947ad0b3de8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1140,6 +1140,7 @@ void ip6_route_input(struct sk_buff *skb)
 		.flowi6_proto = iph->nexthdr,
 	};
 
+	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
 
-- 
1.8.3.1
