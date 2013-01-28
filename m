From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2 1/2] netpoll: use ipv6_addr_equal() to compare ipv6 addr
Date: Mon, 28 Jan 2013 09:55:20 +0800
Message-ID: <1359338121-10897-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756484Ab3A1Bzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 20:55:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

ipv6_addr_equal() is faster.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/netpoll.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e2f79a1..a6f39b6 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -635,7 +635,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (memcmp(daddr, &np->local_ip, sizeof(*daddr)))
+			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
 				continue;
 
 			hlen = LL_RESERVED_SPACE(np->dev);
@@ -828,9 +828,9 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		if (udp6_csum_init(skb, uh, IPPROTO_UDP))
 			goto out;
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (memcmp(&np->local_ip.in6, &ip6h->daddr, sizeof(struct in6_addr)) != 0)
+			if (!ipv6_addr_equal(&np->local_ip.in6, &ip6h->daddr))
 				continue;
-			if (memcmp(&np->remote_ip.in6, &ip6h->saddr, sizeof(struct in6_addr)) != 0)
+			if (!ipv6_addr_equal(&np->remote_ip.in6, &ip6h->saddr))
 				continue;
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
-- 
1.7.7.6
