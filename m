From: David Miller <davem@davemloft.net>
Subject: Re: inetpeer with create==0
Date: Thu, 03 Mar 2011 00:30:39 -0800 (PST)
Message-ID: <20110303.003039.70182283.davem@davemloft.net>
References: <20110302.204545.193730647.davem@davemloft.net>
	<1299135107.2456.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751649Ab1CCIaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:30:03 -0500
In-Reply-To: <1299135107.2456.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Mar 2011 07:51:47 +0100

> Hmm... I'm curious you send this hack to me ;)

Ok, it's so simple :-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 48f8d45..a194e91 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -492,6 +492,8 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		unlink_from_unused(p);
 		return p;
 	}
+	if (!create)
+		return NULL;
 
 	/* retry an exact lookup, taking the lock before.
 	 * At least, nodes should be hot in our cache.
@@ -505,7 +507,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		unlink_from_unused(p);
 		return p;
 	}
-	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
+	p = kmem_cache_alloc(peer_cachep, GFP_ATOMIC);
 	if (p) {
 		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
