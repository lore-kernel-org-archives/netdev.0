From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] tools: bpf_jit_disasm: increase image buffer size
Date: Thu, 15 May 2014 15:56:39 -0700
Message-ID: <1400194599-5247-3-git-send-email-ast@plumgrid.com>
References: <1400194599-5247-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:46074 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbaEOW4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 18:56:54 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so1690483pbc.23
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 15:56:54 -0700 (PDT)
In-Reply-To: <1400194599-5247-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

JITed seccomp filters can be quite large if they check a lot of syscalls
Simply increase buffer size

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 tools/net/bpf_jit_disasm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index d9730c3319b9..c5baf9c591b7 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -171,7 +171,7 @@ int main(int argc, char **argv)
 {
 	int len, klen, opcodes = 0;
 	char *kbuff;
-	uint8_t image[4096];
+	static uint8_t image[32768];
 
 	if (argc > 1) {
 		if (!strncmp("-o", argv[argc - 1], 2)) {
-- 
1.7.9.5
