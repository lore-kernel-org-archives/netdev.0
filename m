From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 17/17] MIPS: bpf: Fix stack space allocation for BPF memwords on MIPS64
Date: Mon, 23 Jun 2014 10:39:00 +0100
Message-ID: <1403516340-22997-18-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:37728 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbaFWJjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:45 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating stack space for BPF memwords we need to use the
appropriate 32 or 64-bit instruction to avoid losing the top 32 bits
of the stack pointer.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index d8dba7b523a5..545c8487542c 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -617,7 +617,10 @@ static void save_bpf_jit_regs(struct jit_ctx *ctx, unsigned offset)
 	if (ctx->flags & SEEN_MEM) {
 		if (real_off % (RSIZE * 2))
 			real_off += RSIZE;
-		emit_addiu(r_M, r_sp, real_off, ctx);
+		if (config_enabled(CONFIG_64BIT))
+			emit_daddiu(r_M, r_sp, real_off, ctx);
+		else
+			emit_addiu(r_M, r_sp, real_off, ctx);
 	}
 }
 
-- 
2.0.0
