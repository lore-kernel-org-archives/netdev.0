From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 6/8] x86: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT
Date: Mon, 31 Dec 2012 18:00:41 +0100
Message-ID: <bfc52b726919a687068cb42efaca22599a6f32af.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab2LaRAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 12:00:51 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add neq jump
operations to bpf machine" that implements BPF x86 JIT parts
for the BPF JMP_NEQ operation.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/x86/net/bpf_jit_comp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 6d6a4ce..bd10c83 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -587,12 +587,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 			COND_SEL(BPF_S_JMP_JLT_K, X86_JB, X86_JAE);
 			COND_SEL(BPF_S_JMP_JLE_K, X86_JBE, X86_JA);
 			COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
+			COND_SEL(BPF_S_JMP_JNEQ_K,X86_JNE, X86_JE);
 			COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
 			COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
 			COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
 			COND_SEL(BPF_S_JMP_JLT_X, X86_JB, X86_JAE);
 			COND_SEL(BPF_S_JMP_JLE_X, X86_JBE, X86_JA);
 			COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
+			COND_SEL(BPF_S_JMP_JNEQ_X,X86_JNE, X86_JE);
 			COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);
 
 cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
@@ -610,6 +612,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				case BPF_S_JMP_JLT_X:
 				case BPF_S_JMP_JLE_X:
 				case BPF_S_JMP_JEQ_X:
+				case BPF_S_JMP_JNEQ_X:
 					seen |= SEEN_XREG;
 					EMIT2(0x39, 0xd8); /* cmp %ebx,%eax */
 					break;
@@ -618,6 +621,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 					EMIT2(0x85, 0xd8); /* test %ebx,%eax */
 					break;
 				case BPF_S_JMP_JEQ_K:
+				case BPF_S_JMP_JNEQ_K:
 					if (K == 0) {
 						EMIT2(0x85, 0xc0); /* test   %eax,%eax */
 						break;
-- 
1.7.11.7
