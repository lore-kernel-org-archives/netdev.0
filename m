From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before xmit
Date: Wed,  7 Oct 2015 10:16:09 +0200
Message-ID: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37502 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbJGIQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 04:16:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
forwarding"), we also need to clear the skb->sender_cpu when moving
from RX to TX via skb_do_redirect() due to the shared location of
napi_id (used on RX) and sender_cpu (used on TX).

Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ( It's also needed here in the net-next commit 27b29f63058d. )

 net/core/filter.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index da3e535..8f4603c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1462,6 +1462,7 @@ int skb_do_redirect(struct sk_buff *skb)
 		return dev_forward_skb(dev, skb);
 
 	skb->dev = dev;
+	skb_sender_cpu_clear(skb);
 	return dev_queue_xmit(skb);
 }
 
-- 
1.9.3
