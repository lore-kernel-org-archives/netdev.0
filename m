From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/16] ipv4: Deliver ICMP redirects to sockets too.
Date: Thu, 12 Jul 2012 01:10:49 -0700 (PDT)
Message-ID: <20120712.011049.831106026936792516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab2GLIKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:10:50 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 99B7C5824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:10:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And thus, we can remove the ping_err() hack.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 18e39d1..5885146 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -782,13 +782,7 @@ static void icmp_redirect(struct sk_buff *skb)
 		break;
 	}
 
-	/* Ping wants to see redirects.
-         * Let's pretend they are errors of sorts... */
-	if (iph->protocol == IPPROTO_ICMP &&
-	    iph->ihl >= 5 &&
-	    pskb_may_pull(skb, (iph->ihl<<2)+8)) {
-		ping_err(skb, icmp_hdr(skb)->un.gateway);
-	}
+	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);
 
 out:
 	return;
-- 
1.7.10.4
