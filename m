From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: make tracing helpers gpl only
Date: Fri, 23 Oct 2015 14:58:19 -0700
Message-ID: <1445637499-11146-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

exported perf symbols are GPL only, mark eBPF helper functions
used in tracing as GPL only as well.

Suggested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
this is on top of this patch that touches the same file:
http://patchwork.ozlabs.org/patch/534664/

 kernel/trace/bpf_trace.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 003df3887287..4228fd3682c3 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -214,7 +214,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 
 static const struct bpf_func_proto bpf_perf_event_read_proto = {
 	.func		= bpf_perf_event_read,
-	.gpl_only	= false,
+	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_CONST_MAP_PTR,
 	.arg2_type	= ARG_ANYTHING,
@@ -255,7 +255,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
 
 static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.func		= bpf_perf_event_output,
-	.gpl_only	= false,
+	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_CONST_MAP_PTR,
-- 
1.7.9.5
