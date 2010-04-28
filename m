From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/4] bridge: multicast flood
Date: Tue, 27 Apr 2010 18:01:05 -0700
Message-ID: <20100428010336.153753592@vyatta.com>
References: <20100428010103.386761596@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46580 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259Ab0D1BHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 21:07:03 -0400
Content-Disposition: inline; filename=br-router-list-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix unsafe usage of RCU. Would never work on Alpha SMP because
of lack of rcu_dereference()

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_forward.c	2010-04-27 17:11:52.008626080 -0700
+++ b/net/bridge/br_forward.c	2010-04-27 17:23:46.388602995 -0700
@@ -216,7 +216,7 @@ static void br_multicast_flood(struct ne
 
 	prev = NULL;
 
-	rp = br->router_list.first;
+	rp = rcu_dereference(br->router_list.first);
 	p = mdst ? mdst->ports : NULL;
 	while (p || rp) {
 		lport = p ? p->port : NULL;
@@ -233,7 +233,7 @@ static void br_multicast_flood(struct ne
 		if ((unsigned long)lport >= (unsigned long)port)
 			p = p->next;
 		if ((unsigned long)rport >= (unsigned long)port)
-			rp = rp->next;
+			rp = rcu_dereference(rp->next);
 	}
 
 	if (!prev)

-- 

