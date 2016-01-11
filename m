From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 1/9] bpf: prepare for moving map common stuff into one place
Date: Mon, 11 Jan 2016 23:56:53 +0800
Message-ID: <1452527821-12276-2-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces some nop functions of map callback
for use in all map implementation.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/Makefile  |  2 +-
 kernel/bpf/bpf_map.h |  9 +++++++++
 kernel/bpf/map.c     | 26 ++++++++++++++++++++++++++
 3 files changed, 36 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/bpf_map.h
 create mode 100644 kernel/bpf/map.c

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 13272582..191d54b 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,4 +1,4 @@
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
-obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o
+obj-$(CONFIG_BPF_SYSCALL) += map.o hashtab.o arraymap.o
diff --git a/kernel/bpf/bpf_map.h b/kernel/bpf/bpf_map.h
new file mode 100644
index 0000000..7e596c1
--- /dev/null
+++ b/kernel/bpf/bpf_map.h
@@ -0,0 +1,9 @@
+#ifndef INT_BPF_MAP_COMMON_H
+#define INT_BPF_MAP_COMMON_H
+
+#include <linux/bpf.h>
+
+extern void *map_lookup_elem_nop(struct bpf_map *map, void *key);
+extern int map_delete_elem_nop(struct bpf_map *map, void *key);
+
+#endif
diff --git a/kernel/bpf/map.c b/kernel/bpf/map.c
new file mode 100644
index 0000000..bf113fb
--- /dev/null
+++ b/kernel/bpf/map.c
@@ -0,0 +1,26 @@
+/*
+ * bpf map common stuff
+ *
+ *	Copyright (c) 2016 Ming Lei
+ *
+ * Authors:
+ *	Ming Lei <tom.leiming@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/bpf.h>
+
+void *map_lookup_elem_nop(struct bpf_map *map, void *key)
+{
+	return NULL;
+}
+
+int map_delete_elem_nop(struct bpf_map *map, void *key)
+{
+	return -EINVAL;
+}
+
-- 
1.9.1
