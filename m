From: pablo@netfilter.org
Subject: [PATCH 01/23] netfilter: ipset: use NFPROTO_ constants
Date: Thu,  8 Mar 2012 02:00:50 +0100
Message-ID: <1331168472-5820-2-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

ipset is actually using NFPROTO values rather than AF (xt_set passes
that along).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h      |    5 ++++-
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    4 ++--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    4 ++--
 net/netfilter/ipset/ip_set_bitmap_port.c    |    4 ++--
 net/netfilter/ipset/ip_set_core.c           |   16 ++++++++--------
 net/netfilter/ipset/ip_set_getport.c        |    4 ++--
 net/netfilter/ipset/ip_set_hash_ip.c        |   18 +++++++++---------
 net/netfilter/ipset/ip_set_hash_ipport.c    |   10 +++++-----
 net/netfilter/ipset/ip_set_hash_ipportip.c  |   10 +++++-----
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_net.c       |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netiface.c  |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netport.c   |   12 ++++++------
 net/netfilter/ipset/ip_set_list_set.c       |    2 +-
 14 files changed, 64 insertions(+), 61 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 3540c6e..e7b06f5 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -288,7 +288,10 @@ struct ip_set_type {
 	u8 features;
 	/* Set type dimension */
 	u8 dimension;
-	/* Supported family: may be AF_UNSPEC for both AF_INET/AF_INET6 */
+	/*
+	 * Supported family: may be NFPROTO_UNSPEC for both
+	 * NFPROTO_IPV4/NFPROTO_IPV6.
+	 */
 	u8 family;
 	/* Type revisions */
 	u8 revision_min, revision_max;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index e3e7399..a72a4df 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -442,7 +442,7 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
 	map->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
-	set->family = AF_INET;
+	set->family = NFPROTO_IPV4;
 
 	return true;
 }
@@ -550,7 +550,7 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 	.revision_min	= 0,
 	.revision_max	= 0,
 	.create		= bitmap_ip_create,
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 56096f5..81324c1 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -543,7 +543,7 @@ init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
 	map->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
-	set->family = AF_INET;
+	set->family = NFPROTO_IPV4;
 
 	return true;
 }
@@ -623,7 +623,7 @@ static struct ip_set_type bitmap_ipmac_type = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_MAC,
 	.dimension	= IPSET_DIM_TWO,
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 	.revision_min	= 0,
 	.revision_max	= 0,
 	.create		= bitmap_ipmac_create,
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 29ba93b..382ec28 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -422,7 +422,7 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 	map->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
-	set->family = AF_UNSPEC;
+	set->family = NFPROTO_UNSPEC;
 
 	return true;
 }
@@ -483,7 +483,7 @@ static struct ip_set_type bitmap_port_type = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_ONE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 0,
 	.create		= bitmap_port_create,
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index e7f90e7..e6c1c96 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -69,7 +69,7 @@ find_set_type(const char *name, u8 family, u8 revision)
 
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
-		    (type->family == family || type->family == AF_UNSPEC) &&
+		    (type->family == family || type->family == NFPROTO_UNSPEC) &&
 		    revision >= type->revision_min &&
 		    revision <= type->revision_max)
 			return type;
@@ -149,7 +149,7 @@ __find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max,
 	rcu_read_lock();
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
-		    (type->family == family || type->family == AF_UNSPEC)) {
+		    (type->family == family || type->family == NFPROTO_UNSPEC)) {
 			found = true;
 			if (type->revision_min < *min)
 				*min = type->revision_min;
@@ -164,8 +164,8 @@ __find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max,
 		__find_set_type_minmax(name, family, min, max, true);
 }
 
-#define family_name(f)	((f) == AF_INET ? "inet" : \
-			 (f) == AF_INET6 ? "inet6" : "any")
+#define family_name(f)	((f) == NFPROTO_IPV4 ? "inet" : \
+			 (f) == NFPROTO_IPV6 ? "inet6" : "any")
 
 /* Register a set type structure. The type is identified by
  * the unique triple of name, family and revision.
@@ -354,7 +354,7 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (opt->dim < set->type->dimension ||
-	    !(opt->family == set->family || set->family == AF_UNSPEC))
+	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return 0;
 
 	read_lock_bh(&set->lock);
@@ -387,7 +387,7 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (opt->dim < set->type->dimension ||
-	    !(opt->family == set->family || set->family == AF_UNSPEC))
+	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return 0;
 
 	write_lock_bh(&set->lock);
@@ -410,7 +410,7 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (opt->dim < set->type->dimension ||
-	    !(opt->family == set->family || set->family == AF_UNSPEC))
+	    !(opt->family == set->family || set->family == NFPROTO_UNSPEC))
 		return 0;
 
 	write_lock_bh(&set->lock);
@@ -575,7 +575,7 @@ start_msg(struct sk_buff *skb, u32 pid, u32 seq, unsigned int flags,
 		return NULL;
 
 	nfmsg = nlmsg_data(nlh);
-	nfmsg->nfgen_family = AF_INET;
+	nfmsg->nfgen_family = NFPROTO_IPV4;
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = 0;
 
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 1f03556..6fdf88a 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -136,10 +136,10 @@ ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src, __be16 *port)
 	u8 proto;
 
 	switch (pf) {
-	case AF_INET:
+	case NFPROTO_IPV4:
 		ret = ip_set_get_ip4_port(skb, src, port, &proto);
 		break;
-	case AF_INET6:
+	case NFPROTO_IPV6:
 		ret = ip_set_get_ip6_port(skb, src, port, &proto);
 		break;
 	default:
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 4015fca..5139dea 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -366,11 +366,11 @@ hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u8 netmask, hbits;
 	struct ip_set_hash *h;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
-	netmask = set->family == AF_INET ? 32 : 128;
+	netmask = set->family == NFPROTO_IPV4 ? 32 : 128;
 	pr_debug("Create set %s with family %s\n",
-		 set->name, set->family == AF_INET ? "inet" : "inet6");
+		 set->name, set->family == NFPROTO_IPV4 ? "inet" : "inet6");
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
@@ -389,8 +389,8 @@ hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_NETMASK]) {
 		netmask = nla_get_u8(tb[IPSET_ATTR_NETMASK]);
 
-		if ((set->family == AF_INET && netmask > 32) ||
-		    (set->family == AF_INET6 && netmask > 128) ||
+		if ((set->family == NFPROTO_IPV4 && netmask > 32) ||
+		    (set->family == NFPROTO_IPV6 && netmask > 128) ||
 		    netmask == 0)
 			return -IPSET_ERR_INVALID_NETMASK;
 	}
@@ -419,15 +419,15 @@ hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ip4_tvariant : &hash_ip6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_ip4_gc_init(set);
 		else
 			hash_ip6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ip4_variant : &hash_ip6_variant;
 	}
 
@@ -443,7 +443,7 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 0,
 	.create		= hash_ip_create,
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 37d667e..9c27e24 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -450,7 +450,7 @@ hash_ipport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -490,15 +490,15 @@ hash_ipport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipport4_tvariant : &hash_ipport6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_ipport4_gc_init(set);
 		else
 			hash_ipport6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipport4_variant : &hash_ipport6_variant;
 	}
 
@@ -514,7 +514,7 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_ipport_create,
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index e69e271..9134057 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -468,7 +468,7 @@ hash_ipportip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -508,15 +508,15 @@ hash_ipportip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipportip4_tvariant : &hash_ipportip6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_ipportip4_gc_init(set);
 		else
 			hash_ipportip6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipportip4_variant : &hash_ipportip6_variant;
 	}
 
@@ -532,7 +532,7 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_ipportip_create,
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 64199b4..0edb35b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -554,7 +554,7 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -573,7 +573,7 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	h = kzalloc(sizeof(*h)
 		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == AF_INET ? 32 : 128), GFP_KERNEL);
+		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
 	if (!h)
 		return -ENOMEM;
 
@@ -596,16 +596,16 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipportnet4_tvariant
 			: &hash_ipportnet6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_ipportnet4_gc_init(set);
 		else
 			hash_ipportnet6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_ipportnet4_variant : &hash_ipportnet6_variant;
 	}
 
@@ -621,7 +621,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	/*		  1	   SCTP and UDPLITE support added */
 	.revision_max	= 2,	/* Range as input support for IPv4 added */
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 2898819..5a4457a 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -406,7 +406,7 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -425,7 +425,7 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	h = kzalloc(sizeof(*h)
 		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == AF_INET ? 32 : 128), GFP_KERNEL);
+		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
 	if (!h)
 		return -ENOMEM;
 
@@ -448,15 +448,15 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_net4_tvariant : &hash_net6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_net4_gc_init(set);
 		else
 			hash_net6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_net4_variant : &hash_net6_variant;
 	}
 
@@ -472,7 +472,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 1,	/* Range as input support for IPv4 added */
 	.create		= hash_net_create,
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index e13095d..a9fb4af 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -678,7 +678,7 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -697,7 +697,7 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	h = kzalloc(sizeof(*h)
 		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == AF_INET ? 32 : 128), GFP_KERNEL);
+		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
 	if (!h)
 		return -ENOMEM;
 
@@ -722,15 +722,15 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_netiface4_tvariant : &hash_netiface6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_netiface4_gc_init(set);
 		else
 			hash_netiface6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_netiface4_variant : &hash_netiface6_variant;
 	}
 
@@ -746,7 +746,7 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_IFACE,
 	.dimension	= IPSET_DIM_TWO,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.create		= hash_netiface_create,
 	.create_policy	= {
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 8f9de72..1fcc102 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -507,7 +507,7 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
 
-	if (!(set->family == AF_INET || set->family == AF_INET6))
+	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
@@ -526,7 +526,7 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	h = kzalloc(sizeof(*h)
 		    + sizeof(struct ip_set_hash_nets)
-		      * (set->family == AF_INET ? 32 : 128), GFP_KERNEL);
+		      * (set->family == NFPROTO_IPV4 ? 32 : 128), GFP_KERNEL);
 	if (!h)
 		return -ENOMEM;
 
@@ -549,15 +549,15 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_netport4_tvariant : &hash_netport6_tvariant;
 
-		if (set->family == AF_INET)
+		if (set->family == NFPROTO_IPV4)
 			hash_netport4_gc_init(set);
 		else
 			hash_netport6_gc_init(set);
 	} else {
-		set->variant = set->family == AF_INET
+		set->variant = set->family == NFPROTO_IPV4
 			? &hash_netport4_variant : &hash_netport6_variant;
 	}
 
@@ -573,7 +573,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	/*		  1	   SCTP and UDPLITE support added */
 	.revision_max	= 2,	/* Range as input support for IPv4 added */
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 4d10819..7e095f9 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -575,7 +575,7 @@ static struct ip_set_type list_set_type __read_mostly = {
 	.protocol	= IPSET_PROTOCOL,
 	.features	= IPSET_TYPE_NAME | IPSET_DUMP_LAST,
 	.dimension	= IPSET_DIM_ONE,
-	.family		= AF_UNSPEC,
+	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	.revision_max	= 0,
 	.create		= list_set_create,
-- 
1.7.7.3

