From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: dont drop packet in defrag but consume it
Date: Thu, 19 Apr 2012 18:10:26 +0200
Message-ID: <1334851826.2395.192.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33211 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554Ab2DSQKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 12:10:33 -0400
Received: by eekc41 with SMTP id c41so2287620eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 09:10:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When defragmentation is finalized, we clone a packet and kfree_skb() it.

Call consume_skb() to not confuse dropwatch, since its not a drop.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_fragment.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 3727e23..631f596 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -569,7 +569,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		skb_morph(head, qp->q.fragments);
 		head->next = qp->q.fragments->next;
 
-		kfree_skb(qp->q.fragments);
+		consume_skb(qp->q.fragments);
 		qp->q.fragments = head;
 	}
 
