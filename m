From: David Miller <davem@davemloft.net>
Subject: [PATCH] bpf: Add sparc support to tools and samples.
Date: Sat, 22 Apr 2017 15:38:46 -0400 (EDT)
Message-ID: <20170422.153846.1171688488318421720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755346AbdDVTiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 15:38:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 samples/bpf/bpf_helpers.h      | 19 +++++++++++++++++++
 tools/build/feature/test-bpf.c |  3 +++
 tools/lib/bpf/bpf.c            |  2 ++
 3 files changed, 24 insertions(+)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 52de9d8..9a9c95f 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -146,11 +146,30 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->nip)
 
+#elif defined(__sparc__)
+
+#define PT_REGS_PARM1(x) ((x)->u_regs[UREG_I0])
+#define PT_REGS_PARM2(x) ((x)->u_regs[UREG_I1])
+#define PT_REGS_PARM3(x) ((x)->u_regs[UREG_I2])
+#define PT_REGS_PARM4(x) ((x)->u_regs[UREG_I3])
+#define PT_REGS_PARM5(x) ((x)->u_regs[UREG_I4])
+#define PT_REGS_RET(x) ((x)->u_regs[UREG_I7])
+#define PT_REGS_RC(x) ((x)->u_regs[UREG_I0])
+#define PT_REGS_SP(x) ((x)->u_regs[UREG_FP])
+#if defined(__arch64__)
+#define PT_REGS_IP(x) ((x)->tpc)
+#else
+#define PT_REGS_IP(x) ((x)->pc)
+#endif
+
 #endif
 
 #ifdef __powerpc__
 #define BPF_KPROBE_READ_RET_IP(ip, ctx)		({ (ip) = (ctx)->link; })
 #define BPF_KRETPROBE_READ_RET_IP		BPF_KPROBE_READ_RET_IP
+#elif defined(__sparc__)
+#define BPF_KPROBE_READ_RET_IP(ip, ctx)		({ (ip) = PT_REGS_RET(ctx); })
+#define BPF_KRETPROBE_READ_RET_IP		BPF_KPROBE_READ_RET_IP
 #else
 #define BPF_KPROBE_READ_RET_IP(ip, ctx)		({				\
 		bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx)); })
diff --git a/tools/build/feature/test-bpf.c b/tools/build/feature/test-bpf.c
index e04ab89..ebc6dce 100644
--- a/tools/build/feature/test-bpf.c
+++ b/tools/build/feature/test-bpf.c
@@ -9,6 +9,9 @@
 #  define __NR_bpf 321
 # elif defined(__aarch64__)
 #  define __NR_bpf 280
+# elif defined(__sparc__)
+#  define __NR_bpf 349
+# else
 #  error __NR_bpf not defined. libbpf does not support your arch.
 # endif
 #endif
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index f84c398..4fe444b80 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -37,6 +37,8 @@
 #  define __NR_bpf 321
 # elif defined(__aarch64__)
 #  define __NR_bpf 280
+# elif defined(__sparc__)
+#  define __NR_bpf 349
 # else
 #  error __NR_bpf not defined. libbpf does not support your arch.
 # endif
-- 
2.1.2.532.g19b5d50
