From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 2/2] netfilter: Remove unnecessary cast on void pointer
Date: Tue, 21 Mar 2017 17:49:54 +0530
Message-ID: <1490098794-22518-3-git-send-email-singhalsimran0@gmail.com>
References: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following Coccinelle script was used to detect this:
@r@
expression x;
void* e;
type T;
identifier f;
@@
(
  *((T *)e)
|
  ((T *)x)[...]
|
  ((T*)x)->f
|

- (T*)
  e
)

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14. 

 net/netfilter/nf_conntrack_proto.c |  2 +-
 net/netfilter/nft_set_hash.c       |  2 +-
 net/netfilter/xt_hashlimit.c       | 10 +++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 48d8354..ec665c8 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -202,7 +202,7 @@ static int kill_l3proto(struct nf_conn *i, void *data)
 static int kill_l4proto(struct nf_conn *i, void *data)
 {
 	struct nf_conntrack_l4proto *l4proto;
-	l4proto = (struct nf_conntrack_l4proto *)data;
+	l4proto = data;
 	return nf_ct_protonum(i) == l4proto->l4proto &&
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 5f65272..8ec086b 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -352,7 +352,7 @@ static int nft_hash_init(const struct nft_set *set,
 
 static void nft_hash_elem_destroy(void *ptr, void *arg)
 {
-	nft_set_elem_destroy((const struct nft_set *)arg, ptr, true);
+	nft_set_elem_destroy(arg, ptr, true);
 }
 
 static void nft_hash_destroy(const struct nft_set *set)
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2a6dfe8..762e187 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -119,7 +119,7 @@ static int
 cfg_copy(struct hashlimit_cfg2 *to, void *from, int revision)
 {
 	if (revision == 1) {
-		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
+		struct hashlimit_cfg1 *cfg = from;
 
 		to->mode = cfg->mode;
 		to->avg = cfg->avg;
@@ -895,7 +895,7 @@ static void *dl_seq_start(struct seq_file *s, loff_t *pos)
 static void *dl_seq_next(struct seq_file *s, void *v, loff_t *pos)
 {
 	struct xt_hashlimit_htable *htable = s->private;
-	unsigned int *bucket = (unsigned int *)v;
+	unsigned int *bucket = v;
 
 	*pos = ++(*bucket);
 	if (*pos >= htable->cfg.size) {
@@ -909,7 +909,7 @@ static void dl_seq_stop(struct seq_file *s, void *v)
 	__releases(htable->lock)
 {
 	struct xt_hashlimit_htable *htable = s->private;
-	unsigned int *bucket = (unsigned int *)v;
+	unsigned int *bucket = v;
 
 	if (!IS_ERR(bucket))
 		kfree(bucket);
@@ -980,7 +980,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 static int dl_seq_show_v1(struct seq_file *s, void *v)
 {
 	struct xt_hashlimit_htable *htable = s->private;
-	unsigned int *bucket = (unsigned int *)v;
+	unsigned int *bucket = v;
 	struct dsthash_ent *ent;
 
 	if (!hlist_empty(&htable->hash[*bucket])) {
@@ -994,7 +994,7 @@ static int dl_seq_show_v1(struct seq_file *s, void *v)
 static int dl_seq_show(struct seq_file *s, void *v)
 {
 	struct xt_hashlimit_htable *htable = s->private;
-	unsigned int *bucket = (unsigned int *)v;
+	unsigned int *bucket = v;
 	struct dsthash_ent *ent;
 
 	if (!hlist_empty(&htable->hash[*bucket])) {
-- 
2.7.4
