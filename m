From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master] bpf: provide fallback defs for __NR_bpf when not avail
Date: Thu, 15 Jun 2017 00:47:15 +0200
Message-ID: <b59b84be59bccbab994072fdd9969b5d8a483f12.1497480167.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44353 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752500AbdFNWr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 18:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

panji reported that he wasn't able to build iproute2's bpf library
due to lack of __NR_bpf in his system headers. Providing a fallback
definition when __NR_bpf is not available in the system lets the
loader compile just fine, so lets add them for majority of archs.

Reported-by: panji <jpan@live.nl>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/lib/bpf.c b/lib/bpf.c
index ae4d97d..e1e29cc 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -128,6 +128,26 @@ static inline __u64 bpf_ptr_to_u64(const void *ptr)
 	return (__u64)(unsigned long)ptr;
 }
 
+#ifndef __NR_bpf
+# if defined(__i386__)
+#  define __NR_bpf 357
+# elif defined(__x86_64__)
+#  define __NR_bpf 321
+# elif defined(__aarch64__)
+#  define __NR_bpf 280
+# elif defined(__sparc__)
+#  define __NR_bpf 349
+# elif defined(__arm__)
+#  define __NR_bpf 386
+# elif defined(__powerpc__)
+#  define __NR_bpf 361
+# elif defined(__s390__)
+#  define __NR_bpf 351
+# else
+#  error __NR_bpf not defined. Update kernel headers.
+# endif
+#endif
+
 static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 {
 #ifdef __NR_bpf
-- 
1.9.3
