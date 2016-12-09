From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 7/7] samples/bpf: Move open_raw_sock to separate header
Date: Thu,  8 Dec 2016 18:46:20 -0800
Message-ID: <20161209024620.31660-8-joe@ovn.org>
References: <20161209024620.31660-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function was declared in libbpf.c and was the only remaining
function in this library, but has nothing to do with BPF. Shift it out
into a new header, sock_example.h, and include it from the relevant
samples.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: First post.
---
 samples/bpf/Makefile                     | 2 +-
 samples/bpf/fds_example.c                | 1 +
 samples/bpf/libbpf.h                     | 3 ---
 samples/bpf/sock_example.c               | 1 +
 samples/bpf/{libbpf.c => sock_example.h} | 3 +--
 samples/bpf/sockex1_user.c               | 1 +
 samples/bpf/sockex2_user.c               | 1 +
 samples/bpf/sockex3_user.c               | 1 +
 8 files changed, 7 insertions(+), 6 deletions(-)
 rename samples/bpf/{libbpf.c => sock_example.h} (92%)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 0adc47e67e65..7f083faa6e16 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -30,7 +30,7 @@ hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
 
 # Libbpf dependencies
-LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
+LIBBPF := ../../tools/lib/bpf/bpf.o
 
 test_verifier-objs := test_verifier.o $(LIBBPF)
 test_maps-objs := test_maps.o $(LIBBPF)
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 4ffd8f340496..7ae3b19f5c42 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -14,6 +14,7 @@
 
 #include "bpf_load.h"
 #include "libbpf.h"
+#include "sock_example.h"
 
 #define BPF_F_PIN	(1 << 0)
 #define BPF_F_GET	(1 << 1)
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 09aedc320009..3705fba453a0 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -185,7 +185,4 @@ struct bpf_insn;
 		.off   = 0,					\
 		.imm   = 0 })
 
-/* create RAW socket and bind to interface 'name' */
-int open_raw_sock(const char *name);
-
 #endif
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index 7ab636c30154..bb418fd0a1f2 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -27,6 +27,7 @@
 #include <linux/ip.h>
 #include <stddef.h>
 #include "libbpf.h"
+#include "sock_example.h"
 
 static int test_sock(void)
 {
diff --git a/samples/bpf/libbpf.c b/samples/bpf/sock_example.h
similarity index 92%
rename from samples/bpf/libbpf.c
rename to samples/bpf/sock_example.h
index bee473a494f1..09f7fe7e5fd7 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/sock_example.h
@@ -1,4 +1,3 @@
-/* eBPF mini library */
 #include <stdlib.h>
 #include <stdio.h>
 #include <linux/unistd.h>
@@ -11,7 +10,7 @@
 #include <arpa/inet.h>
 #include "libbpf.h"
 
-int open_raw_sock(const char *name)
+static inline int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
 	int sock;
diff --git a/samples/bpf/sockex1_user.c b/samples/bpf/sockex1_user.c
index 2956d893d732..5cdddc5c9015 100644
--- a/samples/bpf/sockex1_user.c
+++ b/samples/bpf/sockex1_user.c
@@ -3,6 +3,7 @@
 #include <linux/bpf.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "sock_example.h"
 #include <unistd.h>
 #include <arpa/inet.h>
 
diff --git a/samples/bpf/sockex2_user.c b/samples/bpf/sockex2_user.c
index c43958a67cca..7ae4e2e5cf3a 100644
--- a/samples/bpf/sockex2_user.c
+++ b/samples/bpf/sockex2_user.c
@@ -3,6 +3,7 @@
 #include <linux/bpf.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "sock_example.h"
 #include <unistd.h>
 #include <arpa/inet.h>
 #include <sys/resource.h>
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index 2cb9011ea440..a100cf6c95bb 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -3,6 +3,7 @@
 #include <linux/bpf.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "sock_example.h"
 #include <unistd.h>
 #include <arpa/inet.h>
 #include <sys/resource.h>
-- 
2.10.2
