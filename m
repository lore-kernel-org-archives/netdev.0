From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/53] netfilter: nf_queue: get rid of dependency on IP6_NF_IPTABLES
Date: Mon, 26 Sep 2016 01:06:33 +0200
Message-ID: <1474844823-2026-24-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54688 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034791AbcIYXHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:54 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4E36FC1097
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:53 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3FB6DDA848
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:53 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 96A11DA817
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:40 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

hash_v6 is used by both nftables and ip6tables, so depend on
IP6_NF_IPTABLES is not properly.

Actually, it only parses ipv6hdr and computes a hash value, so
even if IPV6 is disabled, there's no side effect too, remove it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_queue.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 0dbce55437f2..cc8a11f7e306 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -54,7 +54,6 @@ static inline u32 hash_v4(const struct sk_buff *skb, u32 jhash_initval)
 			(__force u32)iph->saddr, iph->protocol, jhash_initval);
 }
 
-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static inline u32 hash_v6(const struct sk_buff *skb, u32 jhash_initval)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
@@ -77,7 +76,6 @@ static inline u32 hash_v6(const struct sk_buff *skb, u32 jhash_initval)
 
 	return jhash_3words(a, b, c, jhash_initval);
 }
-#endif
 
 static inline u32
 nfqueue_hash(const struct sk_buff *skb, u16 queue, u16 queues_total, u8 family,
@@ -85,10 +83,8 @@ nfqueue_hash(const struct sk_buff *skb, u16 queue, u16 queues_total, u8 family,
 {
 	if (family == NFPROTO_IPV4)
 		queue += ((u64) hash_v4(skb, jhash_initval) * queues_total) >> 32;
-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	else if (family == NFPROTO_IPV6)
 		queue += ((u64) hash_v6(skb, jhash_initval) * queues_total) >> 32;
-#endif
 
 	return queue;
 }
-- 
2.1.4
