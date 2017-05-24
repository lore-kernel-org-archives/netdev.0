From: David Daney <david.daney@cavium.com>
Subject: [PATCH] test_bpf: Add a couple of tests for BPF_JSGE.
Date: Wed, 24 May 2017 16:35:49 -0700
Message-ID: <20170524233549.18388-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some JITs can optimize comparisons with zero.  Add a couple of
BPF_JSGE tests against immediate zero.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 lib/test_bpf.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 889bc31..be88cba 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4504,6 +4504,44 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 1 } },
 	},
+	{
+		"JMP_JSGE_K: Signed jump: value walk 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -3),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 6),
+			BPF_ALU64_IMM(BPF_ADD, R1, 1),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 4),
+			BPF_ALU64_IMM(BPF_ADD, R1, 1),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 2),
+			BPF_ALU64_IMM(BPF_ADD, R1, 1),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 1),
+			BPF_EXIT_INSN(),		/* bad exit */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),	/* good exit */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSGE_K: Signed jump: value walk 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -3),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 4),
+			BPF_ALU64_IMM(BPF_ADD, R1, 2),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 2),
+			BPF_ALU64_IMM(BPF_ADD, R1, 2),
+			BPF_JMP_IMM(BPF_JSGE, R1, 0, 1),
+			BPF_EXIT_INSN(),		/* bad exit */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),	/* good exit */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JGT | BPF_K */
 	{
 		"JMP_JGT_K: if (3 > 2) return 1",
-- 
2.9.4
