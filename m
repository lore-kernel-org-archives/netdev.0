From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH] samples/bpf: Fix cross compiler error with bpf sample
Date: Thu,  3 Aug 2017 22:46:23 -0700
Message-ID: <20170804054623.5229-1-joelaf@google.com>
Cc: Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev@vger.kernel.org (open list:BPF (Safe dynamic programs and tools))
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross-compiling the bpf sample map_perf_test for aarch64, I find that
__NR_getpgrp is undefined. This causes build errors. Fix it by allowing the
deprecated syscall in the sample.

Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/map_perf_test_user.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 1a8894b5ac51..6e6fc7121640 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -8,7 +8,9 @@
 #include <sched.h>
 #include <stdio.h>
 #include <sys/types.h>
+#define __ARCH_WANT_SYSCALL_DEPRECATED
 #include <asm/unistd.h>
+#undef __ARCH_WANT_SYSCALL_DEPRECATED
 #include <unistd.h>
 #include <assert.h>
 #include <sys/wait.h>
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
