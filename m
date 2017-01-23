From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 3/7] tools lib bpf: Add set/is helpers for all prog types
Date: Sun, 22 Jan 2017 17:11:24 -0800
Message-ID: <20170123011128.26534-4-joe@ovn.org>
References: <20170123011128.26534-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123011128.26534-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These bpf_prog_types were exposed in the uapi but there were no
corresponding functions to set these types for programs in libbpf.

Signed-off-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
---
v2: Add ack.
---
 tools/lib/bpf/libbpf.c |  5 +++++
 tools/lib/bpf/libbpf.h | 10 ++++++++++
 2 files changed, 15 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 371cb40a2304..406838fa9c4f 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1448,8 +1448,13 @@ bool bpf_program__is_##NAME(struct bpf_program *prog)	\
 	return bpf_program__is_type(prog, TYPE);	\
 }							\
 
+BPF_PROG_TYPE_FNS(socket_filter, BPF_PROG_TYPE_SOCKET_FILTER);
 BPF_PROG_TYPE_FNS(kprobe, BPF_PROG_TYPE_KPROBE);
+BPF_PROG_TYPE_FNS(sched_cls, BPF_PROG_TYPE_SCHED_CLS);
+BPF_PROG_TYPE_FNS(sched_act, BPF_PROG_TYPE_SCHED_ACT);
 BPF_PROG_TYPE_FNS(tracepoint, BPF_PROG_TYPE_TRACEPOINT);
+BPF_PROG_TYPE_FNS(xdp, BPF_PROG_TYPE_XDP);
+BPF_PROG_TYPE_FNS(perf_event, BPF_PROG_TYPE_PERF_EVENT);
 
 int bpf_map__fd(struct bpf_map *map)
 {
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index a5a8b86a06fe..2188ccdc0e2d 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -174,11 +174,21 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n);
 /*
  * Adjust type of bpf program. Default is kprobe.
  */
+int bpf_program__set_socket_filter(struct bpf_program *prog);
 int bpf_program__set_tracepoint(struct bpf_program *prog);
 int bpf_program__set_kprobe(struct bpf_program *prog);
+int bpf_program__set_sched_cls(struct bpf_program *prog);
+int bpf_program__set_sched_act(struct bpf_program *prog);
+int bpf_program__set_xdp(struct bpf_program *prog);
+int bpf_program__set_perf_event(struct bpf_program *prog);
 
+bool bpf_program__is_socket_filter(struct bpf_program *prog);
 bool bpf_program__is_tracepoint(struct bpf_program *prog);
 bool bpf_program__is_kprobe(struct bpf_program *prog);
+bool bpf_program__is_sched_cls(struct bpf_program *prog);
+bool bpf_program__is_sched_act(struct bpf_program *prog);
+bool bpf_program__is_xdp(struct bpf_program *prog);
+bool bpf_program__is_perf_event(struct bpf_program *prog);
 
 /*
  * We don't need __attribute__((packed)) now since it is
-- 
2.11.0
