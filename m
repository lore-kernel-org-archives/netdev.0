From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/33] netfilter: ipset: list:set: make sure all elements are checked by the gc
Date: Fri,  4 Oct 2013 10:33:03 +0200
Message-ID: <1380875598-5250-19-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55940 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547Ab3JDIez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:55 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When an element timed out, the next one was skipped by the garbage
collector, fixed.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index e44986a..30bf1dd 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -218,13 +218,16 @@ set_cleanup_entries(struct ip_set *set)
 {
 	struct list_set *map = set->data;
 	struct set_elem *e;
-	u32 i;
+	u32 i = 0;
 
-	for (i = 0; i < map->size; i++) {
+	while (i < map->size) {
 		e = list_set_elem(set, map, i);
 		if (e->id != IPSET_INVALID_ID &&
 		    ip_set_timeout_expired(ext_timeout(e, set)))
 			list_set_del(set, i);
+			/* Check element moved to position i in next loop */
+		else
+			i++;
 	}
 }
 
-- 
1.7.10.4
