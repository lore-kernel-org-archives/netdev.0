From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v2 1/5] samples/bpf: Use getppid instead of getpgrp for array map stress
Date: Mon,  7 Aug 2017 06:05:58 -0700
Message-ID: <20170807130602.31785-2-joelaf@google.com>
References: <20170807130602.31785-1-joelaf@google.com>
Cc: Chenbo Feng <fengc@google.com>,
        Alison Chaiken <alison@she-devel.com>, Juri.Lelli@arm.com,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev@vger.kernel.org (open list:BPF (Safe dynamic programs and tools))
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807130602.31785-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross-compiling the bpf sample map_perf_test for aarch64, I find that
__NR_getpgrp is undefined. This causes build errors. This syscall is deprecated
and requires defining __ARCH_WANT_SYSCALL_DEPRECATED. To avoid having to define
that, just use a different syscall (getppid) for the array map stress test.

Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/map_perf_test_kern.c | 2 +-
 samples/bpf/map_perf_test_user.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 245165817fbe..038ffec295cf 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -232,7 +232,7 @@ int stress_hash_map_lookup(struct pt_regs *ctx)
 	return 0;
 }
 
-SEC("kprobe/sys_getpgrp")
+SEC("kprobe/sys_getppid")
 int stress_array_map_lookup(struct pt_regs *ctx)
 {
 	u32 key = 1, i;
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 1a8894b5ac51..1e9e68942197 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -232,7 +232,7 @@ static void test_array_lookup(int cpu)
 
 	start_time = time_get_ns();
 	for (i = 0; i < max_cnt; i++)
-		syscall(__NR_getpgrp, 0);
+		syscall(__NR_getppid, 0);
 	printf("%d:array_lookup %lld lookups per sec\n",
 	       cpu, max_cnt * 1000000000ll * 64 / (time_get_ns() - start_time));
 }
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
