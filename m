From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: tcp: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:36 +0200
Message-ID: <1334838276.2395.152.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51492 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058Ab2DSMYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:40 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so6293431bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to clone skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 86cfe60..050c551 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1353,7 +1353,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->pktoptions = NULL;
 	if (treq->pktopts != NULL) {
 		newnp->pktoptions = skb_clone(treq->pktopts, GFP_ATOMIC);
-		kfree_skb(treq->pktopts);
+		consume_skb(treq->pktopts);
 		treq->pktopts = NULL;
 		if (newnp->pktoptions)
 			skb_set_owner_r(newnp->pktoptions, newsk);
