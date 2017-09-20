From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH v4 1/4] samples/bpf: Use getppid instead of getpgrp for array map stress
Date: Wed, 20 Sep 2017 09:11:56 -0700
Message-ID: <20170920161159.25747-1-joelaf@google.com>
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, daniel@iogearbox.net, davem@davemloft.net,
        ast@kernel.org, kernel-team@android.com,
        Joel Fernandes <joelaf@google.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross-compiling the bpf sample map_perf_test for aarch64, I find that
__NR_getpgrp is undefined. This causes build errors. This syscall is deprecated
and requires defining __ARCH_WANT_SYSCALL_DEPRECATED. To avoid having to define
that, just use a different syscall (getppid) for the array map stress test.

Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/map_perf_test_kern.c | 2 +-
 samples/bpf/map_perf_test_user.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 098c857f1eda..2b2ffb97018b 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -266,7 +266,7 @@ int stress_hash_map_lookup(struct pt_regs *ctx)
 	return 0;
 }
 
-SEC("kprobe/sys_getpgrp")
+SEC("kprobe/sys_getppid")
 int stress_array_map_lookup(struct pt_regs *ctx)
 {
 	u32 key = 1, i;
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index f388254896f6..a0310fc70057 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -282,7 +282,7 @@ static void test_array_lookup(int cpu)
 
 	start_time = time_get_ns();
 	for (i = 0; i < max_cnt; i++)
-		syscall(__NR_getpgrp, 0);
+		syscall(__NR_getppid, 0);
 	printf("%d:array_lookup %lld lookups per sec\n",
 	       cpu, max_cnt * 1000000000ll * 64 / (time_get_ns() - start_time));
 }
-- 
2.14.1.821.g8fa685d3b7-goog
