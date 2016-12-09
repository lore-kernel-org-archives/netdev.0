From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 5/7] samples/bpf: Switch over to libbpf
Date: Thu,  8 Dec 2016 18:46:18 -0800
Message-ID: <20161209024620.31660-6-joe@ovn.org>
References: <20161209024620.31660-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that libbpf under tools/lib/bpf/* is synced with the version from
samples/bpf, we can get rid most of the libbpf library here.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: First post.
---
 samples/bpf/Makefile   |  60 +++++++++++++-------------
 samples/bpf/README.rst |   4 +-
 samples/bpf/libbpf.c   | 111 -------------------------------------------------
 samples/bpf/libbpf.h   |  19 +--------
 tools/lib/bpf/Makefile |   2 +
 5 files changed, 38 insertions(+), 158 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 72c58675973e..c8f7ed37b2de 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -29,35 +29,38 @@ hostprogs-y += trace_event
 hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
 
-test_verifier-objs := test_verifier.o libbpf.o
-test_maps-objs := test_maps.o libbpf.o
-sock_example-objs := sock_example.o libbpf.o
-fds_example-objs := bpf_load.o libbpf.o fds_example.o
-sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
-sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
-sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
-tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
-tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
-tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
-tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
-tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
-tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
-test_probe_write_user-objs := bpf_load.o libbpf.o test_probe_write_user_user.o
-trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
-lathist-objs := bpf_load.o libbpf.o lathist_user.o
-offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
-spintest-objs := bpf_load.o libbpf.o spintest_user.o
-map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
-test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
-test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
-xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
+# Libbpf dependencies
+LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
+
+test_verifier-objs := test_verifier.o $(LIBBPF)
+test_maps-objs := test_maps.o $(LIBBPF)
+sock_example-objs := sock_example.o $(LIBBPF)
+fds_example-objs := bpf_load.o $(LIBBPF) fds_example.o
+sockex1-objs := bpf_load.o $(LIBBPF) sockex1_user.o
+sockex2-objs := bpf_load.o $(LIBBPF) sockex2_user.o
+sockex3-objs := bpf_load.o $(LIBBPF) sockex3_user.o
+tracex1-objs := bpf_load.o $(LIBBPF) tracex1_user.o
+tracex2-objs := bpf_load.o $(LIBBPF) tracex2_user.o
+tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
+tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
+tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
+tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
+trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
+lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
+offwaketime-objs := bpf_load.o $(LIBBPF) offwaketime_user.o
+spintest-objs := bpf_load.o $(LIBBPF) spintest_user.o
+map_perf_test-objs := bpf_load.o $(LIBBPF) map_perf_test_user.o
+test_overhead-objs := bpf_load.o $(LIBBPF) test_overhead_user.o
+test_cgrp2_array_pin-objs := $(LIBBPF) test_cgrp2_array_pin.o
+xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
 # reuse xdp1 source intentionally
-xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
+xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
+test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) \
 				       test_current_task_under_cgroup_user.o
-trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
-sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
-tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
+trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
+sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
+tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -89,7 +92,7 @@ always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
 always += sampleip_kern.o
 
-HOSTCFLAGS += -I$(objtree)/usr/include
+HOSTCFLAGS += -I$(objtree)/usr/include -I$(objtree)/tools/lib/
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_fds_example += -lelf
@@ -123,6 +126,7 @@ CLANG ?= clang
 
 # Trick to allow make to be run from this directory
 all:
+	$(MAKE) -C ../../ tools/lib/bpf/
 	$(MAKE) -C ../../ $$PWD/
 
 clean:
diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index a43eae3f0551..79f9a58f1872 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -1,8 +1,8 @@
 eBPF sample programs
 ====================
 
-This directory contains a mini eBPF library, test stubs, verifier
-test-suite and examples for using eBPF.
+This directory contains a test stubs, verifier test-suite and examples
+for using eBPF. The examples use libbpf from tools/lib/bpf.
 
 Build dependencies
 ==================
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index e5c5a69996fc..d9af876b4a2c 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -4,8 +4,6 @@
 #include <linux/unistd.h>
 #include <unistd.h>
 #include <string.h>
-#include <linux/netlink.h>
-#include <linux/bpf.h>
 #include <errno.h>
 #include <net/ethernet.h>
 #include <net/if.h>
@@ -13,115 +11,6 @@
 #include <arpa/inet.h>
 #include "libbpf.h"
 
-static __u64 ptr_to_u64(void *ptr)
-{
-	return (__u64) (unsigned long) ptr;
-}
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags)
-{
-	union bpf_attr attr = {
-		.map_type = map_type,
-		.key_size = key_size,
-		.value_size = value_size,
-		.max_entries = max_entries,
-		.map_flags = map_flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
-}
-
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-		.flags = flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_lookup_elem(int fd, void *key, void *value)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_delete_elem(int fd, void *key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_get_next_key(int fd, void *key, void *next_key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.next_key = ptr_to_u64(next_key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
-}
-
-#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
-
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int prog_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz)
-{
-	union bpf_attr attr = {
-		.prog_type = prog_type,
-		.insns = ptr_to_u64((void *) insns),
-		.insn_cnt = prog_len / sizeof(struct bpf_insn),
-		.license = ptr_to_u64((void *) license),
-		.log_buf = ptr_to_u64(log_buf),
-		.log_size = log_buf_sz,
-		.log_level = 1,
-	};
-
-	/* assign one field outside of struct init to make sure any
-	 * padding is zero initialized
-	 */
-	attr.kern_version = kern_version;
-
-	log_buf[0] = 0;
-
-	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
-}
-
-int bpf_obj_pin(int fd, const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-		.bpf_fd		= fd,
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_PIN, &attr, sizeof(attr));
-}
-
-int bpf_obj_get(const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_GET, &attr, sizeof(attr));
-}
-
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 1325152be4cd..cc815624aacf 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -2,24 +2,9 @@
 #ifndef __LIBBPF_H
 #define __LIBBPF_H
 
-struct bpf_insn;
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags);
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_map_lookup_elem(int fd, void *key, void *value);
-int bpf_map_delete_elem(int fd, void *key);
-int bpf_map_get_next_key(int fd, void *key, void *next_key);
-
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int insn_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz);
+#include <bpf/bpf.h>
 
-int bpf_obj_pin(int fd, const char *pathname);
-int bpf_obj_get(const char *pathname);
-
-#define BPF_LOG_BUF_SIZE 65536
+struct bpf_insn;
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 62d89d50fcbd..616bd55f3be8 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -149,6 +149,8 @@ CMD_TARGETS = $(LIB_FILE)
 
 TARGETS = $(CMD_TARGETS)
 
+libbpf: all
+
 all: fixdep $(VERSION_FILES) all_cmd
 
 all_cmd: $(CMD_TARGETS)
-- 
2.10.2
