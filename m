From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 05/10] bpf: export bpf_prog_inc_not_zero
Date: Tue, 15 Aug 2017 22:32:22 -0700
Message-ID: <20170816053221.15445.31265.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34019 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdHPFcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:32:41 -0400
Received: by mail-pf0-f193.google.com with SMTP id t86so423783pfe.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:32:41 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_prog_inc_not_zero will be used by upcoming sockmap patches this
patch simply exports it so we can pull it in.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/bpf.h  |    7 +++++++
 kernel/bpf/syscall.c |    3 ++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 39229c4..d6e1de8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -252,6 +252,7 @@ int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
 struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog, int i);
 void bpf_prog_sub(struct bpf_prog *prog, int i);
 struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog);
+struct bpf_prog * __must_check bpf_prog_inc_not_zero(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
 int __bpf_prog_charge(struct user_struct *user, u32 pages);
 void __bpf_prog_uncharge(struct user_struct *user, u32 pages);
@@ -344,6 +345,12 @@ static inline struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog)
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline struct bpf_prog *__must_check
+bpf_prog_inc_not_zero(struct bpf_prog *prog)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 static inline int __bpf_prog_charge(struct user_struct *user, u32 pages)
 {
 	return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index fbe09a0..17e29f5 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -911,7 +911,7 @@ struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 EXPORT_SYMBOL_GPL(bpf_prog_inc);
 
 /* prog_idr_lock should have been held */
-static struct bpf_prog *bpf_prog_inc_not_zero(struct bpf_prog *prog)
+struct bpf_prog *bpf_prog_inc_not_zero(struct bpf_prog *prog)
 {
 	int refold;
 
@@ -927,6 +927,7 @@ static struct bpf_prog *bpf_prog_inc_not_zero(struct bpf_prog *prog)
 
 	return prog;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_inc_not_zero);
 
 static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
