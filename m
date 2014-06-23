From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 08/17] MIPS: bpf: Fix branch conditional for BPF_J{GT/GE} cases
Date: Mon, 23 Jun 2014 10:38:51 +0100
Message-ID: <1403516340-22997-9-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:59116 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbaFWJjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:33 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sltiu and sltu instructions will set the scratch register
to 1 if A <= X|K so fix the emitted branch conditional to check
for scratch != zero rather than scratch >= zero which would complicate
the resuling branch logic given that MIPS does not have a BGT or BGET
instructions to compare general purpose registers directly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 8cae27af03da..500f97fdc0e1 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1127,7 +1127,7 @@ jmp_cmp:
 				}
 				/* A < (K|X) ? r_scrach = 1 */
 				b_off = b_imm(i + inst->jf + 1, ctx);
-				emit_bcond(MIPS_COND_GT, r_s0, r_zero, b_off,
+				emit_bcond(MIPS_COND_NE, r_s0, r_zero, b_off,
 					   ctx);
 				emit_nop(ctx);
 				/* A > (K|X) ? scratch = 0 */
-- 
2.0.0
