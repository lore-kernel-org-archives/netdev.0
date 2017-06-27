From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] bpf: indicate lderr when bpf_apply_relo_data fails
Date: Tue, 27 Jun 2017 02:48:36 +0200
Message-ID: <e9c3ce47faaef896a30df16e72a9861ee59069dc.1498524386.git.daniel@iogearbox.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46883 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdF0Asz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When LLVM wrongly generates a rodata relo entry (llvm BZ #33599),
then just bail out instead of probing for prog w/o reloc, which
will fail in this case anyway.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index ae4d97d..6b5a96d 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -1795,8 +1795,10 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
 		*sseen = true;
 
 		ret = bpf_apply_relo_data(ctx, &data_relo, &data_insn);
-		if (ret < 0)
+		if (ret < 0) {
+			*lderr = true;
 			return ret;
+		}
 
 		memset(&prog, 0, sizeof(prog));
 		prog.type    = ctx->type;
-- 
1.9.3
