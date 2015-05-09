From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH net-next] test: bpf: extend "load 64-bit immediate" testcase
Date: Sat,  9 May 2015 04:14:30 -0400
Message-ID: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Xi Wang <xi.wang@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Will Deacon <will.deacon@arm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend the testcase to catch a signedness bug in the arm64 JIT:

test_bpf: #58 load 64-bit immediate jited:1 ret -1 != 1 FAIL (1 times)

This is useful to ensure other JITs won't have a similar bug.

Link: https://lkml.org/lkml/2015/5/8/458
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 lib/test_bpf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index f2c23ffaa6d7..3c41049d72d8 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1755,7 +1755,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 			BPF_JMP_IMM(BPF_JEQ, R3, 0x1234, 1),
 			BPF_EXIT_INSN(),
-			BPF_ALU64_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R0, 0x1ffffffffLL),
+			BPF_ALU64_IMM(BPF_RSH, R0, 32), /* R0 = 1 */
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
-- 
1.9.1
