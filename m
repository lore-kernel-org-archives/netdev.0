From: Eric Leblond <eric@regit.org>
Subject: [PATCH 1/8] tools lib bpf: add error functions
Date: Sun, 16 Oct 2016 23:18:27 +0200
Message-ID: <20161016211834.11732-2-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45250 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757058AbcJPVVP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:15 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The include of err.h is not explicitely needed in exported
functions and it was causing include conflict with some existing
code due to redefining some macros.

To fix this, let's have error handling functions provided by the
library. Furthermore this will allow user to have an homogeneous
API.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 11 +++++++++++
 tools/lib/bpf/libbpf.h |  4 +++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index b699aea..90932f1 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -31,6 +31,7 @@
 #include <linux/kernel.h>
 #include <linux/bpf.h>
 #include <linux/list.h>
+#include <linux/err.h>
 #include <libelf.h>
 #include <gelf.h>
 
@@ -1447,3 +1448,13 @@ bpf_object__find_map_by_name(struct bpf_object *obj, const char *name)
 	}
 	return NULL;
 }
+
+bool bpf__is_error(const void *ptr)
+{
+	return IS_ERR(ptr);
+}
+
+long bpf__get_error(const void *ptr)
+{
+	return PTR_ERR(ptr);
+}
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index dd7a513..e40c8d3 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -23,7 +23,6 @@
 
 #include <stdio.h>
 #include <stdbool.h>
-#include <linux/err.h>
 
 enum libbpf_errno {
 	__LIBBPF_ERRNO__START = 4000,
@@ -211,4 +210,7 @@ int bpf_map__set_priv(struct bpf_map *map, void *priv,
 		      bpf_map_clear_priv_t clear_priv);
 void *bpf_map__priv(struct bpf_map *map);
 
+bool bpf__is_error(const void *ptr);
+long bpf__get_error(const void *ptr);
+
 #endif
-- 
2.9.3
