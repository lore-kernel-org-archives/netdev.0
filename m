From: kaber@trash.net
Subject: [PATCH 33/72] netfilter: xtables: resolve indirect macros 2/3
Date: Thu, 21 Oct 2010 17:19:20 +0200
Message-ID: <1287674399-31455-34-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59999 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840Ab0JUPUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:09 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_arp/arp_tables.h  |   15 ++++----
 include/linux/netfilter_ipv4/ip_tables.h  |   18 ++++-----
 include/linux/netfilter_ipv6/ip6_tables.h |   20 +++++------
 net/ipv4/netfilter/arp_tables.c           |   38 ++++++++++----------
 net/ipv4/netfilter/ip_tables.c            |   54 ++++++++++++++--------------
 net/ipv6/netfilter/ip6_tables.c           |   54 ++++++++++++++--------------
 net/sched/act_ipt.c                       |   12 +++---
 7 files changed, 103 insertions(+), 108 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 8193860..7e193c9 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -24,6 +24,8 @@
 #ifndef __KERNEL__
 #define ARPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
 #define ARPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
+#define arpt_entry_target xt_entry_target
+#define arpt_standard_target xt_standard_target
 #endif
 
 #define ARPT_DEV_ADDR_LEN_MAX 16
@@ -65,9 +67,6 @@ struct arpt_arp {
 	u_int16_t invflags;
 };
 
-#define arpt_entry_target xt_entry_target
-#define arpt_standard_target xt_standard_target
-
 /* Values for "flag" field in struct arpt_ip (general arp structure).
  * No flags defined yet.
  */
@@ -208,7 +207,7 @@ struct arpt_get_entries {
 #define ARPT_ERROR_TARGET XT_ERROR_TARGET
 
 /* Helper functions */
-static __inline__ struct arpt_entry_target *arpt_get_target(struct arpt_entry *e)
+static __inline__ struct xt_entry_target *arpt_get_target(struct arpt_entry *e)
 {
 	return (void *)e + e->target_offset;
 }
@@ -227,11 +226,11 @@ static __inline__ struct arpt_entry_target *arpt_get_target(struct arpt_entry *e
 /* Standard entry. */
 struct arpt_standard {
 	struct arpt_entry entry;
-	struct arpt_standard_target target;
+	struct xt_standard_target target;
 };
 
 struct arpt_error_target {
-	struct arpt_entry_target target;
+	struct xt_entry_target target;
 	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
@@ -250,7 +249,7 @@ struct arpt_error {
 {									       \
 	.entry		= ARPT_ENTRY_INIT(sizeof(struct arpt_standard)),       \
 	.target		= XT_TARGET_INIT(ARPT_STANDARD_TARGET,		       \
-					 sizeof(struct arpt_standard_target)), \
+					 sizeof(struct xt_standard_target)), \
 	.target.verdict	= -(__verdict) - 1,				       \
 }
 
@@ -287,7 +286,7 @@ struct compat_arpt_entry {
 	unsigned char elems[0];
 };
 
-static inline struct arpt_entry_target *
+static inline struct xt_entry_target *
 compat_arpt_get_target(struct compat_arpt_entry *e)
 {
 	return (void *)e + e->target_offset;
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 1b7cdf1..ec50691 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -34,6 +34,10 @@
 #define ipt_target xt_target
 #define ipt_table xt_table
 #define ipt_get_revision xt_get_revision
+#define ipt_entry_match xt_entry_match
+#define ipt_entry_target xt_entry_target
+#define ipt_standard_target xt_standard_target
+#define ipt_counters xt_counters
 #endif
 
 /* Yes, Virginia, you have to zero the padding. */
@@ -54,12 +58,6 @@ struct ipt_ip {
 	u_int8_t invflags;
 };
 
-#define ipt_entry_match xt_entry_match
-#define ipt_entry_target xt_entry_target
-#define ipt_standard_target xt_standard_target
-
-#define ipt_counters xt_counters
-
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
 #define IPT_F_FRAG		0x01	/* Set if rule is a fragment rule */
 #define IPT_F_GOTO		0x02	/* Set if jump is a goto */
@@ -219,7 +217,7 @@ struct ipt_get_entries {
 #define IPT_ERROR_TARGET XT_ERROR_TARGET
 
 /* Helper functions */
-static __inline__ struct ipt_entry_target *
+static __inline__ struct xt_entry_target *
 ipt_get_target(struct ipt_entry *e)
 {
 	return (void *)e + e->target_offset;
@@ -251,11 +249,11 @@ extern void ipt_unregister_table(struct net *net, struct xt_table *table);
 /* Standard entry. */
 struct ipt_standard {
 	struct ipt_entry entry;
-	struct ipt_standard_target target;
+	struct xt_standard_target target;
 };
 
 struct ipt_error_target {
-	struct ipt_entry_target target;
+	struct xt_entry_target target;
 	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
@@ -309,7 +307,7 @@ struct compat_ipt_entry {
 };
 
 /* Helper functions */
-static inline struct ipt_entry_target *
+static inline struct xt_entry_target *
 compat_ipt_get_target(struct compat_ipt_entry *e)
 {
 	return (void *)e + e->target_offset;
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index abe31d0..40d11fa 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -34,6 +34,10 @@
 #define ip6t_target xt_target
 #define ip6t_table xt_table
 #define ip6t_get_revision xt_get_revision
+#define ip6t_entry_match xt_entry_match
+#define ip6t_entry_target xt_entry_target
+#define ip6t_standard_target xt_standard_target
+#define ip6t_counters xt_counters
 #endif
 
 /* Yes, Virginia, you have to zero the padding. */
@@ -63,12 +67,6 @@ struct ip6t_ip6 {
 	u_int8_t invflags;
 };
 
-#define ip6t_entry_match xt_entry_match
-#define ip6t_entry_target xt_entry_target
-#define ip6t_standard_target xt_standard_target
-
-#define ip6t_counters	xt_counters
-
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
 #define IP6T_F_PROTO		0x01	/* Set if rule cares about upper 
 					   protocols */
@@ -113,11 +111,11 @@ struct ip6t_entry {
 /* Standard entry */
 struct ip6t_standard {
 	struct ip6t_entry entry;
-	struct ip6t_standard_target target;
+	struct xt_standard_target target;
 };
 
 struct ip6t_error_target {
-	struct ip6t_entry_target target;
+	struct xt_entry_target target;
 	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
@@ -136,7 +134,7 @@ struct ip6t_error {
 {									       \
 	.entry		= IP6T_ENTRY_INIT(sizeof(struct ip6t_standard)),       \
 	.target		= XT_TARGET_INIT(IP6T_STANDARD_TARGET,		       \
-					 sizeof(struct ip6t_standard_target)), \
+					 sizeof(struct xt_standard_target)),   \
 	.target.verdict	= -(__verdict) - 1,				       \
 }
 
@@ -275,7 +273,7 @@ struct ip6t_get_entries {
 #define IP6T_ERROR_TARGET XT_ERROR_TARGET
 
 /* Helper functions */
-static __inline__ struct ip6t_entry_target *
+static __inline__ struct xt_entry_target *
 ip6t_get_target(struct ip6t_entry *e)
 {
 	return (void *)e + e->target_offset;
@@ -332,7 +330,7 @@ struct compat_ip6t_entry {
 	unsigned char elems[0];
 };
 
-static inline struct ip6t_entry_target *
+static inline struct xt_entry_target *
 compat_ip6t_get_target(struct compat_ip6t_entry *e)
 {
 	return (void *)e + e->target_offset;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e427a9e..ed178cb 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -228,7 +228,7 @@ arpt_error(struct sk_buff *skb, const struct xt_action_param *par)
 	return NF_DROP;
 }
 
-static inline const struct arpt_entry_target *
+static inline const struct xt_entry_target *
 arpt_get_target_c(const struct arpt_entry *e)
 {
 	return arpt_get_target((struct arpt_entry *)e);
@@ -282,7 +282,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 
 	arp = arp_hdr(skb);
 	do {
-		const struct arpt_entry_target *t;
+		const struct xt_entry_target *t;
 
 		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
 			e = arpt_next_entry(e);
@@ -297,7 +297,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 		if (!t->u.kernel.target->target) {
 			int v;
 
-			v = ((struct arpt_standard_target *)t)->verdict;
+			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != ARPT_RETURN) {
@@ -377,7 +377,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 		e->counters.pcnt = pos;
 
 		for (;;) {
-			const struct arpt_standard_target *t
+			const struct xt_standard_target *t
 				= (void *)arpt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
@@ -464,14 +464,14 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 
 static inline int check_entry(const struct arpt_entry *e, const char *name)
 {
-	const struct arpt_entry_target *t;
+	const struct xt_entry_target *t;
 
 	if (!arp_checkentry(&e->arp)) {
 		duprintf("arp_tables: arp check failed %p %s.\n", e, name);
 		return -EINVAL;
 	}
 
-	if (e->target_offset + sizeof(struct arpt_entry_target) > e->next_offset)
+	if (e->target_offset + sizeof(struct xt_entry_target) > e->next_offset)
 		return -EINVAL;
 
 	t = arpt_get_target_c(e);
@@ -483,7 +483,7 @@ static inline int check_entry(const struct arpt_entry *e, const char *name)
 
 static inline int check_target(struct arpt_entry *e, const char *name)
 {
-	struct arpt_entry_target *t = arpt_get_target(e);
+	struct xt_entry_target *t = arpt_get_target(e);
 	int ret;
 	struct xt_tgchk_param par = {
 		.table     = name,
@@ -506,7 +506,7 @@ static inline int check_target(struct arpt_entry *e, const char *name)
 static inline int
 find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 {
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	int ret;
 
@@ -536,7 +536,7 @@ out:
 
 static bool check_underflow(const struct arpt_entry *e)
 {
-	const struct arpt_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->arp))
@@ -544,7 +544,7 @@ static bool check_underflow(const struct arpt_entry *e)
 	t = arpt_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
-	verdict = ((struct arpt_standard_target *)t)->verdict;
+	verdict = ((struct xt_standard_target *)t)->verdict;
 	verdict = -verdict - 1;
 	return verdict == NF_DROP || verdict == NF_ACCEPT;
 }
@@ -566,7 +566,7 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 	}
 
 	if (e->next_offset
-	    < sizeof(struct arpt_entry) + sizeof(struct arpt_entry_target)) {
+	    < sizeof(struct arpt_entry) + sizeof(struct xt_entry_target)) {
 		duprintf("checking: element %p size %u\n",
 			 e, e->next_offset);
 		return -EINVAL;
@@ -598,7 +598,7 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 static inline void cleanup_entry(struct arpt_entry *e)
 {
 	struct xt_tgdtor_param par;
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 
 	t = arpt_get_target(e);
 	par.target   = t->u.kernel.target;
@@ -794,7 +794,7 @@ static int copy_entries_to_user(unsigned int total_size,
 	/* FIXME: use iterator macros --RR */
 	/* ... then go back and fix counters and names */
 	for (off = 0, num = 0; off < total_size; off += e->next_offset, num++){
-		const struct arpt_entry_target *t;
+		const struct xt_entry_target *t;
 
 		e = (struct arpt_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
@@ -807,7 +807,7 @@ static int copy_entries_to_user(unsigned int total_size,
 
 		t = arpt_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
-				 + offsetof(struct arpt_entry_target,
+				 + offsetof(struct xt_entry_target,
 					    u.user.name),
 				 t->u.kernel.target->name,
 				 strlen(t->u.kernel.target->name)+1) != 0) {
@@ -844,7 +844,7 @@ static int compat_calc_entry(const struct arpt_entry *e,
 			     const struct xt_table_info *info,
 			     const void *base, struct xt_table_info *newinfo)
 {
-	const struct arpt_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
@@ -1204,7 +1204,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 #ifdef CONFIG_COMPAT
 static inline void compat_release_entry(struct compat_arpt_entry *e)
 {
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 
 	t = compat_arpt_get_target(e);
 	module_put(t->u.kernel.target->me);
@@ -1220,7 +1220,7 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 				  const unsigned int *underflows,
 				  const char *name)
 {
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	unsigned int entry_offset;
 	int ret, off, h;
@@ -1288,7 +1288,7 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 			    unsigned int *size, const char *name,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	struct arpt_entry *de;
 	unsigned int origsize;
@@ -1567,7 +1567,7 @@ static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
 				     struct xt_counters *counters,
 				     unsigned int i)
 {
-	struct arpt_entry_target *t;
+	struct xt_entry_target *t;
 	struct compat_arpt_entry __user *ce;
 	u_int16_t target_offset, next_offset;
 	compat_uint_t origsize;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2efd41b..cb10888 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -186,7 +186,7 @@ static inline bool unconditional(const struct ipt_ip *ip)
 }
 
 /* for const-correctness */
-static inline const struct ipt_entry_target *
+static inline const struct xt_entry_target *
 ipt_get_target_c(const struct ipt_entry *e)
 {
 	return ipt_get_target((struct ipt_entry *)e);
@@ -230,7 +230,7 @@ get_chainname_rulenum(const struct ipt_entry *s, const struct ipt_entry *e,
 		      const char *hookname, const char **chainname,
 		      const char **comment, unsigned int *rulenum)
 {
-	const struct ipt_standard_target *t = (void *)ipt_get_target_c(s);
+	const struct xt_standard_target *t = (void *)ipt_get_target_c(s);
 
 	if (strcmp(t->target.u.kernel.target->name, IPT_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
@@ -346,7 +346,7 @@ ipt_do_table(struct sk_buff *skb,
 		 get_entry(table_base, private->underflow[hook]));
 
 	do {
-		const struct ipt_entry_target *t;
+		const struct xt_entry_target *t;
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
@@ -380,7 +380,7 @@ ipt_do_table(struct sk_buff *skb,
 		if (!t->u.kernel.target->target) {
 			int v;
 
-			v = ((struct ipt_standard_target *)t)->verdict;
+			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != IPT_RETURN) {
@@ -461,7 +461,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 		e->counters.pcnt = pos;
 
 		for (;;) {
-			const struct ipt_standard_target *t
+			const struct xt_standard_target *t
 				= (void *)ipt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
@@ -552,7 +552,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 	return 1;
 }
 
-static void cleanup_match(struct ipt_entry_match *m, struct net *net)
+static void cleanup_match(struct xt_entry_match *m, struct net *net)
 {
 	struct xt_mtdtor_param par;
 
@@ -568,14 +568,14 @@ static void cleanup_match(struct ipt_entry_match *m, struct net *net)
 static int
 check_entry(const struct ipt_entry *e, const char *name)
 {
-	const struct ipt_entry_target *t;
+	const struct xt_entry_target *t;
 
 	if (!ip_checkentry(&e->ip)) {
 		duprintf("ip check failed %p %s.\n", e, par->match->name);
 		return -EINVAL;
 	}
 
-	if (e->target_offset + sizeof(struct ipt_entry_target) >
+	if (e->target_offset + sizeof(struct xt_entry_target) >
 	    e->next_offset)
 		return -EINVAL;
 
@@ -587,7 +587,7 @@ check_entry(const struct ipt_entry *e, const char *name)
 }
 
 static int
-check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
+check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ipt_ip *ip = par->entryinfo;
 	int ret;
@@ -605,7 +605,7 @@ check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 }
 
 static int
-find_check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
+find_check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	struct xt_match *match;
 	int ret;
@@ -630,7 +630,7 @@ err:
 
 static int check_target(struct ipt_entry *e, struct net *net, const char *name)
 {
-	struct ipt_entry_target *t = ipt_get_target(e);
+	struct xt_entry_target *t = ipt_get_target(e);
 	struct xt_tgchk_param par = {
 		.net       = net,
 		.table     = name,
@@ -656,7 +656,7 @@ static int
 find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 		 unsigned int size)
 {
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	int ret;
 	unsigned int j;
@@ -707,7 +707,7 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 
 static bool check_underflow(const struct ipt_entry *e)
 {
-	const struct ipt_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->ip))
@@ -715,7 +715,7 @@ static bool check_underflow(const struct ipt_entry *e)
 	t = ipt_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
-	verdict = ((struct ipt_standard_target *)t)->verdict;
+	verdict = ((struct xt_standard_target *)t)->verdict;
 	verdict = -verdict - 1;
 	return verdict == NF_DROP || verdict == NF_ACCEPT;
 }
@@ -738,7 +738,7 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 	}
 
 	if (e->next_offset
-	    < sizeof(struct ipt_entry) + sizeof(struct ipt_entry_target)) {
+	    < sizeof(struct ipt_entry) + sizeof(struct xt_entry_target)) {
 		duprintf("checking: element %p size %u\n",
 			 e, e->next_offset);
 		return -EINVAL;
@@ -771,7 +771,7 @@ static void
 cleanup_entry(struct ipt_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
@@ -972,8 +972,8 @@ copy_entries_to_user(unsigned int total_size,
 	/* ... then go back and fix counters and names */
 	for (off = 0, num = 0; off < total_size; off += e->next_offset, num++){
 		unsigned int i;
-		const struct ipt_entry_match *m;
-		const struct ipt_entry_target *t;
+		const struct xt_entry_match *m;
+		const struct xt_entry_target *t;
 
 		e = (struct ipt_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
@@ -990,7 +990,7 @@ copy_entries_to_user(unsigned int total_size,
 			m = (void *)e + i;
 
 			if (copy_to_user(userptr + off + i
-					 + offsetof(struct ipt_entry_match,
+					 + offsetof(struct xt_entry_match,
 						    u.user.name),
 					 m->u.kernel.match->name,
 					 strlen(m->u.kernel.match->name)+1)
@@ -1002,7 +1002,7 @@ copy_entries_to_user(unsigned int total_size,
 
 		t = ipt_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
-				 + offsetof(struct ipt_entry_target,
+				 + offsetof(struct xt_entry_target,
 					    u.user.name),
 				 t->u.kernel.target->name,
 				 strlen(t->u.kernel.target->name)+1) != 0) {
@@ -1040,7 +1040,7 @@ static int compat_calc_entry(const struct ipt_entry *e,
 			     const void *base, struct xt_table_info *newinfo)
 {
 	const struct xt_entry_match *ematch;
-	const struct ipt_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
@@ -1407,7 +1407,7 @@ struct compat_ipt_replace {
 	u32			hook_entry[NF_INET_NUMHOOKS];
 	u32			underflow[NF_INET_NUMHOOKS];
 	u32			num_counters;
-	compat_uptr_t		counters;	/* struct ipt_counters * */
+	compat_uptr_t		counters;	/* struct xt_counters * */
 	struct compat_ipt_entry	entries[0];
 };
 
@@ -1416,7 +1416,7 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 			  unsigned int *size, struct xt_counters *counters,
 			  unsigned int i)
 {
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct compat_ipt_entry __user *ce;
 	u_int16_t target_offset, next_offset;
 	compat_uint_t origsize;
@@ -1451,7 +1451,7 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 }
 
 static int
-compat_find_calc_match(struct ipt_entry_match *m,
+compat_find_calc_match(struct xt_entry_match *m,
 		       const char *name,
 		       const struct ipt_ip *ip,
 		       unsigned int hookmask,
@@ -1473,7 +1473,7 @@ compat_find_calc_match(struct ipt_entry_match *m,
 
 static void compat_release_entry(struct compat_ipt_entry *e)
 {
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
@@ -1494,7 +1494,7 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 				  const char *name)
 {
 	struct xt_entry_match *ematch;
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	unsigned int entry_offset;
 	unsigned int j;
@@ -1576,7 +1576,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 			    unsigned int *size, const char *name,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	struct ipt_entry *de;
 	unsigned int origsize;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4b973e1..c7334c1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -215,7 +215,7 @@ static inline bool unconditional(const struct ip6t_ip6 *ipv6)
 	return memcmp(ipv6, &uncond, sizeof(uncond)) == 0;
 }
 
-static inline const struct ip6t_entry_target *
+static inline const struct xt_entry_target *
 ip6t_get_target_c(const struct ip6t_entry *e)
 {
 	return ip6t_get_target((struct ip6t_entry *)e);
@@ -260,7 +260,7 @@ get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 		      const char *hookname, const char **chainname,
 		      const char **comment, unsigned int *rulenum)
 {
-	const struct ip6t_standard_target *t = (void *)ip6t_get_target_c(s);
+	const struct xt_standard_target *t = (void *)ip6t_get_target_c(s);
 
 	if (strcmp(t->target.u.kernel.target->name, IP6T_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
@@ -369,7 +369,7 @@ ip6t_do_table(struct sk_buff *skb,
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	do {
-		const struct ip6t_entry_target *t;
+		const struct xt_entry_target *t;
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
@@ -403,7 +403,7 @@ ip6t_do_table(struct sk_buff *skb,
 		if (!t->u.kernel.target->target) {
 			int v;
 
-			v = ((struct ip6t_standard_target *)t)->verdict;
+			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != IP6T_RETURN) {
@@ -474,7 +474,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 		e->counters.pcnt = pos;
 
 		for (;;) {
-			const struct ip6t_standard_target *t
+			const struct xt_standard_target *t
 				= (void *)ip6t_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
@@ -565,7 +565,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 	return 1;
 }
 
-static void cleanup_match(struct ip6t_entry_match *m, struct net *net)
+static void cleanup_match(struct xt_entry_match *m, struct net *net)
 {
 	struct xt_mtdtor_param par;
 
@@ -581,14 +581,14 @@ static void cleanup_match(struct ip6t_entry_match *m, struct net *net)
 static int
 check_entry(const struct ip6t_entry *e, const char *name)
 {
-	const struct ip6t_entry_target *t;
+	const struct xt_entry_target *t;
 
 	if (!ip6_checkentry(&e->ipv6)) {
 		duprintf("ip_tables: ip check failed %p %s.\n", e, name);
 		return -EINVAL;
 	}
 
-	if (e->target_offset + sizeof(struct ip6t_entry_target) >
+	if (e->target_offset + sizeof(struct xt_entry_target) >
 	    e->next_offset)
 		return -EINVAL;
 
@@ -599,7 +599,7 @@ check_entry(const struct ip6t_entry *e, const char *name)
 	return 0;
 }
 
-static int check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
+static int check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ip6t_ip6 *ipv6 = par->entryinfo;
 	int ret;
@@ -618,7 +618,7 @@ static int check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
 }
 
 static int
-find_check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
+find_check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	struct xt_match *match;
 	int ret;
@@ -643,7 +643,7 @@ err:
 
 static int check_target(struct ip6t_entry *e, struct net *net, const char *name)
 {
-	struct ip6t_entry_target *t = ip6t_get_target(e);
+	struct xt_entry_target *t = ip6t_get_target(e);
 	struct xt_tgchk_param par = {
 		.net       = net,
 		.table     = name,
@@ -670,7 +670,7 @@ static int
 find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 		 unsigned int size)
 {
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	int ret;
 	unsigned int j;
@@ -721,7 +721,7 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 
 static bool check_underflow(const struct ip6t_entry *e)
 {
-	const struct ip6t_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->ipv6))
@@ -729,7 +729,7 @@ static bool check_underflow(const struct ip6t_entry *e)
 	t = ip6t_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
-	verdict = ((struct ip6t_standard_target *)t)->verdict;
+	verdict = ((struct xt_standard_target *)t)->verdict;
 	verdict = -verdict - 1;
 	return verdict == NF_DROP || verdict == NF_ACCEPT;
 }
@@ -752,7 +752,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 	}
 
 	if (e->next_offset
-	    < sizeof(struct ip6t_entry) + sizeof(struct ip6t_entry_target)) {
+	    < sizeof(struct ip6t_entry) + sizeof(struct xt_entry_target)) {
 		duprintf("checking: element %p size %u\n",
 			 e, e->next_offset);
 		return -EINVAL;
@@ -784,7 +784,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
@@ -985,8 +985,8 @@ copy_entries_to_user(unsigned int total_size,
 	/* ... then go back and fix counters and names */
 	for (off = 0, num = 0; off < total_size; off += e->next_offset, num++){
 		unsigned int i;
-		const struct ip6t_entry_match *m;
-		const struct ip6t_entry_target *t;
+		const struct xt_entry_match *m;
+		const struct xt_entry_target *t;
 
 		e = (struct ip6t_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
@@ -1003,7 +1003,7 @@ copy_entries_to_user(unsigned int total_size,
 			m = (void *)e + i;
 
 			if (copy_to_user(userptr + off + i
-					 + offsetof(struct ip6t_entry_match,
+					 + offsetof(struct xt_entry_match,
 						    u.user.name),
 					 m->u.kernel.match->name,
 					 strlen(m->u.kernel.match->name)+1)
@@ -1015,7 +1015,7 @@ copy_entries_to_user(unsigned int total_size,
 
 		t = ip6t_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
-				 + offsetof(struct ip6t_entry_target,
+				 + offsetof(struct xt_entry_target,
 					    u.user.name),
 				 t->u.kernel.target->name,
 				 strlen(t->u.kernel.target->name)+1) != 0) {
@@ -1053,7 +1053,7 @@ static int compat_calc_entry(const struct ip6t_entry *e,
 			     const void *base, struct xt_table_info *newinfo)
 {
 	const struct xt_entry_match *ematch;
-	const struct ip6t_entry_target *t;
+	const struct xt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
@@ -1422,7 +1422,7 @@ struct compat_ip6t_replace {
 	u32			hook_entry[NF_INET_NUMHOOKS];
 	u32			underflow[NF_INET_NUMHOOKS];
 	u32			num_counters;
-	compat_uptr_t		counters;	/* struct ip6t_counters * */
+	compat_uptr_t		counters;	/* struct xt_counters * */
 	struct compat_ip6t_entry entries[0];
 };
 
@@ -1431,7 +1431,7 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 			  unsigned int *size, struct xt_counters *counters,
 			  unsigned int i)
 {
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct compat_ip6t_entry __user *ce;
 	u_int16_t target_offset, next_offset;
 	compat_uint_t origsize;
@@ -1466,7 +1466,7 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 }
 
 static int
-compat_find_calc_match(struct ip6t_entry_match *m,
+compat_find_calc_match(struct xt_entry_match *m,
 		       const char *name,
 		       const struct ip6t_ip6 *ipv6,
 		       unsigned int hookmask,
@@ -1488,7 +1488,7 @@ compat_find_calc_match(struct ip6t_entry_match *m,
 
 static void compat_release_entry(struct compat_ip6t_entry *e)
 {
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
@@ -1509,7 +1509,7 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 				  const char *name)
 {
 	struct xt_entry_match *ematch;
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	unsigned int entry_offset;
 	unsigned int j;
@@ -1591,7 +1591,7 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 			    unsigned int *size, const char *name,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
-	struct ip6t_entry_target *t;
+	struct xt_entry_target *t;
 	struct xt_target *target;
 	struct ip6t_entry *de;
 	unsigned int origsize;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index c7e59e6..f6d464f 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -39,7 +39,7 @@ static struct tcf_hashinfo ipt_hash_info = {
 	.lock	=	&ipt_lock,
 };
 
-static int ipt_init_target(struct ipt_entry_target *t, char *table, unsigned int hook)
+static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
 {
 	struct xt_tgchk_param par;
 	struct xt_target *target;
@@ -66,7 +66,7 @@ static int ipt_init_target(struct ipt_entry_target *t, char *table, unsigned int
 	return 0;
 }
 
-static void ipt_destroy_target(struct ipt_entry_target *t)
+static void ipt_destroy_target(struct xt_entry_target *t)
 {
 	struct xt_tgdtor_param par = {
 		.target   = t->u.kernel.target,
@@ -99,7 +99,7 @@ static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
 	[TCA_IPT_TABLE]	= { .type = NLA_STRING, .len = IFNAMSIZ },
 	[TCA_IPT_HOOK]	= { .type = NLA_U32 },
 	[TCA_IPT_INDEX]	= { .type = NLA_U32 },
-	[TCA_IPT_TARG]	= { .len = sizeof(struct ipt_entry_target) },
+	[TCA_IPT_TARG]	= { .len = sizeof(struct xt_entry_target) },
 };
 
 static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
@@ -108,7 +108,7 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	struct nlattr *tb[TCA_IPT_MAX + 1];
 	struct tcf_ipt *ipt;
 	struct tcf_common *pc;
-	struct ipt_entry_target *td, *t;
+	struct xt_entry_target *td, *t;
 	char *tname;
 	int ret = 0, err;
 	u32 hook = 0;
@@ -126,7 +126,7 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	if (tb[TCA_IPT_TARG] == NULL)
 		return -EINVAL;
 
-	td = (struct ipt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
+	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
 	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
 		return -EINVAL;
 
@@ -249,7 +249,7 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_ipt *ipt = a->priv;
-	struct ipt_entry_target *t;
+	struct xt_entry_target *t;
 	struct tcf_t tm;
 	struct tc_cnt c;
 
-- 
1.7.1

