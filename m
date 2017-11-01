From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/2] nfp: bpf: rename ALU_OP_NEG to ALU_OP_NOT
Date: Wed,  1 Nov 2017 10:38:24 -0700
Message-ID: <20171101173825.7008-2-jakub.kicinski@netronome.com>
References: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, Jiong Wang <jiong.wang@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:53522 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdKARib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:38:31 -0400
Received: by mail-pg0-f66.google.com with SMTP id s2so2683886pge.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:38:31 -0700 (PDT)
In-Reply-To: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiong Wang <jiong.wang@netronome.com>

The current ALU_OP_NEG is Op encoding 0x4 for NPF ALU instruction. It is
actually performing "~B" operation which is bitwise NOT.

The using naming ALU_OP_NEG is misleading as NEG is -B which is not the
same as ~B.

Signed-off-by: Jiong Wang <jiong.wang@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index e7eeb7a07f81..369173100fcf 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -944,7 +944,7 @@ wrp_alu_imm(struct nfp_prog *nfp_prog, u8 dst, enum alu_op alu_op, u32 imm)
 	if (alu_op == ALU_OP_XOR) {
 		if (!~imm)
 			emit_alu(nfp_prog, reg_both(dst), reg_none(),
-				 ALU_OP_NEG, reg_b(dst));
+				 ALU_OP_NOT, reg_b(dst));
 		if (!imm || !~imm)
 			return;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index f4d1df3a1925..74d0c11ab2f9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -174,7 +174,7 @@ enum shf_sc {
 enum alu_op {
 	ALU_OP_NONE	= 0x00,
 	ALU_OP_ADD	= 0x01,
-	ALU_OP_NEG	= 0x04,
+	ALU_OP_NOT	= 0x04,
 	ALU_OP_AND	= 0x08,
 	ALU_OP_SUB_C	= 0x0d,
 	ALU_OP_ADD_C	= 0x11,
-- 
2.14.1
