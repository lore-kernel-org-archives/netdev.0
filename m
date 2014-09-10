From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/5] netfilter: Convert pr_warning to pr_warn
Date: Tue,  9 Sep 2014 21:17:32 -0700
Message-ID: <4708b4ef0485c1bc9efe3c0e59924a0f1c3c3bb4.1410322181.git.joe@perches.com>
References: <cover.1410322181.git.joe@perches.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410322181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common pr_warn.

Other miscellanea:

o Coalesce formats
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/ipset/ip_set_core.c     | 23 +++++++++++-----------
 net/netfilter/ipset/ip_set_hash_gen.h | 12 ++++++------
 net/netfilter/xt_connbytes.c          |  2 +-
 net/netfilter/xt_hashlimit.c          |  2 +-
 net/netfilter/xt_set.c                | 36 ++++++++++++++++-------------------
 5 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 5edbbe8..ac31bf8 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -101,7 +101,7 @@ load_settype(const char *name)
 	nfnl_unlock(NFNL_SUBSYS_IPSET);
 	pr_debug("try to load ip_set_%s\n", name);
 	if (request_module("ip_set_%s", name) < 0) {
-		pr_warning("Can't find ip_set type %s\n", name);
+		pr_warn("Can't find ip_set type %s\n", name);
 		nfnl_lock(NFNL_SUBSYS_IPSET);
 		return false;
 	}
@@ -195,20 +195,19 @@ ip_set_type_register(struct ip_set_type *type)
 	int ret = 0;
 
 	if (type->protocol != IPSET_PROTOCOL) {
-		pr_warning("ip_set type %s, family %s, revision %u:%u uses "
-			   "wrong protocol version %u (want %u)\n",
-			   type->name, family_name(type->family),
-			   type->revision_min, type->revision_max,
-			   type->protocol, IPSET_PROTOCOL);
+		pr_warn("ip_set type %s, family %s, revision %u:%u uses wrong protocol version %u (want %u)\n",
+			type->name, family_name(type->family),
+			type->revision_min, type->revision_max,
+			type->protocol, IPSET_PROTOCOL);
 		return -EINVAL;
 	}
 
 	ip_set_type_lock();
 	if (find_set_type(type->name, type->family, type->revision_min)) {
 		/* Duplicate! */
-		pr_warning("ip_set type %s, family %s with revision min %u "
-			   "already registered!\n", type->name,
-			   family_name(type->family), type->revision_min);
+		pr_warn("ip_set type %s, family %s with revision min %u already registered!\n",
+			type->name, family_name(type->family),
+			type->revision_min);
 		ret = -EINVAL;
 		goto unlock;
 	}
@@ -228,9 +227,9 @@ ip_set_type_unregister(struct ip_set_type *type)
 {
 	ip_set_type_lock();
 	if (!find_set_type(type->name, type->family, type->revision_min)) {
-		pr_warning("ip_set type %s, family %s with revision min %u "
-			   "not registered\n", type->name,
-			   family_name(type->family), type->revision_min);
+		pr_warn("ip_set type %s, family %s with revision min %u not registered\n",
+			type->name, family_name(type->family),
+			type->revision_min);
 		goto unlock;
 	}
 	list_del_rcu(&type->list);
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 61c7fb0..80f49df 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -565,8 +565,8 @@ retry:
 		 set->name, orig->htable_bits, htable_bits, orig);
 	if (!htable_bits) {
 		/* In case we have plenty of memory :-) */
-		pr_warning("Cannot increase the hashsize of set %s further\n",
-			   set->name);
+		pr_warn("Cannot increase the hashsize of set %s further\n",
+			set->name);
 		return -IPSET_ERR_HASH_FULL;
 	}
 	t = ip_set_alloc(sizeof(*t)
@@ -651,8 +651,8 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (h->elements >= h->maxelem) {
 		if (net_ratelimit())
-			pr_warning("Set %s is full, maxelem %u reached\n",
-				   set->name, h->maxelem);
+			pr_warn("Set %s is full, maxelem %u reached\n",
+				set->name, h->maxelem);
 		return -IPSET_ERR_HASH_FULL;
 	}
 
@@ -998,8 +998,8 @@ mtype_list(const struct ip_set *set,
 nla_put_failure:
 	nlmsg_trim(skb, incomplete);
 	if (unlikely(first == cb->args[IPSET_CB_ARG0])) {
-		pr_warning("Can't list set %s: one bucket does not fit into "
-			   "a message. Please report it!\n", set->name);
+		pr_warn("Can't list set %s: one bucket does not fit into a message. Please report it!\n",
+			set->name);
 		cb->args[IPSET_CB_ARG0] = 0;
 		return -EMSGSIZE;
 	}
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 1e63461..d4bec26 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -120,7 +120,7 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 	 * accounting is enabled, so complain in the hope that someone notices.
 	 */
 	if (!nf_ct_acct_enabled(par->net)) {
-		pr_warning("Forcing CT accounting to be enabled\n");
+		pr_warn("Forcing CT accounting to be enabled\n");
 		nf_ct_set_acct(par->net, true);
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 52eb3e03..05fbc2a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -943,7 +943,7 @@ static int __init hashlimit_mt_init(void)
 					    sizeof(struct dsthash_ent), 0, 0,
 					    NULL);
 	if (!hashlimit_cachep) {
-		pr_warning("unable to create slab cache\n");
+		pr_warn("unable to create slab cache\n");
 		goto err2;
 	}
 	return 0;
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 80c2e2d..cb70f6e 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -84,13 +84,12 @@ set_match_v0_checkentry(const struct xt_mtchk_param *par)
 	index = ip_set_nfnl_get_byindex(par->net, info->match_set.index);
 
 	if (index == IPSET_INVALID_ID) {
-		pr_warning("Cannot find set identified by id %u to match\n",
-			   info->match_set.index);
+		pr_warn("Cannot find set identified by id %u to match\n",
+			info->match_set.index);
 		return -ENOENT;
 	}
 	if (info->match_set.u.flags[IPSET_DIM_MAX-1] != 0) {
-		pr_warning("Protocol error: set match dimension "
-			   "is over the limit!\n");
+		pr_warn("Protocol error: set match dimension is over the limit!\n");
 		ip_set_nfnl_put(par->net, info->match_set.index);
 		return -ERANGE;
 	}
@@ -134,13 +133,12 @@ set_match_v1_checkentry(const struct xt_mtchk_param *par)
 	index = ip_set_nfnl_get_byindex(par->net, info->match_set.index);
 
 	if (index == IPSET_INVALID_ID) {
-		pr_warning("Cannot find set identified by id %u to match\n",
-			   info->match_set.index);
+		pr_warn("Cannot find set identified by id %u to match\n",
+			info->match_set.index);
 		return -ENOENT;
 	}
 	if (info->match_set.dim > IPSET_DIM_MAX) {
-		pr_warning("Protocol error: set match dimension "
-			   "is over the limit!\n");
+		pr_warn("Protocol error: set match dimension is over the limit!\n");
 		ip_set_nfnl_put(par->net, info->match_set.index);
 		return -ERANGE;
 	}
@@ -230,8 +228,8 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	if (info->add_set.index != IPSET_INVALID_ID) {
 		index = ip_set_nfnl_get_byindex(par->net, info->add_set.index);
 		if (index == IPSET_INVALID_ID) {
-			pr_warning("Cannot find add_set index %u as target\n",
-				   info->add_set.index);
+			pr_warn("Cannot find add_set index %u as target\n",
+				info->add_set.index);
 			return -ENOENT;
 		}
 	}
@@ -239,8 +237,8 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	if (info->del_set.index != IPSET_INVALID_ID) {
 		index = ip_set_nfnl_get_byindex(par->net, info->del_set.index);
 		if (index == IPSET_INVALID_ID) {
-			pr_warning("Cannot find del_set index %u as target\n",
-				   info->del_set.index);
+			pr_warn("Cannot find del_set index %u as target\n",
+				info->del_set.index);
 			if (info->add_set.index != IPSET_INVALID_ID)
 				ip_set_nfnl_put(par->net, info->add_set.index);
 			return -ENOENT;
@@ -248,8 +246,7 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	}
 	if (info->add_set.u.flags[IPSET_DIM_MAX-1] != 0 ||
 	    info->del_set.u.flags[IPSET_DIM_MAX-1] != 0) {
-		pr_warning("Protocol error: SET target dimension "
-			   "is over the limit!\n");
+		pr_warn("Protocol error: SET target dimension is over the limit!\n");
 		if (info->add_set.index != IPSET_INVALID_ID)
 			ip_set_nfnl_put(par->net, info->add_set.index);
 		if (info->del_set.index != IPSET_INVALID_ID)
@@ -303,8 +300,8 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 	if (info->add_set.index != IPSET_INVALID_ID) {
 		index = ip_set_nfnl_get_byindex(par->net, info->add_set.index);
 		if (index == IPSET_INVALID_ID) {
-			pr_warning("Cannot find add_set index %u as target\n",
-				   info->add_set.index);
+			pr_warn("Cannot find add_set index %u as target\n",
+				info->add_set.index);
 			return -ENOENT;
 		}
 	}
@@ -312,8 +309,8 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 	if (info->del_set.index != IPSET_INVALID_ID) {
 		index = ip_set_nfnl_get_byindex(par->net, info->del_set.index);
 		if (index == IPSET_INVALID_ID) {
-			pr_warning("Cannot find del_set index %u as target\n",
-				   info->del_set.index);
+			pr_warn("Cannot find del_set index %u as target\n",
+				info->del_set.index);
 			if (info->add_set.index != IPSET_INVALID_ID)
 				ip_set_nfnl_put(par->net, info->add_set.index);
 			return -ENOENT;
@@ -321,8 +318,7 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 	}
 	if (info->add_set.dim > IPSET_DIM_MAX ||
 	    info->del_set.dim > IPSET_DIM_MAX) {
-		pr_warning("Protocol error: SET target dimension "
-			   "is over the limit!\n");
+		pr_warn("Protocol error: SET target dimension is over the limit!\n");
 		if (info->add_set.index != IPSET_INVALID_ID)
 			ip_set_nfnl_put(par->net, info->add_set.index);
 		if (info->del_set.index != IPSET_INVALID_ID)
-- 
1.8.1.2.459.gbcd45b4.dirty
