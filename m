From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] net: filter: fix typo in sparc BPF JIT
Date: Thu,  5 Jun 2014 22:47:44 -0700
Message-ID: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:45071 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaFFFrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 01:47:49 -0400
Received: by mail-pd0-f174.google.com with SMTP id r10so2129725pdi.5
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 22:47:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix typo in sparc codegen for SKF_AD_IFINDEX and SKF_AD_HATYPE
classic BPF extensions

Fixes: 2809a2087cc4 ("net: filter: Just In Time compiler for sparc")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
tested with qemu-sparc64
the patch doesn't apply cleanly to net-next, but logic is the same.

 arch/sparc/net/bpf_jit_comp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index a82c6b2..b19a0c2 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -83,9 +83,9 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define BNE		(F2(0, 2) | CONDNE)
 
 #ifdef CONFIG_SPARC64
-#define BNE_PTR		(F2(0, 1) | CONDNE | (2 << 20))
+#define BE_PTR		(F2(0, 1) | CONDE | (2 << 20))
 #else
-#define BNE_PTR		BNE
+#define BE_PTR		BNE
 #endif
 
 #define SETHI(K, REG)	\
@@ -600,7 +600,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_ANC_IFINDEX:
 				emit_skb_loadptr(dev, r_A);
 				emit_cmpi(r_A, 0);
-				emit_branch(BNE_PTR, cleanup_addr + 4);
+				emit_branch(BE_PTR, cleanup_addr + 4);
 				emit_nop();
 				emit_load32(r_A, struct net_device, ifindex, r_A);
 				break;
@@ -613,7 +613,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_ANC_HATYPE:
 				emit_skb_loadptr(dev, r_A);
 				emit_cmpi(r_A, 0);
-				emit_branch(BNE_PTR, cleanup_addr + 4);
+				emit_branch(BE_PTR, cleanup_addr + 4);
 				emit_nop();
 				emit_load16(r_A, struct net_device, type, r_A);
 				break;
-- 
1.7.9.5
