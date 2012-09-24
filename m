From: pablo@netfilter.org
Subject: [PATCH 11/16] netfilter: ipset: Coding style fixes
Date: Mon, 24 Sep 2012 21:19:23 +0200
Message-ID: <1348514369-3272-12-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58129 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab2IXTVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:06 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h       |    5 +++--
 include/linux/netfilter/ipset/ip_set_ahash.h |    2 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    4 ++--
 net/netfilter/ipset/ip_set_core.c            |    9 ++++++---
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 1d954c6..0c1e97b 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -255,7 +255,7 @@ struct ip_set_type_variant {
 	 *		returns negative error code,
 	 *			zero for no match/success to add/delete
 	 *			positive for matching element */
-	int (*kadt)(struct ip_set *set, const struct sk_buff * skb,
+	int (*kadt)(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
 		    enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 
@@ -430,7 +430,8 @@ static inline int nla_put_ipaddr4(struct sk_buff *skb, int type, __be32 ipaddr)
 	return ret;
 }
 
-static inline int nla_put_ipaddr6(struct sk_buff *skb, int type, const struct in6_addr *ipaddrptr)
+static inline int nla_put_ipaddr6(struct sk_buff *skb, int type,
+				  const struct in6_addr *ipaddrptr)
 {
 	struct nlattr *__nested = ipset_nest_start(skb, type);
 	int ret;
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 495acdf..ef9acd3 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -696,7 +696,7 @@ nla_put_failure:
 }
 
 static int
-type_pf_kadt(struct ip_set *set, const struct sk_buff * skb,
+type_pf_kadt(struct ip_set *set, const struct sk_buff *skb,
 	     const struct xt_action_param *par,
 	     enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 static int
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 645c9d1..0f92dc2 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -323,11 +323,11 @@ bitmap_ipmac_tlist(const struct ip_set *set,
 		    (elem->match == MAC_FILLED &&
 		     nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN,
 			     elem->ether)))
-		    goto nla_put_failure;
+			goto nla_put_failure;
 		timeout = elem->match == MAC_UNSET ? elem->timeout
 				: ip_set_timeout_get(elem->timeout);
 		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(timeout)))
-		    goto nla_put_failure;
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, atd);
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index ad39ef4..72e9bf0 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -69,7 +69,8 @@ find_set_type(const char *name, u8 family, u8 revision)
 
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
-		    (type->family == family || type->family == NFPROTO_UNSPEC) &&
+		    (type->family == family ||
+		     type->family == NFPROTO_UNSPEC) &&
 		    revision >= type->revision_min &&
 		    revision <= type->revision_max)
 			return type;
@@ -149,7 +150,8 @@ __find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max,
 	rcu_read_lock();
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
-		    (type->family == family || type->family == NFPROTO_UNSPEC)) {
+		    (type->family == family ||
+		     type->family == NFPROTO_UNSPEC)) {
 			found = true;
 			if (type->revision_min < *min)
 				*min = type->revision_min;
@@ -721,7 +723,8 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * by the nfnl mutex. Find the first free index in ip_set_list
 	 * and check clashing.
 	 */
-	if ((ret = find_free_id(set->name, &index, &clash)) != 0) {
+	ret = find_free_id(set->name, &index, &clash);
+	if (ret != 0) {
 		/* If this is the same set and requested, ignore error */
 		if (ret == -EEXIST &&
 		    (flags & IPSET_FLAG_EXIST) &&
-- 
1.7.10.4
