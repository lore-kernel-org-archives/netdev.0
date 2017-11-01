From: Roman Gushchin <guro@fb.com>
Subject: [PATCH net-next 3/4] bpf: move cgroup_helpers from samples/bpf/ to tools/testing/selftesting/bpf/
Date: Wed, 1 Nov 2017 11:20:36 -0400
Message-ID: <20171101152037.3288-4-guro@fb.com>
References: <20171101152037.3288-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, Roman Gushchin <guro@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101152037.3288-1-guro@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose of this move is to use these files in bpf tests.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/Makefile                                      | 5 +++--
 tools/testing/selftests/bpf/Makefile                      | 2 +-
 {samples => tools/testing/selftests}/bpf/cgroup_helpers.c | 0
 {samples => tools/testing/selftests}/bpf/cgroup_helpers.h | 0
 4 files changed, 4 insertions(+), 3 deletions(-)
 rename {samples => tools/testing/selftests}/bpf/cgroup_helpers.c (100%)
 rename {samples => tools/testing/selftests}/bpf/cgroup_helpers.h (100%)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ea2b9e6135f3..adb1e5dba1ea 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -45,6 +45,7 @@ hostprogs-y += syscall_tp
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
+CGROUP_HELPERS := ../../tools/testing/selftests/bpf/cgroup_helpers.o
 
 test_lru_dist-objs := test_lru_dist.o $(LIBBPF)
 sock_example-objs := sock_example.o $(LIBBPF)
@@ -68,13 +69,13 @@ map_perf_test-objs := bpf_load.o $(LIBBPF) map_perf_test_user.o
 test_overhead-objs := bpf_load.o $(LIBBPF) test_overhead_user.o
 test_cgrp2_array_pin-objs := $(LIBBPF) test_cgrp2_array_pin.o
 test_cgrp2_attach-objs := $(LIBBPF) test_cgrp2_attach.o
-test_cgrp2_attach2-objs := $(LIBBPF) test_cgrp2_attach2.o cgroup_helpers.o
+test_cgrp2_attach2-objs := $(LIBBPF) test_cgrp2_attach2.o $(CGROUP_HELPERS)
 test_cgrp2_sock-objs := $(LIBBPF) test_cgrp2_sock.o
 test_cgrp2_sock2-objs := bpf_load.o $(LIBBPF) test_cgrp2_sock2.o
 xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) cgroup_helpers.o \
+test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) $(CGROUP_HELPERS) \
 				       test_current_task_under_cgroup_user.o
 trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
 sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 2e7880ea0add..36c34f0218a3 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -22,7 +22,7 @@ TEST_PROGS := test_kmod.sh test_xdp_redirect.sh test_xdp_meta.sh
 
 include ../lib.mk
 
-BPFOBJ := $(OUTPUT)/libbpf.a
+BPFOBJ := $(OUTPUT)/libbpf.a $(OUTPUT)/cgroup_helpers.c
 
 $(TEST_GEN_PROGS): $(BPFOBJ)
 
diff --git a/samples/bpf/cgroup_helpers.c b/tools/testing/selftests/bpf/cgroup_helpers.c
similarity index 100%
rename from samples/bpf/cgroup_helpers.c
rename to tools/testing/selftests/bpf/cgroup_helpers.c
diff --git a/samples/bpf/cgroup_helpers.h b/tools/testing/selftests/bpf/cgroup_helpers.h
similarity index 100%
rename from samples/bpf/cgroup_helpers.h
rename to tools/testing/selftests/bpf/cgroup_helpers.h
-- 
2.13.6
