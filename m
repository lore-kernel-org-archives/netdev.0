From: akpm@linux-foundation.org
Subject: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon
 union initialization bug
Date: Mon, 18 Jul 2016 15:50:58 -0700
Message-ID: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ast@kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:49670 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbcGRWu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 18:50:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon union initialization bug

kernel/trace/bpf_trace.c: In function 'bpf_event_output':
kernel/trace/bpf_trace.c:312: error: unknown field 'next' specified in initializer
kernel/trace/bpf_trace.c:312: warning: missing braces around initializer
kernel/trace/bpf_trace.c:312: warning: (near initialization for 'raw.frag.<anonymous>')

Fixes: 555c8a8623a3a87 ("bpf: avoid stack copy and use skb ctx for event output")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/trace/bpf_trace.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -puN kernel/trace/bpf_trace.c~kernel-trace-bpf_tracec-work-around-gcc-444-anon-union-initialization-bug kernel/trace/bpf_trace.c
--- a/kernel/trace/bpf_trace.c~kernel-trace-bpf_tracec-work-around-gcc-444-anon-union-initialization-bug
+++ a/kernel/trace/bpf_trace.c
@@ -309,7 +309,9 @@ u64 bpf_event_output(struct bpf_map *map
 	};
 	struct perf_raw_record raw = {
 		.frag = {
-			.next	= ctx_size ? &frag : NULL,
+			{
+				.next	= ctx_size ? &frag : NULL,
+			},
 			.size	= meta_size,
 			.data	= meta,
 		},
_
