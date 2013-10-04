From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/33] netfilter: ipset: Don't call ip_nest_end needlessly in the error path
Date: Fri,  4 Oct 2013 10:32:49 +0200
Message-ID: <1380875598-5250-5-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h |    2 +-
 net/netfilter/ipset/ip_set_hash_gen.h   |    2 +-
 net/netfilter/ipset/ip_set_list_set.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 2524337..f6af97c 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -228,11 +228,11 @@ mtype_list(const struct ip_set *set,
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, adt);
 	if (unlikely(id == first)) {
 		cb->args[2] = 0;
 		return -EMSGSIZE;
 	}
+	ipset_nest_end(skb, adt);
 	return 0;
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 707bc52..7ff20ec 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -909,13 +909,13 @@ mtype_list(const struct ip_set *set,
 
 nla_put_failure:
 	nlmsg_trim(skb, incomplete);
-	ipset_nest_end(skb, atd);
 	if (unlikely(first == cb->args[2])) {
 		pr_warning("Can't list set %s: one bucket does not fit into "
 			   "a message. Please report it!\n", set->name);
 		cb->args[2] = 0;
 		return -EMSGSIZE;
 	}
+	ipset_nest_end(skb, atd);
 	return 0;
 }
 
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 979b8c9..68299ee 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -550,11 +550,11 @@ finish:
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, atd);
 	if (unlikely(i == first)) {
 		cb->args[2] = 0;
 		return -EMSGSIZE;
 	}
+	ipset_nest_end(skb, atd);
 	return 0;
 }
 
-- 
1.7.10.4

