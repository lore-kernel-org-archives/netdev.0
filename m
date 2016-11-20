From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 2/5] net: xdp: add invalid buffer warning
Date: Sat, 19 Nov 2016 18:50:04 -0800
Message-ID: <20161120025004.19187.84665.stgit@john-Precision-Tower-5810>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
        john.fastabend@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: daniel@iogearbox.net, eric.dumazet@gmail.com, mst@redhat.com,
        kubakici@wp.pl, shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36781 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbcKTCub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 21:50:31 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so24692484pgx.3
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 18:50:31 -0800 (PST)
In-Reply-To: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a warning for drivers to use when encountering an invalid
buffer for XDP. For normal cases this should not happen but to catch
this in virtual/qemu setups that I may not have expected from the
emulation layer having a standard warning is useful.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/filter.h |    1 +
 net/core/filter.c      |    6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c52..0c79004 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -595,6 +595,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 void bpf_warn_invalid_xdp_action(u32 act);
+void bpf_warn_invalid_xdp_buffer(void);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/net/core/filter.c b/net/core/filter.c
index dece94f..b777730 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2774,6 +2774,12 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+void bpf_warn_invalid_xdp_buffer(void)
+{
+	WARN_ONCE(1, "Illegal XDP buffer encountered, expect packet loss\n");
+}
+EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_buffer);
+
 static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					int src_reg, int ctx_off,
 					struct bpf_insn *insn_buf,
