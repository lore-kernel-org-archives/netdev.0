From: Mircea Gherzan <mgherzan@gmail.com>
Subject: [PATCH] ARM: bpf_jit: BPF_S_ANC_ALU_XOR_X support
Date: Thu,  7 Jun 2012 17:40:18 +0200
Message-ID: <1339083618-15009-1-git-send-email-mgherzan@gmail.com>
Cc: mgherzan@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, davem@davemloft.net
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33746 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab2FGPlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 11:41:06 -0400
Received: by bkcji2 with SMTP id ji2so698804bkc.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 08:41:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

JIT support for the XOR operation introduced by the commit
ffe06c17afbb.

Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
---
 arch/arm/net/bpf_jit_32.c |    5 +++++
 arch/arm/net/bpf_jit_32.h |    4 ++++
 2 files changed, 9 insertions(+)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 62135849..c641fb6 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -762,6 +762,11 @@ b_epilogue:
 			update_on_xread(ctx);
 			emit(ARM_MOV_R(r_A, r_X), ctx);
 			break;
+		case BPF_S_ANC_ALU_XOR_X:
+			/* A ^= X */
+			update_on_xread(ctx);
+			emit(ARM_EOR_R(r_A, r_A, r_X), ctx);
+			break;
 		case BPF_S_ANC_PROTOCOL:
 			/* A = ntohs(skb->protocol) */
 			ctx->seen |= SEEN_SKB;
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index 99ae5e3..7fa2f7d 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -68,6 +68,8 @@
 #define ARM_INST_CMP_R		0x01500000
 #define ARM_INST_CMP_I		0x03500000
 
+#define ARM_INST_EOR_R		0x00200000
+
 #define ARM_INST_LDRB_I		0x05d00000
 #define ARM_INST_LDRB_R		0x07d00000
 #define ARM_INST_LDRH_I		0x01d000b0
@@ -132,6 +134,8 @@
 #define ARM_CMP_R(rn, rm)	_AL3_R(ARM_INST_CMP, 0, rn, rm)
 #define ARM_CMP_I(rn, imm)	_AL3_I(ARM_INST_CMP, 0, rn, imm)
 
+#define ARM_EOR_R(rd, rn, rm)	_AL3_R(ARM_INST_EOR, rd, rn, rm)
+
 #define ARM_LDR_I(rt, rn, off)	(ARM_INST_LDR_I | (rt) << 12 | (rn) << 16 \
 				 | (off))
 #define ARM_LDRB_I(rt, rn, off)	(ARM_INST_LDRB_I | (rt) << 12 | (rn) << 16 \
-- 
1.7.10
