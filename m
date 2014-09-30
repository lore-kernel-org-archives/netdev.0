From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] bpf: add tests to verifier testsuite
Date: Mon, 29 Sep 2014 18:50:02 -0700
Message-ID: <1412041802-24858-3-git-send-email-ast@plumgrid.com>
References: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add 4 extra tests to cover jump verification better

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/test_verifier.c |  130 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 130 insertions(+)

diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index d10992e2740e..f44ef11f65a7 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -461,6 +461,136 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 invalid mem access",
 		.result = REJECT,
 	},
+	{
+		"jump test 1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 5),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"jump test 2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 14),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 5),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"jump test 3",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 19),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 15),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -32),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -40),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 7),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -48),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -56),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {24},
+		.result = ACCEPT,
+	},
+	{
+		"jump test 4",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
1.7.9.5
