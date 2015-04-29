From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 1/4] net: filter: make bpf_migrate_filter available outside of net/core/filter.c
Date: Wed, 29 Apr 2015 15:37:34 +0200
Message-ID: <1430314657-2552-2-git-send-email-nschichan@freebox.fr>
References: <1430314657-2552-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430314657-2552-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is in preparation of its use in the seccomp code.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 include/linux/filter.h | 1 +
 net/core/filter.c      | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index caac208..7e0811b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -379,6 +379,7 @@ static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 
 int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
 void bpf_prog_destroy(struct bpf_prog *fp);
+struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
diff --git a/net/core/filter.c b/net/core/filter.c
index f6bdc2b..b8ce66e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -876,7 +876,7 @@ bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 	return false;
 }
 
-static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
+struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
 {
 	struct sock_filter *old_prog;
 	struct bpf_prog *old_fp;
-- 
1.9.1
