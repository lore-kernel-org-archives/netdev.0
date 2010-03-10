From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Annotates neigh_invalidate()
Date: Wed, 10 Mar 2010 06:40:54 +0100
Message-ID: <1268199654.2872.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39772 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab0CJFlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 00:41:02 -0500
Received: by bwz1 with SMTP id 1so4626040bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 21:40:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Annotates neigh_invalidate() with __releases() and __acquires() for
sparse sake.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d102f6d..6cee643 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -771,6 +771,8 @@ static __inline__ int neigh_max_probes(struct neighbour *n)
 }
 
 static void neigh_invalidate(struct neighbour *neigh)
+	__releases(neigh->lock)
+	__acquires(neigh->lock)
 {
 	struct sk_buff *skb;
 



