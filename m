From: David Miller <davem@davemloft.net>
Subject: [PATCH] rxrpc: Fix set but unused variable 'usage' in
 rxrpc_get_peer().
Date: Thu, 19 May 2011 18:41:22 -0400 (EDT)
Message-ID: <20110519.184122.270573760959851407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1ESWlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:41:24 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMfMjL028913
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:41:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I backed off from trying to just eliminate this variable, since
transforming atomic_inc_return() into atomic_inc() takes away
the memory barriers.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rxrpc/ar-peer.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index b6ff063..2754f09 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -157,6 +157,7 @@ struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 	/* we can now add the new candidate to the list */
 	peer = candidate;
 	candidate = NULL;
+	usage = atomic_read(&peer->usage);
 
 	list_add_tail(&peer->link, &rxrpc_peers);
 	write_unlock_bh(&rxrpc_peer_lock);
@@ -171,7 +172,7 @@ success:
 	     &peer->srx.transport.sin.sin_addr,
 	     ntohs(peer->srx.transport.sin.sin_port));
 
-	_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
+	_leave(" = %p {u=%d}", peer, usage);
 	return peer;
 
 	/* we found the peer in the list immediately */
-- 
1.7.4.4

