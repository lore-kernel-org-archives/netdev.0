From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 7/8] sparc: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT
Date: Mon, 31 Dec 2012 14:59:47 +0100
Message-ID: <58f3f55effbff9f5082ab97f15ef9ba65c523e60.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216Ab2LaOiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 09:38:51 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add neq jump
operations to bpf machine" that implements BPF Sparc JIT parts
for the BPF JMP_NEQ operation.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/sparc/net/bpf_jit_comp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index f5b4fc9..5da318c 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -694,12 +694,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 			COND_SEL(BPF_S_JMP_JLT_K, BLU, BGEU);
 			COND_SEL(BPF_S_JMP_JLE_K, BLEU, BGU);
 			COND_SEL(BPF_S_JMP_JEQ_K, BE, BNE);
+			COND_SEL(BPF_S_JMP_JNEQ_K, BNE, BE);
 			COND_SEL(BPF_S_JMP_JSET_K, BNE, BE);
 			COND_SEL(BPF_S_JMP_JGT_X, BGU, BLEU);
 			COND_SEL(BPF_S_JMP_JGE_X, BGEU, BLU);
 			COND_SEL(BPF_S_JMP_JLT_X, BLU, BGEU);
 			COND_SEL(BPF_S_JMP_JLE_X, BLEU, BGU);
 			COND_SEL(BPF_S_JMP_JEQ_X, BE, BNE);
+			COND_SEL(BPF_S_JMP_JNEQ_X, BNE, BE);
 			COND_SEL(BPF_S_JMP_JSET_X, BNE, BE);
 
 cond_branch:			f_offset = addrs[i + filter[i].jf];
@@ -718,6 +720,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 				case BPF_S_JMP_JLT_X:
 				case BPF_S_JMP_JLE_X:
 				case BPF_S_JMP_JEQ_X:
+				case BPF_S_JMP_JNEQ_X:
 					seen |= SEEN_XREG;
 					emit_cmp(r_A, r_X);
 					break;
@@ -726,6 +729,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 					emit_btst(r_A, r_X);
 					break;
 				case BPF_S_JMP_JEQ_K:
+				case BPF_S_JMP_JNEQ_K:
 				case BPF_S_JMP_JGT_K:
 				case BPF_S_JMP_JGE_K:
 				case BPF_S_JMP_JLT_K:
-- 
1.7.11.7
