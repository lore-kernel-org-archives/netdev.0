From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH net-next] test_bpf: extend tests for 32-bit endianness conversion
Date: Fri, 26 Jun 2015 08:25:20 -0700
Message-ID: <1435332320-6476-1-git-send-email-xi.wang@gmail.com>
Cc: linux-kernel@vger.kernel.org, Xi Wang <xi.wang@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33999 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbFZPZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 11:25:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently "ALU_END_FROM_BE 32" and "ALU_END_FROM_LE 32" do not test if
the upper bits of the result are zeros (the arm64 JIT had such bugs).
Extend the two tests to catch this.

Cc: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
See the arm64 JIT bugs:

https://lkml.org/lkml/2015/6/25/721
---
 lib/test_bpf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 7f58c73..9198f28 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -3674,6 +3674,9 @@ static struct bpf_test tests[] = {
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
 			BPF_ENDIAN(BPF_FROM_BE, R0, 32),
+			BPF_ALU64_REG(BPF_MOV, R1, R0),
+			BPF_ALU64_IMM(BPF_RSH, R1, 32),
+			BPF_ALU32_REG(BPF_ADD, R0, R1), /* R1 = 0 */
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -3708,6 +3711,9 @@ static struct bpf_test tests[] = {
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
 			BPF_ENDIAN(BPF_FROM_LE, R0, 32),
+			BPF_ALU64_REG(BPF_MOV, R1, R0),
+			BPF_ALU64_IMM(BPF_RSH, R1, 32),
+			BPF_ALU32_REG(BPF_ADD, R0, R1), /* R1 = 0 */
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
-- 
2.1.4
