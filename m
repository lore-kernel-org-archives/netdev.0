From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/6] rxrpc: Fix exclusive client connections
Date: Thu, 29 Sep 2016 23:15:34 +0100
Message-ID: <147518733450.29235.2927492790211019597.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934815AbcI2WPh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 18:15:37 -0400
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exclusive connections are currently reusable (which they shouldn't be)
because rxrpc_alloc_client_connection() checks the exclusive flag in the
rxrpc_connection struct before it's initialised from the function
parameters.  This means that the DONT_REUSE flag doesn't get set.

Fix this by checking the function parameters for the exclusive flag.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_client.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index c76a125df891..f5ee8bfa5bef 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -200,7 +200,7 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	}
 
 	atomic_set(&conn->usage, 1);
-	if (conn->params.exclusive)
+	if (cp->exclusive)
 		__set_bit(RXRPC_CONN_DONT_REUSE, &conn->flags);
 
 	conn->params		= *cp;
