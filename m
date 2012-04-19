From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: GRO_MERGED_FREE consumes packets
Date: Thu, 19 Apr 2012 19:07:40 +0200
Message-ID: <1334855260.2395.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51139 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab2DSRHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:07:46 -0400
Received: by eekc41 with SMTP id c41so2305018eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 10:07:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As part of GRO processing, merged skbs should be consumed, not freed, to
not confuse dropwatch/drop_monitor.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c938127..501f3cc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3542,10 +3542,13 @@ gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 		break;
 
 	case GRO_DROP:
-	case GRO_MERGED_FREE:
 		kfree_skb(skb);
 		break;
 
+	case GRO_MERGED_FREE:
+		consume_skb(skb);
+		break;
+
 	case GRO_HELD:
 	case GRO_MERGED:
 		break;
