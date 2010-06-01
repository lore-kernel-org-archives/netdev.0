From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xfrm: force a dst reference in __xfrm_route_forward()
Date: Tue, 01 Jun 2010 22:04:49 +0200
Message-ID: <1275422689.2638.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46233 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192Ab0FAUF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 16:05:26 -0400
Received: by wyi11 with SMTP id 11so1317598wyi.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 13:05:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets going through __xfrm_route_forward() have a not refcounted dst
entry, since we enabled a noref forwarding path.

xfrm_lookup() might incorrectly release this dst entry.

It's a bit late to make invasive changes in xfrm_lookup(), so lets force
a refcount in this path.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/xfrm/xfrm_policy.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d965a2b..4bf27d9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2153,6 +2153,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 		return 0;
 	}
 
+	skb_dst_force(skb);
 	dst = skb_dst(skb);
 
 	res = xfrm_lookup(net, &dst, &fl, NULL, 0) == 0;


