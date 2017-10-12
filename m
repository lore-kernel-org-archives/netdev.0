From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/12] nfp: bpf: add missing return in jne_imm optimization
Date: Thu, 12 Oct 2017 10:34:09 -0700
Message-ID: <20171012173418.4029-4-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:49194 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbdJLRev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:51 -0400
Received: by mail-pf0-f169.google.com with SMTP id l188so5841901pfc.6
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:51 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We optimize comparisons to immediate 0 as if (reg.lo | reg.hi).
The early return statement was missing, however, which means we
would generate two comparisons - optimized one followed by a
normal 2x 32 bit compare.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index cf8a6eb3ec99..5ac834e91aed 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1191,6 +1191,7 @@ static int jne_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 		emit_alu(nfp_prog, reg_none(), reg_a(insn->dst_reg * 2),
 			 ALU_OP_OR, reg_b(insn->dst_reg * 2 + 1));
 		emit_br(nfp_prog, BR_BNE, insn->off, 0);
+		return 0;
 	}
 
 	tmp_reg = ur_load_imm_any(nfp_prog, imm & ~0U, imm_b(nfp_prog));
-- 
2.14.1
