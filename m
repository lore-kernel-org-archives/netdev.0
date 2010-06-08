From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] ipv6: fix ICMP6_MIB_OUTERRORS
Date: Tue, 08 Jun 2010 10:24:44 +0200
Message-ID: <1275985484.2475.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37814 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab0FHIYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 04:24:48 -0400
Received: by fxm8 with SMTP id 8so2656540fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 01:24:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 1f8438a85366 (icmp: Account for ICMP out errors), I did a typo
on IPV6 side, using ICMP6_MIB_OUTMSGS instead of ICMP6_MIB_OUTERRORS

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index ce79929..03e62f9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -483,7 +483,7 @@ route_done:
 			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
 			      MSG_DONTWAIT, np->dontfrag);
 	if (err) {
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
@@ -565,7 +565,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 				np->dontfrag);
 
 	if (err) {
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
+		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}


