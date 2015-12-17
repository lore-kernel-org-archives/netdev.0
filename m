From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/5] bpf: fix misleading comment in bpf_convert_filter
Date: Thu, 17 Dec 2015 23:51:55 +0100
Message-ID: <3996c95af55b2fbb22fdd2e9bf8e6800e53d7352.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53888 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbbLQWwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:04 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comment says "User BPF's register A is mapped to our BPF register 6",
which is actually wrong as the mapping is on register 0. This can
already be inferred from the code itself. So just remove it before
someone makes assumptions based on that. Only code tells truth. ;)

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index b513eb8..c770196 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -348,12 +348,6 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  *    jump offsets, 2nd pass remapping:
  *   new_prog = kmalloc(sizeof(struct bpf_insn) * new_len);
  *   bpf_convert_filter(old_prog, old_len, new_prog, &new_len);
- *
- * User BPF's register A is mapped to our BPF register 6, user BPF
- * register X is mapped to BPF register 7; frame pointer is always
- * register 10; Context 'void *ctx' is stored in register 1, that is,
- * for socket filters: ctx == 'struct sk_buff *', for seccomp:
- * ctx == 'struct seccomp_data *'.
  */
 static int bpf_convert_filter(struct sock_filter *prog, int len,
 			      struct bpf_insn *new_prog, int *new_len)
-- 
1.9.3
