From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] sparc: bpf_jit_comp: add XOR instruction for BPF
 JIT JIT
Date: Mon, 24 Sep 2012 23:57:54 +0200
Message-ID: <20120924215753.GA31312@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51622 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab2IXV56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 17:57:58 -0400
Received: by wgbdr13 with SMTP id dr13so4093340wgb.1
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 14:57:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "filter: add XOR instruction for use
with X/K" that implements BPF SPARC JIT parts for the BPF XOR operation.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---

 I don't own a SPARC machine. This code is untested and uncompiled, but
 following the other instructions, this should integrate cleanly. Can
 someone confirm that? Thanks.

 arch/sparc/net/bpf_jit_comp.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index e9073e9..2836870 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -464,8 +464,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 				emit_alu_K(OR, K);
 				break;
 			case BPF_S_ANC_ALU_XOR_X: /* A ^= X; */
+			case BPF_S_ALU_XOR_X:
 				emit_alu_X(XOR);
 				break;
+			case BPF_S_ALU_XOR_K:	/* A ^= K */
+				emit_alu_K(XOR, K);
+				break;
 			case BPF_S_ALU_LSH_X:	/* A <<= X */
 				emit_alu_X(SLL);
 				break;
