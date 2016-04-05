From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH net 4/4] lib/test_bpf: Add additional BPF_ADD tests
Date: Tue,  5 Apr 2016 15:32:56 +0530
Message-ID: <9b71e280481a9f84cd7dbb9e767fd08e6f4c0aef.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of these tests proved useful with the powerpc eBPF JIT port due to
sign-extended 16-bit immediate loads. Though some of these aspects get
covered in other tests, it is better to have explicit tests so as to
quickly tag the precise problem.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 lib/test_bpf.c | 128 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 128 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 2fb31aa..8f22fbe 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -2566,6 +2566,70 @@ static struct bpf_test tests[] = {
 		{ { 0, 0x1 } },
 	},
 	{
+		"ALU_ADD_K: 0 + 0xffff = 0xffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0xffff),
+			BPF_ALU32_IMM(BPF_ADD, R2, 0xffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU_ADD_K: 0 + 0x7fffffff = 0x7fffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0x7fffffff),
+			BPF_ALU32_IMM(BPF_ADD, R2, 0x7fffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU_ADD_K: 0 + 0x80000000 = 0x80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0x80000000),
+			BPF_ALU32_IMM(BPF_ADD, R2, 0x80000000),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU_ADD_K: 0 + 0x80008000 = 0x80008000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0x80008000),
+			BPF_ALU32_IMM(BPF_ADD, R2, 0x80008000),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
 		"ALU64_ADD_K: 1 + 2 = 3",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 1),
@@ -2657,6 +2721,70 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 0x1 } },
 	},
+	{
+		"ALU64_ADD_K: 0 + 0xffff = 0xffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0xffff),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0xffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_ADD_K: 0 + 0x7fffffff = 0x7fffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0x7fffffff),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0x7fffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_ADD_K: 0 + 0x80000000 = 0xffffffff80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0xffffffff80000000LL),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0x80000000),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU_ADD_K: 0 + 0x80008000 = 0xffffffff80008000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0xffffffff80008000LL),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0x80008000),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
 	/* BPF_ALU | BPF_SUB | BPF_X */
 	{
 		"ALU_SUB_X: 3 - 1 = 2",
-- 
2.7.4
