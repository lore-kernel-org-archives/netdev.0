From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: udp: fix UDP_MIB_IGNOREDMULTI updates
Date: Tue, 29 Mar 2016 08:43:41 -0700
Message-ID: <1459266221.6473.182.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33064 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757515AbcC2Pnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 11:43:43 -0400
Received: by mail-pf0-f175.google.com with SMTP id 4so17108462pfd.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 08:43:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 counters updates use a different macro than IPv4.

Fixes: 36cbb2452cbaf ("udp: Increment UDP_MIB_IGNOREDMULTI for arriving unmatched multicasts")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/udp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fd25e447a5fa..8125931106be 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -843,8 +843,8 @@ start_lookup:
 		flush_stack(stack, count, skb, count - 1);
 	} else {
 		if (!inner_flushed)
-			UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
-					 proto == IPPROTO_UDPLITE);
+			UDP6_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
+					  proto == IPPROTO_UDPLITE);
 		consume_skb(skb);
 	}
 	return 0;
