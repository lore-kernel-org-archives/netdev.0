From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] sparc: bpf_jit: add support for BPF_LD(X) | BPF_LEN instructions
Date: Tue, 23 Sep 2014 14:36:11 -0700
Message-ID: <1411508171-10740-1-git-send-email-ast@plumgrid.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59264 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756611AbaIWVgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 17:36:15 -0400
Received: by mail-pd0-f174.google.com with SMTP id g10so6699534pdj.19
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 14:36:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF_LD | BPF_W | BPF_LEN instruction is occasionally used by tcpdump
and present in 11 tests in lib/test_bpf.c
Teach sparc JIT compiler to emit it.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

coupled with pending net fix test_bpf still comes out clean on sparc64.
compile tested only on sparc32

Though both patches touch the same file, there should be no conflicts
between net and net-next.

 arch/sparc/net/bpf_jit_comp.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 7c06f18150ab..86bad49d6604 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -624,7 +624,12 @@ void bpf_jit_compile(struct bpf_prog *fp)
 					emit_and(r_A, r_TMP, r_A);
 				}
 				break;
-
+			case BPF_LD | BPF_W | BPF_LEN:
+				emit_skb_load32(len, r_A);
+				break;
+			case BPF_LDX | BPF_W | BPF_LEN:
+				emit_skb_load32(len, r_X);
+				break;
 			case BPF_LD | BPF_IMM:
 				emit_loadimm(K, r_A);
 				break;
-- 
1.7.9.5
