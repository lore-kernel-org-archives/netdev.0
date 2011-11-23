From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix a bug in ndisc_send_redirect
Date: Wed, 23 Nov 2011 14:18:05 +0800
Message-ID: <4ECC901D.5070905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57687 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754473Ab1KWGRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 01:17:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Release skb when transmit rate limit _not_ allow

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/ndisc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 44e5b7f..0cb78d7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1571,7 +1571,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	}
 	if (!rt->rt6i_peer)
 		rt6_bind_peer(rt, 1);
-	if (inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
+	if (!inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
 		goto release;
 
 	if (dev->addr_len) {
-- 
1.7.3.2
