From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/7] bpf: extend bpf_trace_printk to support %i
Date: Sun,  2 Jul 2017 02:13:29 +0200
Message-ID: <f60861b7e62e6d0460ba183e6bf600b3c4750777.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57543 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752330AbdGBANq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:46 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Currently, bpf_trace_printk does not support common formatting
symbol '%i' however vsprintf does and is what eventually gets
called by bpf helper. If users are used to '%i' and currently
make use of it, then bpf_trace_printk will just return with
error without dumping anything to the trace pipe, so just add
support for '%i' to the helper.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 5c6d538..3738519 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -122,8 +122,8 @@ static const struct bpf_func_proto *bpf_get_probe_write_proto(void)
 }
 
 /*
- * limited trace_printk()
- * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
+ * Only limited trace_printk() conversion specifiers allowed:
+ * %d %i %u %x %ld %li %lu %lx %lld %lli %llu %llx %p %s
  */
 BPF_CALL_5(bpf_trace_printk, char *, fmt, u32, fmt_size, u64, arg1,
 	   u64, arg2, u64, arg3)
@@ -198,7 +198,8 @@ static const struct bpf_func_proto *bpf_get_probe_write_proto(void)
 			i++;
 		}
 
-		if (fmt[i] != 'd' && fmt[i] != 'u' && fmt[i] != 'x')
+		if (fmt[i] != 'i' && fmt[i] != 'd' &&
+		    fmt[i] != 'u' && fmt[i] != 'x')
 			return -EINVAL;
 		fmt_cnt++;
 	}
-- 
1.9.3
