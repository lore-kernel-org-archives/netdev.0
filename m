From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] netfilter: ipset: Allocate the proper size of memory when /0 networks are supported
Date: Wed,  3 Dec 2014 13:55:41 +0100
Message-ID: <1417611342-25257-12-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48732 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbaLCMxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:42 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 8ef9135..974ff38 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1101,8 +1101,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 
 	hsize = sizeof(*h);
 #ifdef IP_SET_HASH_WITH_NETS
-	hsize += sizeof(struct net_prefixes) *
-		(set->family == NFPROTO_IPV4 ? 32 : 128);
+	hsize += sizeof(struct net_prefixes) * NLEN(set->family);
 #endif
 	h = kzalloc(hsize, GFP_KERNEL);
 	if (!h)
-- 
1.7.10.4
