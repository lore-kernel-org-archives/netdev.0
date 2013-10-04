From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/33] netfilter: ipset: For set:list types, replaced elements must be zeroed out
Date: Fri,  4 Oct 2013 10:33:11 +0200
Message-ID: <1380875598-5250-27-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56031 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3JDIfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:35:05 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The new extensions require zero initialization for the new element
to be added into a slot from where another element was pushed away.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index f9681dc..e23f33c 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -184,6 +184,8 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 			}
 			memmove(list_set_elem(set, map, i + 1), e,
 				set->dsize * (map->size - (i + 1)));
+			/* Extensions must be initialized to zero */
+			memset(e, 0, set->dsize);
 		}
 	}
 
@@ -192,7 +194,7 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 		ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(e, set), ext);
-	if (SET_WITH_COMMENT(set) && ext->comment)
+	if (SET_WITH_COMMENT(set))
 		ip_set_init_comment(ext_comment(e, set), ext);
 	return 0;
 }
-- 
1.7.10.4
