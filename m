From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/21] netfilter: ipset: Give a better name to a macro in ip_set_core.c
Date: Mon, 18 May 2015 18:25:05 +0200
Message-ID: <1431966324-4494-3-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index d259da3..ed05f1e 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -42,7 +42,7 @@ static inline struct ip_set_net *ip_set_pernet(struct net *net)
 }
 
 #define IP_SET_INC	64
-#define STREQ(a, b)	(strncmp(a, b, IPSET_MAXNAMELEN) == 0)
+#define STRNCMP(a, b)	(strncmp(a, b, IPSET_MAXNAMELEN) == 0)
 
 static unsigned int max_sets;
 
@@ -85,7 +85,7 @@ find_set_type(const char *name, u8 family, u8 revision)
 	struct ip_set_type *type;
 
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
-		if (STREQ(type->name, name) &&
+		if (STRNCMP(type->name, name) &&
 		    (type->family == family ||
 		     type->family == NFPROTO_UNSPEC) &&
 		    revision >= type->revision_min &&
@@ -132,7 +132,7 @@ __find_set_type_get(const char *name, u8 family, u8 revision,
 	/* Make sure the type is already loaded
 	 * but we don't support the revision */
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
-		if (STREQ(type->name, name)) {
+		if (STRNCMP(type->name, name)) {
 			err = -IPSET_ERR_FIND_TYPE;
 			goto unlock;
 		}
@@ -166,7 +166,7 @@ __find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max,
 	*min = 255; *max = 0;
 	rcu_read_lock();
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
-		if (STREQ(type->name, name) &&
+		if (STRNCMP(type->name, name) &&
 		    (type->family == family ||
 		     type->family == NFPROTO_UNSPEC)) {
 			found = true;
@@ -581,7 +581,7 @@ ip_set_get_byname(struct net *net, const char *name, struct ip_set **set)
 	rcu_read_lock();
 	for (i = 0; i < inst->ip_set_max; i++) {
 		s = rcu_dereference(inst->ip_set_list)[i];
-		if (s != NULL && STREQ(s->name, name)) {
+		if (s != NULL && STRNCMP(s->name, name)) {
 			__ip_set_get(s);
 			index = i;
 			*set = s;
@@ -758,7 +758,7 @@ find_set_and_id(struct ip_set_net *inst, const char *name, ip_set_id_t *id)
 	*id = IPSET_INVALID_ID;
 	for (i = 0; i < inst->ip_set_max; i++) {
 		set = ip_set(inst, i);
-		if (set != NULL && STREQ(set->name, name)) {
+		if (set != NULL && STRNCMP(set->name, name)) {
 			*id = i;
 			break;
 		}
@@ -787,7 +787,7 @@ find_free_id(struct ip_set_net *inst, const char *name, ip_set_id_t *index,
 		if (s == NULL) {
 			if (*index == IPSET_INVALID_ID)
 				*index = i;
-		} else if (STREQ(name, s->name)) {
+		} else if (STRNCMP(name, s->name)) {
 			/* Name clash */
 			*set = s;
 			return -EEXIST;
@@ -887,7 +887,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	if (ret == -EEXIST) {
 		/* If this is the same set and requested, ignore error */
 		if ((flags & IPSET_FLAG_EXIST) &&
-		    STREQ(set->type->name, clash->type->name) &&
+		    STRNCMP(set->type->name, clash->type->name) &&
 		    set->type->family == clash->type->family &&
 		    set->type->revision_min == clash->type->revision_min &&
 		    set->type->revision_max == clash->type->revision_max &&
@@ -1098,7 +1098,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
 	for (i = 0; i < inst->ip_set_max; i++) {
 		s = ip_set(inst, i);
-		if (s != NULL && STREQ(s->name, name2)) {
+		if (s != NULL && STRNCMP(s->name, name2)) {
 			ret = -IPSET_ERR_EXIST_SETNAME2;
 			goto out;
 		}
-- 
1.7.10.4

