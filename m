From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 56/62: xtables: add const qualifiers
Date: Tue, 16 Feb 2010 15:56:35 +0100 (MET)
Message-ID: <20100216145633.2796.45790.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d5d1baa15f5b05e9110403724d5dc72d6d541e04
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 26 07:51:59 2009 +0200

    netfilter: xtables: add const qualifiers
    
    This should make it easier to remove redundant arguments later.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 208f4e3..bcdf02d 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -82,7 +82,8 @@ static inline int ebt_do_match (struct ebt_entry_match *m,
 	return m->u.match->match(skb, par) ? EBT_MATCH : EBT_NOMATCH;
 }
 
-static inline int ebt_dev_check(char *entry, const struct net_device *device)
+static inline int
+ebt_dev_check(const char *entry, const struct net_device *device)
 {
 	int i = 0;
 	const char *devname;
@@ -100,8 +101,9 @@ static inline int ebt_dev_check(char *entry, const struct net_device *device)
 
 #define FWINV2(bool,invflg) ((bool) ^ !!(e->invflags & invflg))
 /* process standard matches */
-static inline int ebt_basic_match(struct ebt_entry *e, struct ethhdr *h,
-   const struct net_device *in, const struct net_device *out)
+static inline int
+ebt_basic_match(const struct ebt_entry *e, const struct ethhdr *h,
+                const struct net_device *in, const struct net_device *out)
 {
 	int verdict, i;
 
@@ -156,12 +158,12 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	int i, nentries;
 	struct ebt_entry *point;
 	struct ebt_counter *counter_base, *cb_base;
-	struct ebt_entry_target *t;
+	const struct ebt_entry_target *t;
 	int verdict, sp = 0;
 	struct ebt_chainstack *cs;
 	struct ebt_entries *chaininfo;
-	char *base;
-	struct ebt_table_info *private;
+	const char *base;
+	const struct ebt_table_info *private;
 	bool hotdrop = false;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
@@ -395,7 +397,7 @@ ebt_check_watcher(struct ebt_entry_watcher *w, struct xt_tgchk_param *par,
 	return 0;
 }
 
-static int ebt_verify_pointers(struct ebt_replace *repl,
+static int ebt_verify_pointers(const struct ebt_replace *repl,
 			       struct ebt_table_info *newinfo)
 {
 	unsigned int limit = repl->entries_size;
@@ -466,8 +468,8 @@ static int ebt_verify_pointers(struct ebt_replace *repl,
  * to parse the userspace data
  */
 static inline int
-ebt_check_entry_size_and_hooks(struct ebt_entry *e,
-   struct ebt_table_info *newinfo,
+ebt_check_entry_size_and_hooks(const struct ebt_entry *e,
+   const struct ebt_table_info *newinfo,
    unsigned int *n, unsigned int *cnt,
    unsigned int *totalcnt, unsigned int *udc_cnt)
 {
@@ -622,9 +624,8 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 }
 
 static inline int
-ebt_check_entry(struct ebt_entry *e,
-   struct net *net,
-   struct ebt_table_info *newinfo,
+ebt_check_entry(struct ebt_entry *e, struct net *net,
+   const struct ebt_table_info *newinfo,
    const char *name, unsigned int *cnt,
    struct ebt_cl_stack *cl_s, unsigned int udc_cnt)
 {
@@ -743,12 +744,12 @@ cleanup_matches:
  * the hook mask for udc tells us from which base chains the udc can be
  * accessed. This mask is a parameter to the check() functions of the extensions
  */
-static int check_chainloops(struct ebt_entries *chain, struct ebt_cl_stack *cl_s,
+static int check_chainloops(const struct ebt_entries *chain, struct ebt_cl_stack *cl_s,
    unsigned int udc_cnt, unsigned int hooknr, char *base)
 {
 	int i, chain_nr = -1, pos = 0, nentries = chain->nentries, verdict;
-	struct ebt_entry *e = (struct ebt_entry *)chain->data;
-	struct ebt_entry_target *t;
+	const struct ebt_entry *e = (struct ebt_entry *)chain->data;
+	const struct ebt_entry_target *t;
 
 	while (pos < nentries || chain_nr != -1) {
 		/* end of udc, go back one 'recursion' step */
@@ -814,7 +815,7 @@ letscontinue:
 }
 
 /* do the parsing of the table/chains/entries/matches/watchers/targets, heh */
-static int translate_table(struct net *net, char *name,
+static int translate_table(struct net *net, const char *name,
 			   struct ebt_table_info *newinfo)
 {
 	unsigned int i, j, k, udc_cnt;
@@ -934,7 +935,7 @@ static int translate_table(struct net *net, char *name,
 }
 
 /* called under write_lock */
-static void get_counters(struct ebt_counter *oldcounters,
+static void get_counters(const struct ebt_counter *oldcounters,
    struct ebt_counter *counters, unsigned int nentries)
 {
 	int i, cpu;
@@ -957,7 +958,8 @@ static void get_counters(struct ebt_counter *oldcounters,
 }
 
 /* replace the table */
-static int do_replace(struct net *net, void __user *user, unsigned int len)
+static int do_replace(struct net *net, const void __user *user,
+		      unsigned int len)
 {
 	int ret, i, countersize;
 	struct ebt_table_info *newinfo;
@@ -1237,7 +1239,8 @@ void ebt_unregister_table(struct net *net, struct ebt_table *table)
 }
 
 /* userspace just supplied us with counters */
-static int update_counters(struct net *net, void __user *user, unsigned int len)
+static int update_counters(struct net *net, const void __user *user,
+			   unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1292,8 +1295,8 @@ free_tmp:
 	return ret;
 }
 
-static inline int ebt_make_matchname(struct ebt_entry_match *m,
-   char *base, char __user *ubase)
+static inline int ebt_make_matchname(const struct ebt_entry_match *m,
+    const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)m - base);
 	if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNAMELEN))
@@ -1301,8 +1304,8 @@ static inline int ebt_make_matchname(struct ebt_entry_match *m,
 	return 0;
 }
 
-static inline int ebt_make_watchername(struct ebt_entry_watcher *w,
-   char *base, char __user *ubase)
+static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
+    const char *base, char __user *ubase)
 {
 	char __user *hlp = ubase + ((char *)w - base);
 	if (copy_to_user(hlp , w->u.watcher->name, EBT_FUNCTION_MAXNAMELEN))
@@ -1310,11 +1313,12 @@ static inline int ebt_make_watchername(struct ebt_entry_watcher *w,
 	return 0;
 }
 
-static inline int ebt_make_names(struct ebt_entry *e, char *base, char __user *ubase)
+static inline int
+ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 {
 	int ret;
 	char __user *hlp;
-	struct ebt_entry_target *t;
+	const struct ebt_entry_target *t;
 
 	if (e->bitmask == 0)
 		return 0;
@@ -1335,10 +1339,11 @@ static inline int ebt_make_names(struct ebt_entry *e, char *base, char __user *u
 
 /* called with ebt_mutex locked */
 static int copy_everything_to_user(struct ebt_table *t, void __user *user,
-   int *len, int cmd)
+    const int *len, int cmd)
 {
 	struct ebt_replace tmp;
-	struct ebt_counter *counterstmp, *oldcounters;
+	struct ebt_counter *counterstmp;
+	const struct ebt_counter *oldcounters;
 	unsigned int entries_size, nentries;
 	char *entries;
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2303dc9..4db5c1e 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -233,7 +233,14 @@ arpt_error(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-static inline struct arpt_entry *get_entry(void *base, unsigned int offset)
+static inline const struct arpt_entry_target *
+arpt_get_target_c(const struct arpt_entry *e)
+{
+	return arpt_get_target((struct arpt_entry *)e);
+}
+
+static inline struct arpt_entry *
+get_entry(const void *base, unsigned int offset)
 {
 	return (struct arpt_entry *)(base + offset);
 }
@@ -280,7 +287,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 
 	arp = arp_hdr(skb);
 	do {
-		struct arpt_entry_target *t;
+		const struct arpt_entry_target *t;
 		int hdr_len;
 
 		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
@@ -292,7 +299,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			(2 * skb->dev->addr_len);
 		ADD_COUNTER(e->counters, hdr_len, 1);
 
-		t = arpt_get_target(e);
+		t = arpt_get_target_c(e);
 
 		/* Standard target? */
 		if (!t->u.kernel.target->target) {
@@ -358,7 +365,7 @@ static inline bool unconditional(const struct arpt_arp *arp)
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
  */
-static int mark_source_chains(struct xt_table_info *newinfo,
+static int mark_source_chains(const struct xt_table_info *newinfo,
 			      unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -379,7 +386,7 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 
 		for (;;) {
 			const struct arpt_standard_target *t
-				= (void *)arpt_get_target(e);
+				= (void *)arpt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_ARP_NUMHOOKS)) {
@@ -463,7 +470,7 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 	return 1;
 }
 
-static inline int check_entry(struct arpt_entry *e, const char *name)
+static inline int check_entry(const struct arpt_entry *e, const char *name)
 {
 	const struct arpt_entry_target *t;
 
@@ -475,7 +482,7 @@ static inline int check_entry(struct arpt_entry *e, const char *name)
 	if (e->target_offset + sizeof(struct arpt_entry_target) > e->next_offset)
 		return -EINVAL;
 
-	t = arpt_get_target(e);
+	t = arpt_get_target_c(e);
 	if (e->target_offset + t->u.target_size > e->next_offset)
 		return -EINVAL;
 
@@ -540,14 +547,14 @@ out:
 	return ret;
 }
 
-static bool check_underflow(struct arpt_entry *e)
+static bool check_underflow(const struct arpt_entry *e)
 {
 	const struct arpt_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->arp))
 		return false;
-	t = arpt_get_target(e);
+	t = arpt_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
 	verdict = ((struct arpt_standard_target *)t)->verdict;
@@ -557,8 +564,8 @@ static bool check_underflow(struct arpt_entry *e)
 
 static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 					     struct xt_table_info *newinfo,
-					     unsigned char *base,
-					     unsigned char *limit,
+					     const unsigned char *base,
+					     const unsigned char *limit,
 					     const unsigned int *hook_entries,
 					     const unsigned int *underflows,
 					     unsigned int valid_hooks,
@@ -768,11 +775,11 @@ static void get_counters(const struct xt_table_info *t,
 	local_bh_enable();
 }
 
-static struct xt_counters *alloc_counters(struct xt_table *table)
+static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	struct xt_table_info *private = table->private;
+	const struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -790,11 +797,11 @@ static struct xt_counters *alloc_counters(struct xt_table *table)
 }
 
 static int copy_entries_to_user(unsigned int total_size,
-				struct xt_table *table,
+				const struct xt_table *table,
 				void __user *userptr)
 {
 	unsigned int off, num;
-	struct arpt_entry *e;
+	const struct arpt_entry *e;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
 	int ret = 0;
@@ -814,7 +821,7 @@ static int copy_entries_to_user(unsigned int total_size,
 	/* FIXME: use iterator macros --RR */
 	/* ... then go back and fix counters and names */
 	for (off = 0, num = 0; off < total_size; off += e->next_offset, num++){
-		struct arpt_entry_target *t;
+		const struct arpt_entry_target *t;
 
 		e = (struct arpt_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
@@ -825,7 +832,7 @@ static int copy_entries_to_user(unsigned int total_size,
 			goto free_counters;
 		}
 
-		t = arpt_get_target(e);
+		t = arpt_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
 				 + offsetof(struct arpt_entry_target,
 					    u.user.name),
@@ -860,18 +867,18 @@ static int compat_standard_to_user(void __user *dst, const void *src)
 	return copy_to_user(dst, &cv, sizeof(cv)) ? -EFAULT : 0;
 }
 
-static int compat_calc_entry(struct arpt_entry *e,
+static int compat_calc_entry(const struct arpt_entry *e,
 			     const struct xt_table_info *info,
-			     void *base, struct xt_table_info *newinfo)
+			     const void *base, struct xt_table_info *newinfo)
 {
-	struct arpt_entry_target *t;
+	const struct arpt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
 	off = sizeof(struct arpt_entry) - sizeof(struct compat_arpt_entry);
 	entry_offset = (void *)e - base;
 
-	t = arpt_get_target(e);
+	t = arpt_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
 	ret = xt_compat_add_offset(NFPROTO_ARP, entry_offset, off);
@@ -907,7 +914,8 @@ static int compat_table_info(const struct xt_table_info *info,
 }
 #endif
 
-static int get_info(struct net *net, void __user *user, int *len, int compat)
+static int get_info(struct net *net, void __user *user,
+                    const int *len, int compat)
 {
 	char name[ARPT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -966,7 +974,7 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 }
 
 static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
-		       int *len)
+		       const int *len)
 {
 	int ret;
 	struct arpt_get_entries get;
@@ -1080,7 +1088,8 @@ static int __do_replace(struct net *net, const char *name,
 	return ret;
 }
 
-static int do_replace(struct net *net, void __user *user, unsigned int len)
+static int do_replace(struct net *net, const void __user *user,
+                      unsigned int len)
 {
 	int ret;
 	struct arpt_replace tmp;
@@ -1140,8 +1149,8 @@ add_counter_to_entry(struct arpt_entry *e,
 	return 0;
 }
 
-static int do_add_counters(struct net *net, void __user *user, unsigned int len,
-			   int compat)
+static int do_add_counters(struct net *net, const void __user *user,
+			   unsigned int len, int compat)
 {
 	unsigned int i, curcpu;
 	struct xt_counters_info tmp;
@@ -1245,10 +1254,10 @@ static inline int
 check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 				  struct xt_table_info *newinfo,
 				  unsigned int *size,
-				  unsigned char *base,
-				  unsigned char *limit,
-				  unsigned int *hook_entries,
-				  unsigned int *underflows,
+				  const unsigned char *base,
+				  const unsigned char *limit,
+				  const unsigned int *hook_entries,
+				  const unsigned int *underflows,
 				  unsigned int *i,
 				  const char *name)
 {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2a4f745..e94c18b 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -176,7 +176,7 @@ ipt_error(struct sk_buff *skb, const struct xt_target_param *par)
 
 /* Performance critical - called for every packet */
 static inline bool
-do_match(struct ipt_entry_match *m, const struct sk_buff *skb,
+do_match(const struct ipt_entry_match *m, const struct sk_buff *skb,
 	 struct xt_match_param *par)
 {
 	par->match     = m->u.kernel.match;
@@ -191,7 +191,7 @@ do_match(struct ipt_entry_match *m, const struct sk_buff *skb,
 
 /* Performance critical */
 static inline struct ipt_entry *
-get_entry(void *base, unsigned int offset)
+get_entry(const void *base, unsigned int offset)
 {
 	return (struct ipt_entry *)(base + offset);
 }
@@ -206,6 +206,13 @@ static inline bool unconditional(const struct ipt_ip *ip)
 #undef FWINV
 }
 
+/* for const-correctness */
+static inline const struct ipt_entry_target *
+ipt_get_target_c(const struct ipt_entry *e)
+{
+	return ipt_get_target((struct ipt_entry *)e);
+}
+
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 static const char *const hooknames[] = {
@@ -240,11 +247,11 @@ static struct nf_loginfo trace_loginfo = {
 
 /* Mildly perf critical (only if packet tracing is on) */
 static inline int
-get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
+get_chainname_rulenum(const struct ipt_entry *s, const struct ipt_entry *e,
 		      const char *hookname, const char **chainname,
 		      const char **comment, unsigned int *rulenum)
 {
-	struct ipt_standard_target *t = (void *)ipt_get_target(s);
+	const struct ipt_standard_target *t = (void *)ipt_get_target_c(s);
 
 	if (strcmp(t->target.u.kernel.target->name, IPT_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
@@ -270,15 +277,15 @@ get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
 	return 0;
 }
 
-static void trace_packet(struct sk_buff *skb,
+static void trace_packet(const struct sk_buff *skb,
 			 unsigned int hook,
 			 const struct net_device *in,
 			 const struct net_device *out,
 			 const char *tablename,
-			 struct xt_table_info *private,
-			 struct ipt_entry *e)
+			 const struct xt_table_info *private,
+			 const struct ipt_entry *e)
 {
-	void *table_base;
+	const void *table_base;
 	const struct ipt_entry *root;
 	const char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
@@ -322,9 +329,9 @@ ipt_do_table(struct sk_buff *skb,
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
-	void *table_base;
+	const void *table_base;
 	struct ipt_entry *e, *back;
-	struct xt_table_info *private;
+	const struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
 
@@ -357,7 +364,7 @@ ipt_do_table(struct sk_buff *skb,
 	back = get_entry(table_base, private->underflow[hook]);
 
 	do {
-		struct ipt_entry_target *t;
+		const struct ipt_entry_target *t;
 
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
@@ -450,7 +457,7 @@ ipt_do_table(struct sk_buff *skb,
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct xt_table_info *newinfo,
+mark_source_chains(const struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -468,8 +475,8 @@ mark_source_chains(struct xt_table_info *newinfo,
 		e->counters.pcnt = pos;
 
 		for (;;) {
-			struct ipt_standard_target *t
-				= (void *)ipt_get_target(e);
+			const struct ipt_standard_target *t
+				= (void *)ipt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
@@ -578,9 +585,9 @@ cleanup_match(struct ipt_entry_match *m, struct net *net, unsigned int *i)
 }
 
 static int
-check_entry(struct ipt_entry *e, const char *name)
+check_entry(const struct ipt_entry *e, const char *name)
 {
-	struct ipt_entry_target *t;
+	const struct ipt_entry_target *t;
 
 	if (!ip_checkentry(&e->ip)) {
 		duprintf("ip_tables: ip check failed %p %s.\n", e, name);
@@ -591,7 +598,7 @@ check_entry(struct ipt_entry *e, const char *name)
 	    e->next_offset)
 		return -EINVAL;
 
-	t = ipt_get_target(e);
+	t = ipt_get_target_c(e);
 	if (e->target_offset + t->u.target_size > e->next_offset)
 		return -EINVAL;
 
@@ -718,14 +725,14 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	return ret;
 }
 
-static bool check_underflow(struct ipt_entry *e)
+static bool check_underflow(const struct ipt_entry *e)
 {
 	const struct ipt_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->ip))
 		return false;
-	t = ipt_get_target(e);
+	t = ipt_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
 	verdict = ((struct ipt_standard_target *)t)->verdict;
@@ -736,8 +743,8 @@ static bool check_underflow(struct ipt_entry *e)
 static int
 check_entry_size_and_hooks(struct ipt_entry *e,
 			   struct xt_table_info *newinfo,
-			   unsigned char *base,
-			   unsigned char *limit,
+			   const unsigned char *base,
+			   const unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
 			   unsigned int valid_hooks,
@@ -952,11 +959,11 @@ get_counters(const struct xt_table_info *t,
 	local_bh_enable();
 }
 
-static struct xt_counters * alloc_counters(struct xt_table *table)
+static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	struct xt_table_info *private = table->private;
+	const struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -974,11 +981,11 @@ static struct xt_counters * alloc_counters(struct xt_table *table)
 
 static int
 copy_entries_to_user(unsigned int total_size,
-		     struct xt_table *table,
+		     const struct xt_table *table,
 		     void __user *userptr)
 {
 	unsigned int off, num;
-	struct ipt_entry *e;
+	const struct ipt_entry *e;
 	struct xt_counters *counters;
 	const struct xt_table_info *private = table->private;
 	int ret = 0;
@@ -1030,7 +1037,7 @@ copy_entries_to_user(unsigned int total_size,
 			}
 		}
 
-		t = ipt_get_target(e);
+		t = ipt_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
 				 + offsetof(struct ipt_entry_target,
 					    u.user.name),
@@ -1066,24 +1073,24 @@ static int compat_standard_to_user(void __user *dst, const void *src)
 }
 
 static inline int
-compat_calc_match(struct ipt_entry_match *m, int *size)
+compat_calc_match(const struct ipt_entry_match *m, int *size)
 {
 	*size += xt_compat_match_offset(m->u.kernel.match);
 	return 0;
 }
 
-static int compat_calc_entry(struct ipt_entry *e,
+static int compat_calc_entry(const struct ipt_entry *e,
 			     const struct xt_table_info *info,
-			     void *base, struct xt_table_info *newinfo)
+			     const void *base, struct xt_table_info *newinfo)
 {
-	struct ipt_entry_target *t;
+	const struct ipt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
 	off = sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 	entry_offset = (void *)e - base;
 	IPT_MATCH_ITERATE(e, compat_calc_match, &off);
-	t = ipt_get_target(e);
+	t = ipt_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
 	ret = xt_compat_add_offset(AF_INET, entry_offset, off);
@@ -1119,7 +1126,8 @@ static int compat_table_info(const struct xt_table_info *info,
 }
 #endif
 
-static int get_info(struct net *net, void __user *user, int *len, int compat)
+static int get_info(struct net *net, void __user *user,
+                    const int *len, int compat)
 {
 	char name[IPT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1179,7 +1187,8 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 }
 
 static int
-get_entries(struct net *net, struct ipt_get_entries __user *uptr, int *len)
+get_entries(struct net *net, struct ipt_get_entries __user *uptr,
+	    const int *len)
 {
 	int ret;
 	struct ipt_get_entries get;
@@ -1289,7 +1298,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 }
 
 static int
-do_replace(struct net *net, void __user *user, unsigned int len)
+do_replace(struct net *net, const void __user *user, unsigned int len)
 {
 	int ret;
 	struct ipt_replace tmp;
@@ -1350,7 +1359,8 @@ add_counter_to_entry(struct ipt_entry *e,
 }
 
 static int
-do_add_counters(struct net *net, void __user *user, unsigned int len, int compat)
+do_add_counters(struct net *net, const void __user *user,
+                unsigned int len, int compat)
 {
 	unsigned int i, curcpu;
 	struct xt_counters_info tmp;
@@ -1546,10 +1556,10 @@ static int
 check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 				  struct xt_table_info *newinfo,
 				  unsigned int *size,
-				  unsigned char *base,
-				  unsigned char *limit,
-				  unsigned int *hook_entries,
-				  unsigned int *underflows,
+				  const unsigned char *base,
+				  const unsigned char *limit,
+				  const unsigned int *hook_entries,
+				  const unsigned int *underflows,
 				  unsigned int *i,
 				  const char *name)
 {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 3ff4fd5..4185099 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -208,7 +208,7 @@ ip6t_error(struct sk_buff *skb, const struct xt_target_param *par)
 
 /* Performance critical - called for every packet */
 static inline bool
-do_match(struct ip6t_entry_match *m, const struct sk_buff *skb,
+do_match(const struct ip6t_entry_match *m, const struct sk_buff *skb,
 	 struct xt_match_param *par)
 {
 	par->match     = m->u.kernel.match;
@@ -222,7 +222,7 @@ do_match(struct ip6t_entry_match *m, const struct sk_buff *skb,
 }
 
 static inline struct ip6t_entry *
-get_entry(void *base, unsigned int offset)
+get_entry(const void *base, unsigned int offset)
 {
 	return (struct ip6t_entry *)(base + offset);
 }
@@ -236,6 +236,12 @@ static inline bool unconditional(const struct ip6t_ip6 *ipv6)
 	return memcmp(ipv6, &uncond, sizeof(uncond)) == 0;
 }
 
+static inline const struct ip6t_entry_target *
+ip6t_get_target_c(const struct ip6t_entry *e)
+{
+	return ip6t_get_target((struct ip6t_entry *)e);
+}
+
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 /* This cries for unification! */
@@ -271,11 +277,11 @@ static struct nf_loginfo trace_loginfo = {
 
 /* Mildly perf critical (only if packet tracing is on) */
 static inline int
-get_chainname_rulenum(struct ip6t_entry *s, struct ip6t_entry *e,
+get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 		      const char *hookname, const char **chainname,
 		      const char **comment, unsigned int *rulenum)
 {
-	struct ip6t_standard_target *t = (void *)ip6t_get_target(s);
+	const struct ip6t_standard_target *t = (void *)ip6t_get_target_c(s);
 
 	if (strcmp(t->target.u.kernel.target->name, IP6T_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
@@ -301,15 +307,15 @@ get_chainname_rulenum(struct ip6t_entry *s, struct ip6t_entry *e,
 	return 0;
 }
 
-static void trace_packet(struct sk_buff *skb,
+static void trace_packet(const struct sk_buff *skb,
 			 unsigned int hook,
 			 const struct net_device *in,
 			 const struct net_device *out,
 			 const char *tablename,
-			 struct xt_table_info *private,
-			 struct ip6t_entry *e)
+			 const struct xt_table_info *private,
+			 const struct ip6t_entry *e)
 {
-	void *table_base;
+	const void *table_base;
 	const struct ip6t_entry *root;
 	const char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
@@ -352,9 +358,9 @@ ip6t_do_table(struct sk_buff *skb,
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
-	void *table_base;
+	const void *table_base;
 	struct ip6t_entry *e, *back;
-	struct xt_table_info *private;
+	const struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
 
@@ -385,7 +391,7 @@ ip6t_do_table(struct sk_buff *skb,
 	back = get_entry(table_base, private->underflow[hook]);
 
 	do {
-		struct ip6t_entry_target *t;
+		const struct ip6t_entry_target *t;
 
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
@@ -400,7 +406,7 @@ ip6t_do_table(struct sk_buff *skb,
 			    ntohs(ipv6_hdr(skb)->payload_len) +
 			    sizeof(struct ipv6hdr), 1);
 
-		t = ip6t_get_target(e);
+		t = ip6t_get_target_c(e);
 		IP_NF_ASSERT(t->u.kernel.target);
 
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
@@ -482,7 +488,7 @@ ip6t_do_table(struct sk_buff *skb,
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct xt_table_info *newinfo,
+mark_source_chains(const struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
@@ -500,8 +506,8 @@ mark_source_chains(struct xt_table_info *newinfo,
 		e->counters.pcnt = pos;
 
 		for (;;) {
-			struct ip6t_standard_target *t
-				= (void *)ip6t_get_target(e);
+			const struct ip6t_standard_target *t
+				= (void *)ip6t_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
@@ -610,9 +616,9 @@ cleanup_match(struct ip6t_entry_match *m, struct net *net, unsigned int *i)
 }
 
 static int
-check_entry(struct ip6t_entry *e, const char *name)
+check_entry(const struct ip6t_entry *e, const char *name)
 {
-	struct ip6t_entry_target *t;
+	const struct ip6t_entry_target *t;
 
 	if (!ip6_checkentry(&e->ipv6)) {
 		duprintf("ip_tables: ip check failed %p %s.\n", e, name);
@@ -623,7 +629,7 @@ check_entry(struct ip6t_entry *e, const char *name)
 	    e->next_offset)
 		return -EINVAL;
 
-	t = ip6t_get_target(e);
+	t = ip6t_get_target_c(e);
 	if (e->target_offset + t->u.target_size > e->next_offset)
 		return -EINVAL;
 
@@ -750,14 +756,14 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	return ret;
 }
 
-static bool check_underflow(struct ip6t_entry *e)
+static bool check_underflow(const struct ip6t_entry *e)
 {
 	const struct ip6t_entry_target *t;
 	unsigned int verdict;
 
 	if (!unconditional(&e->ipv6))
 		return false;
-	t = ip6t_get_target(e);
+	t = ip6t_get_target_c(e);
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) != 0)
 		return false;
 	verdict = ((struct ip6t_standard_target *)t)->verdict;
@@ -768,8 +774,8 @@ static bool check_underflow(struct ip6t_entry *e)
 static int
 check_entry_size_and_hooks(struct ip6t_entry *e,
 			   struct xt_table_info *newinfo,
-			   unsigned char *base,
-			   unsigned char *limit,
+			   const unsigned char *base,
+			   const unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
 			   unsigned int valid_hooks,
@@ -984,11 +990,11 @@ get_counters(const struct xt_table_info *t,
 	local_bh_enable();
 }
 
-static struct xt_counters *alloc_counters(struct xt_table *table)
+static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	struct xt_table_info *private = table->private;
+	const struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1006,11 +1012,11 @@ static struct xt_counters *alloc_counters(struct xt_table *table)
 
 static int
 copy_entries_to_user(unsigned int total_size,
-		     struct xt_table *table,
+		     const struct xt_table *table,
 		     void __user *userptr)
 {
 	unsigned int off, num;
-	struct ip6t_entry *e;
+	const struct ip6t_entry *e;
 	struct xt_counters *counters;
 	const struct xt_table_info *private = table->private;
 	int ret = 0;
@@ -1062,7 +1068,7 @@ copy_entries_to_user(unsigned int total_size,
 			}
 		}
 
-		t = ip6t_get_target(e);
+		t = ip6t_get_target_c(e);
 		if (copy_to_user(userptr + off + e->target_offset
 				 + offsetof(struct ip6t_entry_target,
 					    u.user.name),
@@ -1098,24 +1104,24 @@ static int compat_standard_to_user(void __user *dst, const void *src)
 }
 
 static inline int
-compat_calc_match(struct ip6t_entry_match *m, int *size)
+compat_calc_match(const struct ip6t_entry_match *m, int *size)
 {
 	*size += xt_compat_match_offset(m->u.kernel.match);
 	return 0;
 }
 
-static int compat_calc_entry(struct ip6t_entry *e,
+static int compat_calc_entry(const struct ip6t_entry *e,
 			     const struct xt_table_info *info,
-			     void *base, struct xt_table_info *newinfo)
+			     const void *base, struct xt_table_info *newinfo)
 {
-	struct ip6t_entry_target *t;
+	const struct ip6t_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
 	off = sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 	entry_offset = (void *)e - base;
 	IP6T_MATCH_ITERATE(e, compat_calc_match, &off);
-	t = ip6t_get_target(e);
+	t = ip6t_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
 	ret = xt_compat_add_offset(AF_INET6, entry_offset, off);
@@ -1151,7 +1157,8 @@ static int compat_table_info(const struct xt_table_info *info,
 }
 #endif
 
-static int get_info(struct net *net, void __user *user, int *len, int compat)
+static int get_info(struct net *net, void __user *user,
+                    const int *len, int compat)
 {
 	char name[IP6T_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1211,7 +1218,8 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 }
 
 static int
-get_entries(struct net *net, struct ip6t_get_entries __user *uptr, int *len)
+get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
+            const int *len)
 {
 	int ret;
 	struct ip6t_get_entries get;
@@ -1322,7 +1330,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 }
 
 static int
-do_replace(struct net *net, void __user *user, unsigned int len)
+do_replace(struct net *net, const void __user *user, unsigned int len)
 {
 	int ret;
 	struct ip6t_replace tmp;
@@ -1383,7 +1391,7 @@ add_counter_to_entry(struct ip6t_entry *e,
 }
 
 static int
-do_add_counters(struct net *net, void __user *user, unsigned int len,
+do_add_counters(struct net *net, const void __user *user, unsigned int len,
 		int compat)
 {
 	unsigned int i, curcpu;
@@ -1582,10 +1590,10 @@ static int
 check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 				  struct xt_table_info *newinfo,
 				  unsigned int *size,
-				  unsigned char *base,
-				  unsigned char *limit,
-				  unsigned int *hook_entries,
-				  unsigned int *underflows,
+				  const unsigned char *base,
+				  const unsigned char *limit,
+				  const unsigned int *hook_entries,
+				  const unsigned int *underflows,
 				  unsigned int *i,
 				  const char *name)
 {
