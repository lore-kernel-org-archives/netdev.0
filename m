From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 04/10] bpf, x86/arm64: remove useless checks on prog
Date: Fri, 13 May 2016 19:08:29 +0200
Message-ID: <bd2c1206d14a65f7a2ef111c38b675d9ba771a82.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41869 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbcEMRJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:02 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is never such a situation, where bpf_int_jit_compile() is
called with either prog as NULL or len as 0, so the tests are
unnecessary and confusing as people would just copy them. s390
doesn't have them, so no change is needed there.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm64/net/bpf_jit_comp.c | 3 ---
 arch/x86/net/bpf_jit_comp.c   | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a34420a..a7fb209 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -771,9 +771,6 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	if (!bpf_jit_enable)
 		return;
 
-	if (!prog || !prog->len)
-		return;
-
 	memset(&ctx, 0, sizeof(ctx));
 	ctx.prog = prog;
 
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 4286f36..f5bfd4f 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1086,9 +1086,6 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	if (!bpf_jit_enable)
 		return;
 
-	if (!prog || !prog->len)
-		return;
-
 	addrs = kmalloc(prog->len * sizeof(*addrs), GFP_KERNEL);
 	if (!addrs)
 		return;
-- 
1.9.3
