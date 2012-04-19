From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:53 +0200
Message-ID: <1334838293.2395.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51492 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049Ab2DSMY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:57 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so6293431bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to clone skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8f0d68d..4aba72f0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1274,7 +1274,7 @@ drop_pages:
 				return -ENOMEM;
 
 			nfrag->next = frag->next;
-			kfree_skb(frag);
+			consume_skb(frag);
 			frag = nfrag;
 			*fragp = frag;
 		}
