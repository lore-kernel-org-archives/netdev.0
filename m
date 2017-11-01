From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf: minor cleanups after merge
Date: Wed,  1 Nov 2017 23:58:09 +0100
Message-ID: <d8fa1fc37a2c8b39eee142c5dd0e6de36a58493d.1509576758.git.daniel@iogearbox.net>
References: <cover.1509576758.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55614 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753175AbdKAW60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 18:58:26 -0400
In-Reply-To: <cover.1509576758.git.daniel@iogearbox.net>
In-Reply-To: <cover.1509576758.git.daniel@iogearbox.net>
References: <cover.1509576758.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor cleanups after Dave's recent merge in f8ddadc4db6c
("Merge git://git.kernel.org...") of net into net-next in
order to get the code in line with what was done originally
in the net tree: i) use max() instead of max_t() since both
ranges are u16, ii) don't split the direct access test cases
in the middle with bpf_exit test cases from 390ee7e29fc
("bpf: enforce return code for cgroup-bpf programs").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/verifier.c                       |   2 +-
 tools/testing/selftests/bpf/test_verifier.c | 144 ++++++++++++++--------------
 2 files changed, 73 insertions(+), 73 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2bb6d6a..2cc3e94 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2532,7 +2532,7 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 			continue;
 		reg = &state->stack[i].spilled_ptr;
 		if (reg->type == type && reg->id == dst_reg->id)
-			reg->range = max_t(u16, reg->range, new_range);
+			reg->range = max(reg->range, new_range);
 	}
 }
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 1b93941..3b38a3d 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -7250,78 +7250,6 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_XDP,
 	},
 	{
-		"bpf_exit with invalid return code. test1",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 has value (0x0; 0xffffffff)",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test2",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
-			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test3",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
-			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 3),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 has value (0x0; 0x3)",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test4",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test5",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_0, 2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 has value (0x2; 0x0)",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test6",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 is not a known value (ctx)",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
-		"bpf_exit with invalid return code. test7",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 4),
-			BPF_ALU64_REG(BPF_MUL, BPF_REG_0, BPF_REG_2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 has unknown scalar value",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
-	},
-	{
 		"XDP pkt read, pkt_end >= pkt_data', bad access 1",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
@@ -7470,6 +7398,78 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_XDP,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
+	{
+		"bpf_exit with invalid return code. test1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x0; 0xffffffff)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test2",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x0; 0x3)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test5",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x2; 0x0)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test6",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 is not a known value (ctx)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test7",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 4),
+			BPF_ALU64_REG(BPF_MUL, BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has unknown scalar value",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
1.9.3
