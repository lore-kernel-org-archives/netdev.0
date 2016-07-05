From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/24] rxrpc: Check the source of a packet to a
 client conn
Date: Tue, 05 Jul 2016 14:12:32 +0100
Message-ID: <146772435240.21657.14537615652235527199.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbcGENMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 09:12:34 -0400
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking up a client connection to which to route a packet, we need to
check that the packet came from the correct source so that a peer can't try
to muck around with another peer's connection.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_object.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index c86a3cff7585..2c2456ff2853 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -508,7 +508,9 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 		}
 	} else {
 		conn = idr_find(&rxrpc_client_conn_ids, cid >> RXRPC_CIDSHIFT);
-		if (conn && conn->proto.epoch == epoch)
+		if (conn &&
+		    conn->proto.epoch == epoch &&
+		    conn->params.peer == peer)
 			goto found;
 	}
 
