From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] net: use WARN() for the WARN_ON in commit b6b39e8f3fbbb
Date: Thu, 22 Oct 2009 20:35:12 -0700
Message-ID: <20091022203512.1d714d5a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34746 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbZJWDeL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 23:34:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d63ae5a34f2ed0821870c9e4c797e4e095f0c58a Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Thu, 22 Oct 2009 20:32:24 -0700
Subject: [PATCH] net: use WARN() for the WARN_ON in commit b6b39e8f3fbbb

Commit b6b39e8f3fbbb (tcp: Try to catch MSG_PEEK bug) added a printk()
to the WARN_ON() that's in tcp.c. This patch changes this combination
to WARN(); the advantage of WARN() is that the printk message shows up
inside the message, so that kerneloops.org will collect the message.

In addition, this gets rid of an extra if() statement.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/ipv4/tcp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 90b2e06..a0e56db 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1442,9 +1442,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				goto found_ok_skb;
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
-			if (WARN_ON(!(flags & MSG_PEEK)))
-				printk(KERN_INFO "recvmsg bug 2: copied %X "
-				       "seq %X\n", *seq, TCP_SKB_CB(skb)->seq);
+			WARN(!(flags & MSG_PEEK), KERN_INFO "recvmsg bug 2: "
+					"copied %X seq %X\n", *seq, 
+					TCP_SKB_CB(skb)->seq);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
-- 
1.6.2.5



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
