From: James Hogan <james.hogan@imgtec.com>
Subject: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Mon, 7 Aug 2017 23:25:14 +0100
Message-ID: <20170807222514.24292-3-james.hogan@imgtec.com>
References: <20170807222514.24292-1-james.hogan@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        James Hogan <james.hogan@imgtec.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807222514.24292-1-james.hogan@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In bpf_trace_printk(), the elements in mod[] are left uninitialised, but
they are then incremented to track the width of the formats. Zero
initialise the array just in case the memory contains non-zero values on
entry.

Fixes: 9c959c863f82 ("tracing: Allow BPF programs to call bpf_trace_printk()")
Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: netdev@vger.kernel.org
---
When I checked (on MIPS32), the elements tended to have the value zero
anyway (does BPF zero the stack or something clever?), so this is a
purely theoretical fix.
---
 kernel/trace/bpf_trace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 32dcbe1b48f2..86a52857d941 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -129,7 +129,7 @@ BPF_CALL_5(bpf_trace_printk, char *, fmt, u32, fmt_size, u64, arg1,
 	   u64, arg2, u64, arg3)
 {
 	bool str_seen = false;
-	int mod[3] = {};
+	int mod[3] = { 0, 0, 0 };
 	int fmt_cnt = 0;
 	u64 unsafe_addr;
 	char buf[64];
-- 
2.13.2
