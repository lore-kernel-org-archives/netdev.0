From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 04/17] MIPS: bpf: Use the LO register to get division's quotient
Date: Mon, 23 Jun 2014 10:38:47 +0100
Message-ID: <1403516340-22997-5-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:31289 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaFWJj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:28 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading from the HI register to get the division result is wrong.
The quotient is placed in the LO register.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index f7c206404989..5cc92c4590cb 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -408,7 +408,7 @@ static inline void emit_div(unsigned int dst, unsigned int src,
 		u32 *p = &ctx->target[ctx->idx];
 		uasm_i_divu(&p, dst, src);
 		p = &ctx->target[ctx->idx + 1];
-		uasm_i_mfhi(&p, dst);
+		uasm_i_mflo(&p, dst);
 	}
 	ctx->idx += 2; /* 2 insts */
 }
-- 
2.0.0
