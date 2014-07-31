From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 2/5] net: filter: rename sk_filter_proglen -> bpf_classic_proglen
Date: Wed, 30 Jul 2014 20:34:13 -0700
Message-ID: <1406777656-27755-3-git-send-email-ast@plumgrid.com>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

trivial rename to better match semantics of macro

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h |    3 +--
 net/core/filter.c      |    8 ++++----
 net/core/sock_diag.c   |    2 +-
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 00640edc166f..3769341a745d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -344,8 +344,7 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 		   offsetof(struct sk_filter, insns[proglen]));
 }
 
-#define sk_filter_proglen(fprog)			\
-		(fprog->len * sizeof(fprog->filter[0]))
+#define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 5a6aeb1d40b8..d6cb287e4f59 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -813,7 +813,7 @@ EXPORT_SYMBOL(sk_chk_filter);
 static int sk_store_orig_filter(struct sk_filter *fp,
 				const struct sock_fprog *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = bpf_classic_proglen(fprog);
 	struct sock_fprog_kern *fkprog;
 
 	fp->orig_prog = kmalloc(sizeof(*fkprog), GFP_KERNEL);
@@ -1001,7 +1001,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp)
 int sk_unattached_filter_create(struct sk_filter **pfp,
 				struct sock_fprog_kern *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = bpf_classic_proglen(fprog);
 	struct sk_filter *fp;
 
 	/* Make sure new filter is there and in the right amounts. */
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = bpf_classic_proglen(fprog);
 	unsigned int sk_fsize = sk_filter_size(fprog->len);
 	int err;
 
@@ -1154,7 +1154,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		goto out;
 
 	ret = -EFAULT;
-	if (copy_to_user(ubuf, fprog->filter, sk_filter_proglen(fprog)))
+	if (copy_to_user(ubuf, fprog->filter, bpf_classic_proglen(fprog)))
 		goto out;
 
 	/* Instead of bytes, the API requests to return the number
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a4216a4c9572..57d922320c59 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -69,7 +69,7 @@ int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 		goto out;
 
 	fprog = filter->orig_prog;
-	flen = sk_filter_proglen(fprog);
+	flen = bpf_classic_proglen(fprog);
 
 	attr = nla_reserve(skb, attrtype, flen);
 	if (attr == NULL) {
-- 
1.7.9.5

