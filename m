From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] test_bpf: assign type to native eBPF test cases
Date: Thu, 30 Jul 2015 12:42:46 +0200
Message-ID: <45cfb718190f86817a7662e58499a08f30521404.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52549 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbG3Kmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 06:42:53 -0400
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As JITs start to perform optimizations whether to clear A and X on eBPF
programs in the prologue, we should actually assign a program type to the
native eBPF test cases. It doesn't really matter which program type, as
these instructions don't go through the verifier, but it needs to be a
type != BPF_PROG_TYPE_UNSPEC. This reflects eBPF programs loaded via bpf(2)
system call (!= type unspec) vs. classic BPF to eBPF migrations (== type
unspec).

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 lib/test_bpf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 8b5e66f..3afddf2 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4613,6 +4613,8 @@ static struct bpf_prog *generate_filter(int which, int *err)
 		}
 
 		fp->len = flen;
+		/* Type doesn't really matter here as long as it's not unspec. */
+		fp->type = BPF_PROG_TYPE_SOCKET_FILTER;
 		memcpy(fp->insnsi, fptr, fp->len * sizeof(struct bpf_insn));
 
 		bpf_prog_select_runtime(fp);
-- 
1.9.3
