From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: move CONFIG_BPF_SYSCALL-only function declarations
Date: Mon,  2 Mar 2015 15:21:55 +0100
Message-ID: <4564a0e32064e77c4a96a21909423251e251916b.1425305972.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, masami.hiramatsu.pt@hitachi.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34529 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbbCBOV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 09:21:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Masami noted that it would be better to hide the remaining CONFIG_BPF_SYSCALL-only
function declarations within the BPF header ifdef, w/o else path dummy alternatives
since these functions are not supposed to have a user outside of CONFIG_BPF_SYSCALL.

Suggested-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Reference: http://article.gmane.org/gmane.linux.kernel.api/8658
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index a1a7ff2..a884f5a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -42,10 +42,6 @@ struct bpf_map_type_list {
 	enum bpf_map_type type;
 };
 
-void bpf_register_map_type(struct bpf_map_type_list *tl);
-void bpf_map_put(struct bpf_map *map);
-struct bpf_map *bpf_map_get(struct fd f);
-
 /* function argument constraints */
 enum bpf_arg_type {
 	ARG_ANYTHING = 0,	/* any argument is ok */
@@ -126,9 +122,16 @@ struct bpf_prog_aux {
 
 #ifdef CONFIG_BPF_SYSCALL
 void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+void bpf_register_map_type(struct bpf_map_type_list *tl);
 
-void bpf_prog_put(struct bpf_prog *prog);
 struct bpf_prog *bpf_prog_get(u32 ufd);
+void bpf_prog_put(struct bpf_prog *prog);
+
+struct bpf_map *bpf_map_get(struct fd f);
+void bpf_map_put(struct bpf_map *map);
+
+/* verify correctness of eBPF program */
+int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 #else
 static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
 {
@@ -142,10 +145,7 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
-#endif
-
-/* verify correctness of eBPF program */
-int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
+#endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
 extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
-- 
1.9.3
