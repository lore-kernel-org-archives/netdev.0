From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH net-next RESEND] test_bpf: extend tests for 32-bit endianness conversion
Date: Wed,  8 Jul 2015 14:00:56 -0700
Message-ID: <1436389256-28483-1-git-send-email-xi.wang@gmail.com>
Cc: Xi Wang <xi.wang@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36324 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208AbbGHVBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:01:32 -0400
Received: by pddu5 with SMTP id u5so64428764pdd.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:01:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently "ALU_END_FROM_BE 32" and "ALU_END_FROM_LE 32" do not test if
the upper bits of the result are zeros (the arm64 JIT had such bugs).
Extend the two tests to catch this.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
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
