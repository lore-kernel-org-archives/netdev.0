From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Tue,  2 Feb 2016 11:20:22 -0800
Message-ID: <1454440822-1953-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35404 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbcBBTUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:20:30 -0500
Received: by mail-pa0-f65.google.com with SMTP id gi1so8770159pac.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:20:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Scrub skb before hitting the iptable hooks to ensure packets hit
these hooks.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8c48bb2a94ea..21c380f9ccd5 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 		ip_rt_put(rt);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, false);
 	skb_dst_set(skb, &rt->dst);
 	err = ip_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
@@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 		dst_release(dst);
 		goto err;
 	}
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, false);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
2.7.0.rc3.207.g0ac5344
