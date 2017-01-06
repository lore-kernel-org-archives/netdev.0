From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: change back to orig prog on too many passes
Date: Sat,  7 Jan 2017 00:26:33 +0100
Message-ID: <ce21b137ee688d48859b8337b2b2aebb2c404b93.1483744629.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59779 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdAFX1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 18:27:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If after too many passes still no image could be emitted, then
swap back to the original program as we do in all other cases
and don't use the one with blinding.

Fixes: 959a75791603 ("bpf, x86: add support for constant blinding")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/x86/net/bpf_jit_comp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index e76d1af..bb660e5 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1172,6 +1172,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		set_memory_ro((unsigned long)header, header->pages);
 		prog->bpf_func = (void *)image;
 		prog->jited = 1;
+	} else {
+		prog = orig_prog;
 	}
 
 out_addrs:
-- 
1.9.3
