From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next 3/3] samples/bpf: check before defining offsetof
Date: Mon, 24 Apr 2017 15:31:08 +0200
Message-ID: <20170424133108.31595-4-alexander@alemayhu.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
Cc: Alexander Alemayhu <alexander@alemayhu.com>, daniel@iogearbox.net,
        ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33782 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1171341AbdDXNbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:31:32 -0400
Received: by mail-lf0-f54.google.com with SMTP id 88so73891872lfr.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 06:31:31 -0700 (PDT)
In-Reply-To: <20170424133108.31595-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following warning

samples/bpf/test_lru_dist.c:28:0: warning: "offsetof" redefined
 #define offsetof(TYPE, MEMBER) ((size_t)&((TYPE *)0)->MEMBER)

In file included from ./tools/lib/bpf/bpf.h:25:0,
                 from samples/bpf/libbpf.h:5,
                 from samples/bpf/test_lru_dist.c:24:
/usr/lib/gcc/x86_64-redhat-linux/6.3.1/include/stddef.h:417:0: note: this is the location of the previous definition
 #define offsetof(TYPE, MEMBER) __builtin_offsetof (TYPE, MEMBER)

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 samples/bpf/test_lru_dist.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/test_lru_dist.c b/samples/bpf/test_lru_dist.c
index d96dc88d3b04..73c357142268 100644
--- a/samples/bpf/test_lru_dist.c
+++ b/samples/bpf/test_lru_dist.c
@@ -25,7 +25,9 @@
 #include "bpf_util.h"
 
 #define min(a, b) ((a) < (b) ? (a) : (b))
-#define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
+#ifndef offsetof
+# define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
+#endif
 #define container_of(ptr, type, member) ({			\
 	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
 	(type *)( (char *)__mptr - offsetof(type,member) );})
-- 
2.9.3
