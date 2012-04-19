From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: dccp: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:48 +0200
Message-ID: <1334838288.2395.156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38632 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab2DSMYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:52 -0400
Received: by mail-ee0-f46.google.com with SMTP id c41so2207028eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to clone skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index e923ac9..fa9512d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -580,7 +580,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	newnp->pktoptions = NULL;
 	if (ireq6->pktopts != NULL) {
 		newnp->pktoptions = skb_clone(ireq6->pktopts, GFP_ATOMIC);
-		kfree_skb(ireq6->pktopts);
+		consume_skb(ireq6->pktopts);
 		ireq6->pktopts = NULL;
 		if (newnp->pktoptions)
 			skb_set_owner_r(newnp->pktoptions, newsk);
