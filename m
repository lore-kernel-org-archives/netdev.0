From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 8/8] PPC: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT
Date: Mon, 31 Dec 2012 14:59:48 +0100
Message-ID: <1238fc2b4409419f2f1098ba9c7fd74fe09121a4.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164Ab2LaOQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 09:16:14 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add neq jump
operations to bpf machine" that implements BPF PowerPC JIT
parts for the BPF JMP_NEQ operation.

Cc: Matt Evans <matt@ozlabs.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/powerpc/net/bpf_jit_comp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 46b4d21..4b9ee59 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -496,6 +496,8 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		case BPF_S_JMP_JEQ_X:
 			true_cond = COND_EQ;
 			goto cond_branch;
+		case BPF_S_JMP_JNEQ_K:
+		case BPF_S_JMP_JNEQ_X:
 		case BPF_S_JMP_JSET_K:
 		case BPF_S_JMP_JSET_X:
 			true_cond = COND_NE;
@@ -514,6 +516,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			case BPF_S_JMP_JLT_X:
 			case BPF_S_JMP_JLE_X:
 			case BPF_S_JMP_JEQ_X:
+			case BPF_S_JMP_JNEQ_X:
 				ctx->seen |= SEEN_XREG;
 				PPC_CMPLW(r_A, r_X);
 				break;
@@ -522,6 +525,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				PPC_AND_DOT(r_scratch1, r_A, r_X);
 				break;
 			case BPF_S_JMP_JEQ_K:
+			case BPF_S_JMP_JNEQ_K:
 			case BPF_S_JMP_JGT_K:
 			case BPF_S_JMP_JGE_K:
 			case BPF_S_JMP_JLT_K:
-- 
1.7.11.7
