From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v5 10/11] bpf: Remove bpf_sys.h from selftests
Date: Fri, 10 Feb 2017 00:21:44 +0100
Message-ID: <20170209232145.19085-11-mic@digikod.net>
References: <20170209232145.19085-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:35534 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdBJAkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 19:40:32 -0500
In-Reply-To: <20170209232145.19085-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add require dependency headers.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                         |  6 ++++++
 tools/testing/selftests/bpf/bpf_sys.h       | 27 ---------------------------
 tools/testing/selftests/bpf/test_lpm_map.c  |  1 -
 tools/testing/selftests/bpf/test_lru_map.c  |  1 -
 tools/testing/selftests/bpf/test_maps.c     |  1 -
 tools/testing/selftests/bpf/test_tag.c      |  3 +--
 tools/testing/selftests/bpf/test_verifier.c |  4 ++--
 7 files changed, 9 insertions(+), 34 deletions(-)
 delete mode 100644 tools/testing/selftests/bpf/bpf_sys.h

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index f8a2b7fa7741..50e04cc5dddd 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -50,7 +50,13 @@ static __u64 ptr_to_u64(const void *ptr)
 static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
 		   unsigned int size)
 {
+#ifdef __NR_bpf
 	return syscall(__NR_bpf, cmd, attr, size);
+#else
+	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
+	errno = ENOSYS;
+	return -1;
+#endif
 }
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size,
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
deleted file mode 100644
index aa076a8a07f7..000000000000
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ /dev/null
@@ -1,27 +0,0 @@
-#ifndef __BPF_SYS__
-#define __BPF_SYS__
-
-#include <stdint.h>
-#include <stdlib.h>
-
-#include <sys/syscall.h>
-
-#include <linux/bpf.h>
-
-static inline __u64 bpf_ptr_to_u64(const void *ptr)
-{
-	return (__u64)(unsigned long) ptr;
-}
-
-static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
-{
-#ifdef __NR_bpf
-	return syscall(__NR_bpf, cmd, attr, size);
-#else
-	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
-	errno = ENOSYS;
-	return -1;
-#endif
-}
-
-#endif /* __BPF_SYS__ */
diff --git a/tools/testing/selftests/bpf/test_lpm_map.c b/tools/testing/selftests/bpf/test_lpm_map.c
index 3cc812cac2d7..e97565243d59 100644
--- a/tools/testing/selftests/bpf/test_lpm_map.c
+++ b/tools/testing/selftests/bpf/test_lpm_map.c
@@ -23,7 +23,6 @@
 #include <sys/resource.h>
 
 #include <bpf/bpf.h>
-#include "bpf_sys.h"
 #include "bpf_util.h"
 
 struct tlpm_node {
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 48973ded1c96..00b0aff56e2e 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -19,7 +19,6 @@
 #include <sys/resource.h>
 
 #include <bpf/bpf.h>
-#include "bpf_sys.h"
 #include "bpf_util.h"
 
 #define LOCAL_FREE_TARGET	(128)
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 39168499f43f..cada17ac00b8 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -22,7 +22,6 @@
 #include <linux/bpf.h>
 
 #include <bpf/bpf.h>
-#include "bpf_sys.h"
 #include "bpf_util.h"
 
 static int map_flags;
diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
index ae4263638cd5..de409fc50c35 100644
--- a/tools/testing/selftests/bpf/test_tag.c
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -1,3 +1,4 @@
+#include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <ctype.h>
@@ -20,8 +21,6 @@
 
 #include "../../../include/linux/filter.h"
 
-#include "bpf_sys.h"
-
 static struct bpf_insn prog[BPF_MAXINSNS];
 
 static void bpf_gen_imm_prog(unsigned int insns, int fd_map)
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 63818cbb9fb1..e1f5b9eea1e8 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -8,7 +8,9 @@
  * License as published by the Free Software Foundation.
  */
 
+#include <stdint.h>
 #include <stdio.h>
+#include <stdlib.h>
 #include <unistd.h>
 #include <errno.h>
 #include <string.h>
@@ -28,8 +30,6 @@
 
 #include "../../../include/linux/filter.h"
 
-#include "bpf_sys.h"
-
 #ifndef ARRAY_SIZE
 # define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
-- 
2.11.0
