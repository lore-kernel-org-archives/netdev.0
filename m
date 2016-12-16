From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv5 perf/core 5/5] samples/bpf: Move open_raw_sock to separate header
Date: Fri, 16 Dec 2016 10:32:59 -0800
Message-ID: <20161216183259.14840-6-joe@ovn.org>
References: <20161216183259.14840-1-joe@ovn.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:46843 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756171AbcLPSdV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:33:21 -0500
In-Reply-To: <20161216183259.14840-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function was declared in libbpf.c and was the only remaining
function in this library, but has nothing to do with BPF. Shift it out
into a new header, sock_example.h, and include it from the relevant
samples.

Signed-off-by: Joe Stringer <joe@ovn.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Link: http://lkml.kernel.org/r/20161209024620.31660-8-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
v5: No change.
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
index 5a73f5a7ace1..f01b66f277b0 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -36,7 +36,7 @@ hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 
 # Libbpf dependencies
-LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
+LIBBPF := ../../tools/lib/bpf/bpf.o
 
 test_lru_dist-objs := test_lru_dist.o $(LIBBPF)
 sock_example-objs := sock_example.o $(LIBBPF)
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 6245062844d1..92592e38569b 100644
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
index 5546f8aac37e..6fc6e193ef1b 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -27,6 +27,7 @@
 #include <linux/ip.h>
 #include <stddef.h>
 #include "libbpf.h"
+#include "sock_example.h"
 
 char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
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
index 9454448bf198..6cd2feb3e9b3 100644
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
index 6a40600d5a83..0e0207c90841 100644
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
index 9099c4255f23..b5524d417eb5 100644
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
