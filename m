From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 3/3] bpf: let kprobe programs use bpf_get_smp_processor_id() helper
Date: Fri, 12 Jun 2015 19:39:14 -0700
Message-ID: <1434163154-5218-4-git-send-email-ast@plumgrid.com>
References: <1434163154-5218-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>, lizefan@huawei.com,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434163154-5218-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's useful to do per-cpu histograms.

Suggested-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v1->v2: no changes

 kernel/trace/bpf_trace.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4f9b5d41869b..88a041adee90 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -181,6 +181,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_current_comm_proto;
 	case BPF_FUNC_trace_printk:
 		return bpf_get_trace_printk_proto();
+	case BPF_FUNC_get_smp_processor_id:
+		return &bpf_get_smp_processor_id_proto;
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
