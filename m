From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 2/5] net: xdp: add invalid buffer warning
Date: Fri, 18 Nov 2016 10:59:54 -0800
Message-ID: <20161118185954.16137.46876.stgit@john-Precision-Tower-5810>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.fastabend@gmail.com, brouer@redhat.com
To: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33409 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753260AbcKRTAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:00:14 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so21362386pgd.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 11:00:13 -0800 (PST)
In-Reply-To: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
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
index cd9e2ba..b8fb57c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2722,6 +2722,12 @@ void bpf_warn_invalid_xdp_action(u32 act)
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
