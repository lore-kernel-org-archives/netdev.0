From: martinbj2008@gmail.com
Subject: [PATCH v1 net] net: use skb_clone to avoid alloc_pages failure.
Date: Tue, 17 Nov 2015 20:49:30 +0800
Message-ID: <1447764570-22647-1-git-send-email-martinbj2008@gmail.com>
Cc: netdev@vger.kernel.org, Martin Zhang <martinbj2008@gmail.com>,
	Junwei Zhang <linggao.zjw@alibaba-inc.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35790 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbKQMth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 07:49:37 -0500
Received: by pacej9 with SMTP id ej9so8491579pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 04:49:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Zhang <martinbj2008@gmail.com>

1. new skb only need dst and ip address(v4 or v6).
2. skb_copy may need high order pages, which is very rare on long running server.

Signed-off-by: Junwei Zhang <linggao.zjw@alibaba-inc.com>
Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
---

 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 1aa8437..e6af42d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -857,7 +857,7 @@ static void neigh_probe(struct neighbour *neigh)
 	struct sk_buff *skb = skb_peek_tail(&neigh->arp_queue);
 	/* keep skb alive even if arp_queue overflows */
 	if (skb)
-		skb = skb_copy(skb, GFP_ATOMIC);
+		skb = skb_clone(skb, GFP_ATOMIC);
 	write_unlock(&neigh->lock);
 	neigh->ops->solicit(neigh, skb);
 	atomic_inc(&neigh->probes);
-- 
2.1.4
