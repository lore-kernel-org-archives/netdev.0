From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 55/62: xtables: constify args in compat copying functions
Date: Tue, 16 Feb 2010 15:56:34 +0100 (MET)
Message-ID: <20100216145631.2796.36913.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 739674fb7febf116e7d647031fab16989a08a965
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 26 08:23:19 2009 +0200

    netfilter: xtables: constify args in compat copying functions
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index a0a144a..c61758f 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -286,8 +286,8 @@ struct xt_match {
 	void (*destroy)(const struct xt_mtdtor_param *);
 #ifdef CONFIG_COMPAT
 	/* Called when userspace align differs from kernel space one */
-	void (*compat_from_user)(void *dst, void *src);
-	int (*compat_to_user)(void __user *dst, void *src);
+	void (*compat_from_user)(void *dst, const void *src);
+	int (*compat_to_user)(void __user *dst, const void *src);
 #endif
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
@@ -328,8 +328,8 @@ struct xt_target {
 	void (*destroy)(const struct xt_tgdtor_param *);
 #ifdef CONFIG_COMPAT
 	/* Called when userspace align differs from kernel space one */
-	void (*compat_from_user)(void *dst, void *src);
-	int (*compat_to_user)(void __user *dst, void *src);
+	void (*compat_from_user)(void *dst, const void *src);
+	int (*compat_to_user)(void __user *dst, const void *src);
 #endif
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
@@ -593,13 +593,13 @@ extern short xt_compat_calc_jump(u_int8_t af, unsigned int offset);
 extern int xt_compat_match_offset(const struct xt_match *match);
 extern int xt_compat_match_from_user(struct xt_entry_match *m,
 				     void **dstptr, unsigned int *size);
-extern int xt_compat_match_to_user(struct xt_entry_match *m,
+extern int xt_compat_match_to_user(const struct xt_entry_match *m,
 				   void __user **dstptr, unsigned int *size);
 
 extern int xt_compat_target_offset(const struct xt_target *target);
 extern void xt_compat_target_from_user(struct xt_entry_target *t,
 				       void **dstptr, unsigned int *size);
-extern int xt_compat_target_to_user(struct xt_entry_target *t,
+extern int xt_compat_target_to_user(const struct xt_entry_target *t,
 				    void __user **dstptr, unsigned int *size);
 
 #endif /* CONFIG_COMPAT */
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 72723ea..2303dc9 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -842,7 +842,7 @@ static int copy_entries_to_user(unsigned int total_size,
 }
 
 #ifdef CONFIG_COMPAT
-static void compat_standard_from_user(void *dst, void *src)
+static void compat_standard_from_user(void *dst, const void *src)
 {
 	int v = *(compat_int_t *)src;
 
@@ -851,7 +851,7 @@ static void compat_standard_from_user(void *dst, void *src)
 	memcpy(dst, &v, sizeof(v));
 }
 
-static int compat_standard_to_user(void __user *dst, void *src)
+static int compat_standard_to_user(void __user *dst, const void *src)
 {
 	compat_int_t cv = *(int *)src;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2057b1b..2a4f745 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1047,7 +1047,7 @@ copy_entries_to_user(unsigned int total_size,
 }
 
 #ifdef CONFIG_COMPAT
-static void compat_standard_from_user(void *dst, void *src)
+static void compat_standard_from_user(void *dst, const void *src)
 {
 	int v = *(compat_int_t *)src;
 
@@ -1056,7 +1056,7 @@ static void compat_standard_from_user(void *dst, void *src)
 	memcpy(dst, &v, sizeof(v));
 }
 
-static int compat_standard_to_user(void __user *dst, void *src)
+static int compat_standard_to_user(void __user *dst, const void *src)
 {
 	compat_int_t cv = *(int *)src;
 
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 399061c..09a5d3f 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -338,7 +338,7 @@ struct compat_ipt_ulog_info {
 	char		prefix[ULOG_PREFIX_LEN];
 };
 
-static void ulog_tg_compat_from_user(void *dst, void *src)
+static void ulog_tg_compat_from_user(void *dst, const void *src)
 {
 	const struct compat_ipt_ulog_info *cl = src;
 	struct ipt_ulog_info l = {
@@ -351,7 +351,7 @@ static void ulog_tg_compat_from_user(void *dst, void *src)
 	memcpy(dst, &l, sizeof(l));
 }
 
-static int ulog_tg_compat_to_user(void __user *dst, void *src)
+static int ulog_tg_compat_to_user(void __user *dst, const void *src)
 {
 	const struct ipt_ulog_info *l = src;
 	struct compat_ipt_ulog_info cl = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index dcd7825..3ff4fd5 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1079,7 +1079,7 @@ copy_entries_to_user(unsigned int total_size,
 }
 
 #ifdef CONFIG_COMPAT
-static void compat_standard_from_user(void *dst, void *src)
+static void compat_standard_from_user(void *dst, const void *src)
 {
 	int v = *(compat_int_t *)src;
 
@@ -1088,7 +1088,7 @@ static void compat_standard_from_user(void *dst, void *src)
 	memcpy(dst, &v, sizeof(v));
 }
 
-static int compat_standard_to_user(void __user *dst, void *src)
+static int compat_standard_to_user(void __user *dst, const void *src)
 {
 	compat_int_t cv = *(int *)src;
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 1250319..69c5628 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -485,8 +485,8 @@ int xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
 }
 EXPORT_SYMBOL_GPL(xt_compat_match_from_user);
 
-int xt_compat_match_to_user(struct xt_entry_match *m, void __user **dstptr,
-			    unsigned int *size)
+int xt_compat_match_to_user(const struct xt_entry_match *m,
+			    void __user **dstptr, unsigned int *size)
 {
 	const struct xt_match *match = m->u.kernel.match;
 	struct compat_xt_entry_match __user *cm = *dstptr;
@@ -588,8 +588,8 @@ void xt_compat_target_from_user(struct xt_entry_target *t, void **dstptr,
 }
 EXPORT_SYMBOL_GPL(xt_compat_target_from_user);
 
-int xt_compat_target_to_user(struct xt_entry_target *t, void __user **dstptr,
-			     unsigned int *size)
+int xt_compat_target_to_user(const struct xt_entry_target *t,
+			     void __user **dstptr, unsigned int *size)
 {
 	const struct xt_target *target = t->u.kernel.target;
 	struct compat_xt_entry_target __user *ct = *dstptr;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 017c959..e47fb80 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -775,7 +775,7 @@ struct compat_xt_hashlimit_info {
 	compat_uptr_t master;
 };
 
-static void hashlimit_mt_compat_from_user(void *dst, void *src)
+static void hashlimit_mt_compat_from_user(void *dst, const void *src)
 {
 	int off = offsetof(struct compat_xt_hashlimit_info, hinfo);
 
@@ -783,7 +783,7 @@ static void hashlimit_mt_compat_from_user(void *dst, void *src)
 	memset(dst + off, 0, sizeof(struct compat_xt_hashlimit_info) - off);
 }
 
-static int hashlimit_mt_compat_to_user(void __user *dst, void *src)
+static int hashlimit_mt_compat_to_user(void __user *dst, const void *src)
 {
 	int off = offsetof(struct compat_xt_hashlimit_info, hinfo);
 
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 2773be6..a0ca533 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -148,7 +148,7 @@ struct compat_xt_rateinfo {
 
 /* To keep the full "prev" timestamp, the upper 32 bits are stored in the
  * master pointer, which does not need to be preserved. */
-static void limit_mt_compat_from_user(void *dst, void *src)
+static void limit_mt_compat_from_user(void *dst, const void *src)
 {
 	const struct compat_xt_rateinfo *cm = src;
 	struct xt_rateinfo m = {
@@ -162,7 +162,7 @@ static void limit_mt_compat_from_user(void *dst, void *src)
 	memcpy(dst, &m, sizeof(m));
 }
 
-static int limit_mt_compat_to_user(void __user *dst, void *src)
+static int limit_mt_compat_to_user(void __user *dst, const void *src)
 {
 	const struct xt_rateinfo *m = src;
 	struct compat_xt_rateinfo cm = {
