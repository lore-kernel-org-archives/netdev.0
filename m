From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] net: xdp: remove unused bfp_warn_invalid_xdp_buffer()
Date: Tue, 27 Dec 2016 10:49:54 +0800
Message-ID: <1482806994-14649-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 73b62bd085f4737679ea9afc7867fa5f99ba7d1b ("virtio-net:
remove the warning before XDP linearizing"), there's no users for
bpf_warn_invalid_xdp_buffer(), so remove it. This is a revert for
commit f23bc46c30ca5ef58b8549434899fcbac41b2cfc.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/filter.h | 1 -
 net/core/filter.c      | 6 ------
 2 files changed, 7 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7023142..a0934e6 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -610,7 +610,6 @@ bool bpf_helper_changes_pkt_data(void *func);
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 void bpf_warn_invalid_xdp_action(u32 act);
-void bpf_warn_invalid_xdp_buffer(void);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/net/core/filter.c b/net/core/filter.c
index 7190bd6..b146170 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2972,12 +2972,6 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-void bpf_warn_invalid_xdp_buffer(void)
-{
-	WARN_ONCE(1, "Illegal XDP buffer encountered, expect throughput degradation\n");
-}
-EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_buffer);
-
 static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					int src_reg, int ctx_off,
 					struct bpf_insn *insn_buf,
-- 
2.7.4
