From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 3/7] tools lib bpf: Add flags to bpf_create_map()
Date: Thu,  8 Dec 2016 18:46:16 -0800
Message-ID: <20161209024620.31660-4-joe@ovn.org>
References: <20161209024620.31660-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The map_flags argument to bpf_create_map() was previously not exposed.
By exposing it, users can access flags such as whether or not to
preallocate the map.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: Split from "tools lib bpf: Sync with samples/bpf/libbpf".
---
 tools/lib/bpf/bpf.c    | 3 ++-
 tools/lib/bpf/bpf.h    | 2 +-
 tools/lib/bpf/libbpf.c | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 89e8e8e5b60e..d0afb26c2e0f 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -54,7 +54,7 @@ static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
 }
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size,
-		   int value_size, int max_entries)
+		   int value_size, int max_entries, __u32 map_flags)
 {
 	union bpf_attr attr;
 
@@ -64,6 +64,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
 	attr.key_size = key_size;
 	attr.value_size = value_size;
 	attr.max_entries = max_entries;
+	attr.map_flags = map_flags;
 
 	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 61130170a6ad..7fcdce16fd62 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -24,7 +24,7 @@
 #include <linux/bpf.h>
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries);
+		   int max_entries, __u32 map_flags);
 
 /* Recommend log buffer size */
 #define BPF_LOG_BUF_SIZE 65536
diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 2e974593f3e8..84e6b35da4bd 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -854,7 +854,8 @@ bpf_object__create_maps(struct bpf_object *obj)
 		*pfd = bpf_create_map(def->type,
 				      def->key_size,
 				      def->value_size,
-				      def->max_entries);
+				      def->max_entries,
+				      0);
 		if (*pfd < 0) {
 			size_t j;
 			int err = *pfd;
-- 
2.10.2
