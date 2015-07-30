From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/4] bpf, x86/sparc: show actual number of passes in bpf_jit_dump
Date: Thu, 30 Jul 2015 12:42:48 +0200
Message-ID: <16c61aff6d8c8261a9edabc00a038b06780b0ee6.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52556 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbbG3Kmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 06:42:54 -0400
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bpf_jit_compile() got split into two functions via commit
f3c2af7ba17a ("net: filter: x86: split bpf_jit_compile()"), bpf_jit_dump()
was changed to always show 0 as number of compiler passes. Change it to
dump the actual number. Also on sparc, we count passes starting from 0,
so add 1 for the debug dump as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/sparc/net/bpf_jit_comp.c | 2 +-
 arch/x86/net/bpf_jit_comp.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 7931eee..f8b9f71 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -807,7 +807,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 	}
 
 	if (bpf_jit_enable > 1)
-		bpf_jit_dump(flen, proglen, pass, image);
+		bpf_jit_dump(flen, proglen, pass + 1, image);
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 6c335a8..c08000b 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1103,7 +1103,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	}
 
 	if (bpf_jit_enable > 1)
-		bpf_jit_dump(prog->len, proglen, 0, image);
+		bpf_jit_dump(prog->len, proglen, pass + 1, image);
 
 	if (image) {
 		bpf_flush_icache(header, image + proglen);
-- 
1.9.3
