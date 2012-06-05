From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x86 bpf_jit: support BPF_S_ANC_ALU_XOR_X
 instruction
Date: Tue, 05 Jun 2012 09:26:30 +0200
Message-ID: <1338881190.2760.1992.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61754 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab2FEH0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 03:26:35 -0400
Received: by bkcji2 with SMTP id ji2so4321620bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 00:26:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit ffe06c17afbb  (filter: add XOR operation) added generic support
for XOR operation.

This patch implements the XOR instruction in x86 jit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jiri Pirko <jpirko@redhat.com>
---
 arch/x86/net/bpf_jit_comp.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 0597f95..2cf6ce3 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -309,6 +309,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 				else
 					EMIT1_off32(0x0d, K);	/* or imm32,%eax */
 				break;
+			case BPF_S_ANC_ALU_XOR_X: /* A ^= X; */
+				seen |= SEEN_XREG;
+				EMIT2(0x31, 0xd8);		/* xor %ebx,%eax */
+				break;
 			case BPF_S_ALU_LSH_X: /* A <<= X; */
 				seen |= SEEN_XREG;
 				EMIT4(0x89, 0xd9, 0xd3, 0xe0);	/* mov %ebx,%ecx; shl %cl,%eax */
