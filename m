From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] bpf, s390: fix build for libbpf and selftest suite
Date: Fri,  4 Aug 2017 14:20:55 +0200
Message-ID: <4c18cdbfad03bded866c2ae3a05b8648213acf01.1501848914.git.daniel@iogearbox.net>
References: <cover.1501848914.git.daniel@iogearbox.net>
Cc: holzheu@linux.vnet.ibm.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58279 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbdHDMVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:21:00 -0400
In-Reply-To: <cover.1501848914.git.daniel@iogearbox.net>
In-Reply-To: <cover.1501848914.git.daniel@iogearbox.net>
References: <cover.1501848914.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BPF feature test as well as libbpf is missing the __NR_bpf
define for s390 and currently refuses to compile (selftest suite
depends on libbpf as well). Similar issue was fixed some time
ago via b0c47807d31d ("bpf: Add sparc support to tools and
samples."), just do the same and add definitions.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/build/feature/test-bpf.c | 2 ++
 tools/lib/bpf/bpf.c            | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/tools/build/feature/test-bpf.c b/tools/build/feature/test-bpf.c
index 7598361..da2172f 100644
--- a/tools/build/feature/test-bpf.c
+++ b/tools/build/feature/test-bpf.c
@@ -11,6 +11,8 @@
 #  define __NR_bpf 280
 # elif defined(__sparc__)
 #  define __NR_bpf 349
+# elif defined(__s390__)
+#  define __NR_bpf 351
 # else
 #  error __NR_bpf not defined. libbpf does not support your arch.
 # endif
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 256f571..e5bbb09 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -39,6 +39,8 @@
 #  define __NR_bpf 280
 # elif defined(__sparc__)
 #  define __NR_bpf 349
+# elif defined(__s390__)
+#  define __NR_bpf 351
 # else
 #  error __NR_bpf not defined. libbpf does not support your arch.
 # endif
-- 
1.9.3
