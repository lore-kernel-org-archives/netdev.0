From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] sparc: bpf_jit: add SKF_AD_PKTTYPE support to JIT
Date: Tue, 16 Sep 2014 12:35:35 -0700
Message-ID: <1410896135-9867-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:48792 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875AbaIPTgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 15:36:02 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so429071pad.20
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 12:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 233577a22089 ("net: filter: constify detection of pkt_type_offset")
allows us to implement simple PKTTYPE support in sparc JIT

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/sparc/net/bpf_jit_comp.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index b2ad9dc5425e..2dde48bdcc42 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -579,16 +579,11 @@ void bpf_jit_compile(struct bpf_prog *fp)
 			case BPF_ANC | SKF_AD_PROTOCOL:
 				emit_skb_load16(protocol, r_A);
 				break;
-#if 0
-				/* GCC won't let us take the address of
-				 * a bit field even though we very much
-				 * know what we are doing here.
-				 */
 			case BPF_ANC | SKF_AD_PKTTYPE:
-				__emit_skb_load8(pkt_type, r_A);
+				__emit_skb_load8(__pkt_type_offset, r_A);
+				emit_andi(r_A, PKT_TYPE_MAX, r_A);
 				emit_alu_K(SRL, 5);
 				break;
-#endif
 			case BPF_ANC | SKF_AD_IFINDEX:
 				emit_skb_loadptr(dev, r_A);
 				emit_cmpi(r_A, 0);
-- 
1.7.9.5
