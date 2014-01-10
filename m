From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/7] net_sched: avoid casting void pointer
Date: Thu,  9 Jan 2014 16:14:03 -0800
Message-ID: <1389312845-10304-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33489 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbaAJAOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:42 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so3821056pdj.36
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:42 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tp->root is a void* pointer, no need to cast it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_basic.c   | 10 +++++-----
 net/sched/cls_fw.c      | 14 +++++++-------
 net/sched/cls_route.c   |  6 +++---
 net/sched/cls_tcindex.c | 17 +++++++----------
 net/sched/cls_u32.c     |  2 +-
 5 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index af6bea1..e98ca99 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -38,7 +38,7 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
 	int r;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = tp->root;
 	struct basic_filter *f;
 
 	list_for_each_entry(f, &head->flist, link) {
@@ -56,7 +56,7 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
 {
 	unsigned long l = 0UL;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = tp->root;
 	struct basic_filter *f;
 
 	if (head == NULL)
@@ -107,7 +107,7 @@ static void basic_destroy(struct tcf_proto *tp)
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = tp->root;
 	struct basic_filter *t, *f = (struct basic_filter *) arg;
 
 	list_for_each_entry(t, &head->flist, link)
@@ -164,7 +164,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 			struct nlattr **tca, unsigned long *arg)
 {
 	int err;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = tp->root;
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *f = (struct basic_filter *) *arg;
 
@@ -225,7 +225,7 @@ errout:
 
 static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = tp->root;
 	struct basic_filter *f;
 
 	list_for_each_entry(f, &head->flist, link) {
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index ca662aa..ed00e8c 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -75,7 +75,7 @@ static inline int fw_hash(u32 handle)
 static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct fw_filter *f;
 	int r;
 	u32 id = skb->mark;
@@ -111,7 +111,7 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct fw_filter *f;
 
 	if (head == NULL)
@@ -160,7 +160,7 @@ static void fw_destroy(struct tcf_proto *tp)
 
 static int fw_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct fw_filter *f = (struct fw_filter *)arg;
 	struct fw_filter **fp;
 
@@ -190,7 +190,7 @@ static int
 fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	struct nlattr **tb, struct nlattr **tca, unsigned long base)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct tcf_exts e;
 	u32 mask;
 	int err;
@@ -237,7 +237,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 		     struct nlattr **tca,
 		     unsigned long *arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct fw_filter *f = (struct fw_filter *) *arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FW_MAX + 1];
@@ -300,7 +300,7 @@ errout:
 
 static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	int h;
 
 	if (head == NULL)
@@ -329,7 +329,7 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = tp->root;
 	struct fw_filter *f = (struct fw_filter *)fh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index c913613..1ad3068 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -123,7 +123,7 @@ static inline int route4_hash_wild(void)
 static int route4_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			   struct tcf_result *res)
 {
-	struct route4_head *head = (struct route4_head *)tp->root;
+	struct route4_head *head = tp->root;
 	struct dst_entry *dst;
 	struct route4_bucket *b;
 	struct route4_filter *f;
@@ -213,7 +213,7 @@ static inline u32 from_hash(u32 id)
 
 static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 {
-	struct route4_head *head = (struct route4_head *)tp->root;
+	struct route4_head *head = tp->root;
 	struct route4_bucket *b;
 	struct route4_filter *f;
 	unsigned int h1, h2;
@@ -284,7 +284,7 @@ static void route4_destroy(struct tcf_proto *tp)
 
 static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct route4_head *head = (struct route4_head *)tp->root;
+	struct route4_head *head = tp->root;
 	struct route4_filter **fp, *f = (struct route4_filter *)arg;
 	unsigned int h = 0;
 	struct route4_bucket *b;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index f575353..eed8404 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -24,9 +24,6 @@
 #define DEFAULT_HASH_SIZE	64	/* optimized for diffserv */
 
 
-#define	PRIV(tp)	((struct tcindex_data *) (tp)->root)
-
-
 struct tcindex_filter_result {
 	struct tcf_exts		exts;
 	struct tcf_result	res;
@@ -77,7 +74,7 @@ tcindex_lookup(struct tcindex_data *p, u16 key)
 static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter_result *f;
 	int key = (skb->tc_index & p->mask) >> p->shift;
 
@@ -102,7 +99,7 @@ static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 static unsigned long tcindex_get(struct tcf_proto *tp, u32 handle)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter_result *r;
 
 	pr_debug("tcindex_get(tp %p,handle 0x%08x)\n", tp, handle);
@@ -140,7 +137,7 @@ static int tcindex_init(struct tcf_proto *tp)
 static int
 __tcindex_delete(struct tcf_proto *tp, unsigned long arg, int lock)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
 	struct tcindex_filter *f = NULL;
 
@@ -338,7 +335,7 @@ tcindex_change(struct net *net, struct sk_buff *in_skb,
 {
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
 	int err;
 
@@ -360,7 +357,7 @@ tcindex_change(struct net *net, struct sk_buff *in_skb,
 
 static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter *f, *next;
 	int i;
 
@@ -407,7 +404,7 @@ static int tcindex_destroy_element(struct tcf_proto *tp,
 
 static void tcindex_destroy(struct tcf_proto *tp)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcf_walker walker;
 
 	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
@@ -425,7 +422,7 @@ static void tcindex_destroy(struct tcf_proto *tp)
 static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = tp->root;
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index f509b79..84c28da 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -95,7 +95,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 		unsigned int	  off;
 	} stack[TC_U32_MAXDEPTH];
 
-	struct tc_u_hnode *ht = (struct tc_u_hnode *)tp->root;
+	struct tc_u_hnode *ht = tp->root;
 	unsigned int off = skb_network_offset(skb);
 	struct tc_u_knode *n;
 	int sdepth = 0;
-- 
1.8.3.1
