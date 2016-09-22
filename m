From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf: use bpf_get_smp_processor_id_proto instead of raw one
Date: Fri, 23 Sep 2016 01:28:36 +0200
Message-ID: <02fa71ebe1c560cad489967aa29c653b48932596.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42485 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757516AbcIVX2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:28:54 -0400
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same motivation as in commit 80b48c445797 ("bpf: don't use raw processor
id in generic helper"), but this time for XDP typed programs. Thus, allow
for preemption checks when we have DEBUG_PREEMPT enabled, and otherwise
use the raw variant.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index e5d9977..acf84fb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2551,6 +2551,8 @@ xdp_func_proto(enum bpf_func_id func_id)
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
 		return &bpf_xdp_event_output_proto;
+	case BPF_FUNC_get_smp_processor_id:
+		return &bpf_get_smp_processor_id_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
