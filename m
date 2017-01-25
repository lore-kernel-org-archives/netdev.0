From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 15/23] tools lib bpf: Define prog_type fns with macro
Date: Wed, 25 Jan 2017 10:53:42 -0300
Message-ID: <20170125135350.22983-16-acme@kernel.org>
References: <20170125135350.22983-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170125135350.22983-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe@ovn.org>

Turning this into a macro allows future prog types to be added with a
single line per type.

Signed-off-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170123011128.26534-3-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/bpf/libbpf.c | 41 ++++++++++++++++-------------------------
 1 file changed, 16 insertions(+), 25 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 671d5ad07cf1..371cb40a2304 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1428,37 +1428,28 @@ static void bpf_program__set_type(struct bpf_program *prog,
 	prog->type = type;
 }
 
-int bpf_program__set_tracepoint(struct bpf_program *prog)
-{
-	if (!prog)
-		return -EINVAL;
-	bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
-	return 0;
-}
-
-int bpf_program__set_kprobe(struct bpf_program *prog)
-{
-	if (!prog)
-		return -EINVAL;
-	bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
-	return 0;
-}
-
 static bool bpf_program__is_type(struct bpf_program *prog,
 				 enum bpf_prog_type type)
 {
 	return prog ? (prog->type == type) : false;
 }
 
-bool bpf_program__is_tracepoint(struct bpf_program *prog)
-{
-	return bpf_program__is_type(prog, BPF_PROG_TYPE_TRACEPOINT);
-}
-
-bool bpf_program__is_kprobe(struct bpf_program *prog)
-{
-	return bpf_program__is_type(prog, BPF_PROG_TYPE_KPROBE);
-}
+#define BPF_PROG_TYPE_FNS(NAME, TYPE)			\
+int bpf_program__set_##NAME(struct bpf_program *prog)	\
+{							\
+	if (!prog)					\
+		return -EINVAL;				\
+	bpf_program__set_type(prog, TYPE);		\
+	return 0;					\
+}							\
+							\
+bool bpf_program__is_##NAME(struct bpf_program *prog)	\
+{							\
+	return bpf_program__is_type(prog, TYPE);	\
+}							\
+
+BPF_PROG_TYPE_FNS(kprobe, BPF_PROG_TYPE_KPROBE);
+BPF_PROG_TYPE_FNS(tracepoint, BPF_PROG_TYPE_TRACEPOINT);
 
 int bpf_map__fd(struct bpf_map *map)
 {
-- 
2.9.3
