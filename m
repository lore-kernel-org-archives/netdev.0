From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv2 next 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Wed, 10 Feb 2016 07:33:26 -0800
Message-ID: <1455118406-428-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36282 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcBJPdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 10:33:35 -0500
Received: by mail-pf0-f174.google.com with SMTP id e127so13657592pfe.3
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 07:33:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Scrub skb before hitting the iptable hooks to ensure packets hit
these hooks.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1: initial patch
v2: resend

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
