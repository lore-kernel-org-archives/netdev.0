From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] bpf: Use 1<<16 as ceiling for immediate alignment in
 verifier.
Date: Fri, 12 May 2017 22:28:49 -0400 (EDT)
Message-ID: <20170512.222849.1120569263887485495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdEMC2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 22:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we use 1<<31, then sequences like:

	R1 = 0
	R1 <<= 2

do silly things.  Examples of this actually exist in
the MAP tests of test_verifier.c

Update test_align.c expectation strings.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/bpf/verifier.c                    |  2 +-
 tools/testing/selftests/bpf/test_align.c | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 39f2dcb..0f33db0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1715,7 +1715,7 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 static u32 calc_align(u32 imm)
 {
 	if (!imm)
-		return 1U << 31;
+		return 1U << 16;
 	return imm - ((imm - 1) & imm);
 }
 
diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 9644d4e..afaa297 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -235,12 +235,12 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"4: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=0,r=0) R10=fp",
-			"5: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=14,r=0) R10=fp",
-			"6: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R4=pkt(id=0,off=14,r=0) R5=pkt(id=0,off=14,r=0) R10=fp",
-			"10: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv56 R5=pkt(id=0,off=14,r=18) R10=fp",
-			"14: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
-			"15: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
+			"4: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=0,r=0) R10=fp",
+			"5: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=14,r=0) R10=fp",
+			"6: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R4=pkt(id=0,off=14,r=0) R5=pkt(id=0,off=14,r=0) R10=fp",
+			"10: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv56 R5=pkt(id=0,off=14,r=18) R10=fp",
+			"14: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
+			"15: R0=imm0,min_value=0,max_value=0,min_align=65536 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
 		},
 	},
 	{
-- 
2.1.2.532.g19b5d50
