From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 3/5] bpf: add bpf_clone_redirect to bpf_helper_changes_pkt_data
Date: Thu, 25 May 2017 01:05:07 +0200
Message-ID: <75df55a26a345e7718cb520fb1ccc6a02a4460d6.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033163AbdEXXFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 19:05:40 -0400
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf_clone_redirect() still needs to be listed in
bpf_helper_changes_pkt_data() since we call into
bpf_try_make_head_writable() from there, thus we need
to invalidate prior pkt regs as well.

Fixes: 36bbef52c7eb ("bpf: direct packet write and access for helpers for clsact progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index a253a61..a6bb95f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2281,6 +2281,7 @@ bool bpf_helper_changes_pkt_data(void *func)
 	    func == bpf_skb_change_head ||
 	    func == bpf_skb_change_tail ||
 	    func == bpf_skb_pull_data ||
+	    func == bpf_clone_redirect ||
 	    func == bpf_l3_csum_replace ||
 	    func == bpf_l4_csum_replace ||
 	    func == bpf_xdp_adjust_head)
-- 
1.9.3
