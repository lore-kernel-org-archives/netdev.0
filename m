From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v3 1/4] samples/bpf: Use getppid instead of getpgrp for array map stress
Date: Sun,  3 Sep 2017 11:25:46 -0700
Message-ID: <20170903182549.30866-1-joelaf@google.com>
Cc: kernel-team@android.com, Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross-compiling the bpf sample map_perf_test for aarch64, I find that
__NR_getpgrp is undefined. This causes build errors. This syscall is deprecated
and requires defining __ARCH_WANT_SYSCALL_DEPRECATED. To avoid having to define
that, just use a different syscall (getppid) for the array map stress test.

CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
Cc: David Miller <davem@davemloft.net>
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
2.14.1.581.gf28d330327-goog
