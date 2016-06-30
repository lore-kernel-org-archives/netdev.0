From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/19] rxrpc: Check the source of a packet to a
 client conn
Date: Thu, 30 Jun 2016 15:10:49 +0100
Message-ID: <146729584902.26306.1074452400081031592.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbcF3OMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:12:51 -0400
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
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
index 4bfad7cf96cb..9381938187ac 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -509,7 +509,9 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
 		}
 	} else {
 		conn = idr_find(&rxrpc_client_conn_ids, cid >> RXRPC_CIDSHIFT);
-		if (conn && conn->proto.epoch == epoch)
+		if (conn &&
+		    conn->proto.epoch == epoch &&
+		    conn->params.peer == peer)
 			goto found;
 	}
 
