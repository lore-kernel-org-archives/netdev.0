From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, arm: start flushing icache range from header
Date: Sat, 14 Nov 2015 01:26:53 +0100
Message-ID: <971980449d680e6b26e273130d74546c5148893c.1447446440.git.daniel@iogearbox.net>
Cc: nschichan@freebox.fr, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60677 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbKNA07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 19:26:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During review I noticed that the icache range we're flushing should
start at header already and not at ctx.image.

Reason is that after 55309dd3d4cd ("net: bpf: arm: address randomize
and write protect JIT code"), we also want to make sure to flush the
random-sized trap in front of the start of the actual program (analogous
to x86). No operational differences from user side.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Tested-by: Nicolas Schichan <nschichan@freebox.fr>
Cc: Alexei Starovoitov <ast@kernel.org>
---
 ( As arm32 fixes usually go via Dave's tree, targeting -net. )

 arch/arm/net/bpf_jit_32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 2f4b14c..591f9db 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -1061,7 +1061,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	}
 	build_epilogue(&ctx);
 
-	flush_icache_range((u32)ctx.target, (u32)(ctx.target + ctx.idx));
+	flush_icache_range((u32)header, (u32)(ctx.target + ctx.idx));
 
 #if __LINUX_ARM_ARCH__ < 7
 	if (ctx.imm_count)
-- 
1.9.3
