From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: checking for IS_ERR() instead of NULL
Date: Thu, 14 Jul 2016 15:47:01 +0100
Message-ID: <146850762158.24833.7534163896673339680.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

The rxrpc_lookup_peer() function returns NULL on error, it never returns
error pointers.

Fixes: 8496af50eb38 ('rxrpc: Use RCU to access a peer's service connection tree')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_service.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 7cbd612be0d7..fd9027ccba8f 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -163,7 +163,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 
 	if (!peer) {
 		peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
-		if (IS_ERR(peer))
+		if (!peer)
 			goto enomem;
 	}
 
