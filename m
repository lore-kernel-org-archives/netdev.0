From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/8] sparc: bpf_jit_comp: add JMP instructions for BPF JIT
Date: Mon, 31 Dec 2012 14:59:43 +0100
Message-ID: <6cbad4d58b4ef03c7ac1fbdb22e09ad8fe5954c0.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab2LaN7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 08:59:55 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add lt,le jump
operations to bpf machine" that implements BPF SPARC JIT parts
for BPF JMP_LT/JMP_LE operations.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/sparc/net/bpf_jit_comp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 3109ca6..f5b4fc9 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -691,10 +691,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 
 			COND_SEL(BPF_S_JMP_JGT_K, BGU, BLEU);
 			COND_SEL(BPF_S_JMP_JGE_K, BGEU, BLU);
+			COND_SEL(BPF_S_JMP_JLT_K, BLU, BGEU);
+			COND_SEL(BPF_S_JMP_JLE_K, BLEU, BGU);
 			COND_SEL(BPF_S_JMP_JEQ_K, BE, BNE);
 			COND_SEL(BPF_S_JMP_JSET_K, BNE, BE);
 			COND_SEL(BPF_S_JMP_JGT_X, BGU, BLEU);
 			COND_SEL(BPF_S_JMP_JGE_X, BGEU, BLU);
+			COND_SEL(BPF_S_JMP_JLT_X, BLU, BGEU);
+			COND_SEL(BPF_S_JMP_JLE_X, BLEU, BGU);
 			COND_SEL(BPF_S_JMP_JEQ_X, BE, BNE);
 			COND_SEL(BPF_S_JMP_JSET_X, BNE, BE);
 
@@ -711,6 +715,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 				switch (filter[i].code) {
 				case BPF_S_JMP_JGT_X:
 				case BPF_S_JMP_JGE_X:
+				case BPF_S_JMP_JLT_X:
+				case BPF_S_JMP_JLE_X:
 				case BPF_S_JMP_JEQ_X:
 					seen |= SEEN_XREG;
 					emit_cmp(r_A, r_X);
@@ -722,6 +728,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 				case BPF_S_JMP_JEQ_K:
 				case BPF_S_JMP_JGT_K:
 				case BPF_S_JMP_JGE_K:
+				case BPF_S_JMP_JLT_K:
+				case BPF_S_JMP_JLE_K:
 					if (is_simm13(K)) {
 						emit_cmpi(r_A, K);
 					} else {
-- 
1.7.11.7
