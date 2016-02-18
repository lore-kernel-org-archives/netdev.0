From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v3 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Wed, 17 Feb 2016 19:52:30 -0800
Message-ID: <1455767550-16896-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34195 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424679AbcBRDwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:52:35 -0500
Received: by mail-pa0-f68.google.com with SMTP id yy13so1470421pab.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 19:52:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Scrub skb before hitting the iptable hooks to ensure packets hit
these hooks in master's namespace.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8c48bb2a94ea..a1f87ec316cf 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 		ip_rt_put(rt);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, true);
 	skb_dst_set(skb, &rt->dst);
 	err = ip_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 		dst_release(dst);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, true);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
2.7.0.rc3.207.g0ac5344
