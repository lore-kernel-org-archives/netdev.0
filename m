From: Sargun Dhillon <sargun@sargun.me>
Subject: [RFC 4/4] bpf: Restrict Checmate bpf programs to current kernel ABI
Date: Thu, 4 Aug 2016 00:12:29 -0700
Message-ID: <20160804071227.GA19135@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it makes sense to restrict Checmate to loading programs that have been 
compiled with the current kernel ABI. We can further stabilize the ABI, and 
perhaps lift this restriction later.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 kernel/bpf/syscall.c         | 2 +-
 samples/bpf/checmate1_kern.c | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..2a37b4d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -741,7 +741,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (attr->insn_cnt >= BPF_MAXINSNS)
 		return -EINVAL;
 
-	if (type == BPF_PROG_TYPE_KPROBE &&
+	if ((type & (BPF_PROG_TYPE_KPROBE | BPF_PROG_TYPE_CHECMATE)) &&
 	    attr->kern_version != LINUX_VERSION_CODE)
 		return -EINVAL;
 
diff --git a/samples/bpf/checmate1_kern.c b/samples/bpf/checmate1_kern.c
index f78b66b..d4ec1fa 100644
--- a/samples/bpf/checmate1_kern.c
+++ b/samples/bpf/checmate1_kern.c
@@ -3,6 +3,7 @@
 #include <linux/in.h>
 #include <linux/checmate.h>
 #include "bpf_helpers.h"
+#include <linux/version.h>
 
 SEC("checmate")
 int prog(struct checmate_ctx *ctx)
@@ -24,4 +25,4 @@ int prog(struct checmate_ctx *ctx)
 }
 
 char _license[] SEC("license") = "GPL";
-
+u32 _version SEC("version") = LINUX_VERSION_CODE;
-- 
2.7.4
