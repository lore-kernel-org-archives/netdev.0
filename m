From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 2/7] tools lib bpf: use __u32 from linux/types.h
Date: Thu,  8 Dec 2016 18:46:15 -0800
Message-ID: <20161209024620.31660-3-joe@ovn.org>
References: <20161209024620.31660-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        acme@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes the following issue when building without access to 'u32' type:

./tools/lib/bpf/bpf.h:27:23: error: unknown type name ‘u32’

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: Split from "tools lib bpf: Sync with samples/bpf/libbpf"
---
 tools/lib/bpf/bpf.c | 4 ++--
 tools/lib/bpf/bpf.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 8143536b462a..89e8e8e5b60e 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -70,7 +70,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
 
 int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 		     size_t insns_cnt, char *license,
-		     u32 kern_version, char *log_buf, size_t log_buf_sz)
+		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
 {
 	int fd;
 	union bpf_attr attr;
@@ -98,7 +98,7 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 }
 
 int bpf_map_update_elem(int fd, void *key, void *value,
-			u64 flags)
+			__u64 flags)
 {
 	union bpf_attr attr;
 
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 253c3dbb06b4..61130170a6ad 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -30,11 +30,11 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 #define BPF_LOG_BUF_SIZE 65536
 int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 		     size_t insns_cnt, char *license,
-		     u32 kern_version, char *log_buf,
+		     __u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
 
 int bpf_map_update_elem(int fd, void *key, void *value,
-			u64 flags);
+			__u64 flags);
 
 int bpf_map_lookup_elem(int fd, void *key, void *value);
 int bpf_map_delete_elem(int fd, void *key);
-- 
2.10.2
