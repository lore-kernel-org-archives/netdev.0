From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: clear sender_cpu before xmit
Date: Tue,  6 Oct 2015 20:46:07 -0700
Message-ID: <1444189567-3031-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36086 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbbJGDqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 23:46:15 -0400
Received: by pablk4 with SMTP id lk4so7180964pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 20:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
the skb->sender_cpu needs to be cleared before xmit.

Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
That is similar to pending patches for xps:
http://patchwork.ozlabs.org/patch/526952/
and for act_mirred:
http://patchwork.ozlabs.org/patch/527066/

though Fixes tag is different, since bpf_clone_redirect() came in
after commit 2bd82484bb4c ("xps: fix xps for stacked devices")
---
 net/core/filter.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index 87b78ef0c3d4..bb18c3680001 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1415,6 +1415,7 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 		return dev_forward_skb(dev, skb2);
 
 	skb2->dev = dev;
+	skb_sender_cpu_clear(skb2);
 	return dev_queue_xmit(skb2);
 }
 
-- 
1.7.9.5
