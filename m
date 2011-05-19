From: David Miller <davem@davemloft.net>
Subject: [PATCH] rxrpc: Fix set but unused variable 'usage' in
 rxrpc_get_transport()
Date: Thu, 19 May 2011 18:52:08 -0400 (EDT)
Message-ID: <20110519.185208.273511674650559833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab1ESWwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:52:09 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMq89A029907
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:52:09 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is identical to the case I fixed in rxrpc_get_peer()

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rxrpc/ar-transport.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 5e0226f..92df566 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -111,6 +111,7 @@ struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *local,
 	/* we can now add the new candidate to the list */
 	trans = candidate;
 	candidate = NULL;
+	usage = atomic_read(&trans->usage);
 
 	rxrpc_get_local(trans->local);
 	atomic_inc(&trans->peer->usage);
@@ -125,7 +126,7 @@ success:
 	     trans->local->debug_id,
 	     trans->peer->debug_id);
 
-	_leave(" = %p {u=%d}", trans, atomic_read(&trans->usage));
+	_leave(" = %p {u=%d}", trans, usage);
 	return trans;
 
 	/* we found the transport in the list immediately */
-- 
1.7.4.4

