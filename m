From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH net 1/4] lib/test_bpf: Fix JMP_JSET tests
Date: Tue,  5 Apr 2016 15:32:53 +0530
Message-ID: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

JMP_JSET tests incorrectly used BPF_JNE. Fix the same.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 lib/test_bpf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 27a7a26..e76fa4d 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4303,7 +4303,7 @@ static struct bpf_test tests[] = {
 		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 0),
 			BPF_LD_IMM64(R1, 3),
-			BPF_JMP_IMM(BPF_JNE, R1, 2, 1),
+			BPF_JMP_IMM(BPF_JSET, R1, 2, 1),
 			BPF_EXIT_INSN(),
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
@@ -4317,7 +4317,7 @@ static struct bpf_test tests[] = {
 		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 0),
 			BPF_LD_IMM64(R1, 3),
-			BPF_JMP_IMM(BPF_JNE, R1, 0xffffffff, 1),
+			BPF_JMP_IMM(BPF_JSET, R1, 0xffffffff, 1),
 			BPF_EXIT_INSN(),
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
@@ -4474,7 +4474,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 0),
 			BPF_LD_IMM64(R1, 3),
 			BPF_LD_IMM64(R2, 2),
-			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
+			BPF_JMP_REG(BPF_JSET, R1, R2, 1),
 			BPF_EXIT_INSN(),
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
@@ -4489,7 +4489,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 0),
 			BPF_LD_IMM64(R1, 3),
 			BPF_LD_IMM64(R2, 0xffffffff),
-			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
+			BPF_JMP_REG(BPF_JSET, R1, R2, 1),
 			BPF_EXIT_INSN(),
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
-- 
2.7.4
