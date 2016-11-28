From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] bpf: samples: Fix compile of test_lru_dist.c
Date: Sun, 27 Nov 2016 20:32:19 -0800
Message-ID: <1480307539-30187-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33881 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753353AbcK1EcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 23:32:25 -0500
Received: by mail-pf0-f172.google.com with SMTP id c4so22347364pfb.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 20:32:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Build of samples/bpf on debian/jessie fails with:

  HOSTCC  /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.o
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c: In function ‘main’:
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: error: variable ‘r’ has initializer but incomplete type
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
         ^
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: error: ‘RLIM_INFINITY’ undeclared (first use in this function)
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
                     ^
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: note: each undeclared identifier is reported only once for each function it appears in
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: excess elements in struct initializer
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
         ^
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near initialization for ‘r’)
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: excess elements in struct initializer
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near initialization for ‘r’)
/home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:16: error: storage size of ‘r’ isn’t known
  struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

Add sys/resource.h to the include list

Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Cc: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/test_lru_dist.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/samples/bpf/test_lru_dist.c b/samples/bpf/test_lru_dist.c
index 2859977b7f37..bc4a2142eb91 100644
--- a/samples/bpf/test_lru_dist.c
+++ b/samples/bpf/test_lru_dist.c
@@ -16,6 +16,7 @@
 #include <sched.h>
 #include <sys/wait.h>
 #include <sys/stat.h>
+#include <sys/resource.h>
 #include <fcntl.h>
 #include <stdlib.h>
 #include <time.h>
-- 
2.1.4
