From: "zhuangfeiran@ict.ac.cn" <zhuangfeiran@ict.ac.cn>
Subject: [PATCH] fix a bug in emitting the 16-bit immediate operand of AND
Date: Thu, 29 Mar 2012 17:27:00 +0800
Message-ID: <4F742AE4.6050006@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.cstnet.cn ([159.226.251.21]:39050 "EHLO cstnet.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753322Ab2C2JdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 05:33:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When K >= 0xFFFF0000, AND needs the two least significant bytes of K as
its operand, but EMIT2() gives it the least significant byte of K and
0x2. EMIT() should be used here to replace EMIT2().

Signed-off-by: Feiran Zhuang  <zhuangfeiran@ict.ac.cn>
---
 arch/x86/net/bpf_jit_comp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 5671752..5a5b6e4 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -289,7 +289,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 					EMIT2(0x24, K & 0xFF); /* and imm8,%al */
 				} else if (K >= 0xFFFF0000) {
 					EMIT2(0x66, 0x25);	/* and imm16,%ax */
-					EMIT2(K, 2);
+					EMIT(K, 2);
 				} else {
 					EMIT1_off32(0x25, K);	/* and imm32,%eax */
 				}
-- 
1.7.5.4
