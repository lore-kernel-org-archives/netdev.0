From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/8] x86: bpf_jit_comp: add JMP instructions for BPF JIT
Date: Mon, 31 Dec 2012 14:59:42 +0100
Message-ID: <f8cc6429a4a4df0668b5c6388960eb9bb72d4976.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab2LaN7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 08:59:55 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add lt,le jump
operations to bpf machine" that implements BPF x86 JIT parts
for BPF JMP_LT/JMP_LE operations.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/x86/net/bpf_jit_comp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index d11a470..6d6a4ce 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -584,10 +584,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 				break;
 			COND_SEL(BPF_S_JMP_JGT_K, X86_JA, X86_JBE);
 			COND_SEL(BPF_S_JMP_JGE_K, X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JLT_K, X86_JB, X86_JAE);
+			COND_SEL(BPF_S_JMP_JLE_K, X86_JBE, X86_JA);
 			COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
 			COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
 			COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
 			COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JLT_X, X86_JB, X86_JAE);
+			COND_SEL(BPF_S_JMP_JLE_X, X86_JBE, X86_JA);
 			COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
 			COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);
 
@@ -603,6 +607,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				switch (filter[i].code) {
 				case BPF_S_JMP_JGT_X:
 				case BPF_S_JMP_JGE_X:
+				case BPF_S_JMP_JLT_X:
+				case BPF_S_JMP_JLE_X:
 				case BPF_S_JMP_JEQ_X:
 					seen |= SEEN_XREG;
 					EMIT2(0x39, 0xd8); /* cmp %ebx,%eax */
@@ -618,6 +624,8 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 					}
 				case BPF_S_JMP_JGT_K:
 				case BPF_S_JMP_JGE_K:
+				case BPF_S_JMP_JLT_K:
+				case BPF_S_JMP_JLE_K:
 					if (K <= 127)
 						EMIT3(0x83, 0xf8, K); /* cmp imm8,%eax */
 					else
-- 
1.7.11.7
