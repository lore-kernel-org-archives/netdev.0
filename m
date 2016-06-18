From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] rxrpc: checking for IS_ERR() instead of NULL
Date: Sat, 18 Jun 2016 11:44:03 +0300
Message-ID: <20160618084403.GC21713@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rxrpc_lookup_peer_rcu() returns NULL on error, it never returns error
pointers.

Fixes: be6e6707f6ee ('rxrpc: Rework peer object handling to use hash table and RCU')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 47fb167..e11e4d7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -639,7 +639,7 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	rxrpc_get_addr_from_skb(local, skb, &srx);
 	rcu_read_lock();
 	peer = rxrpc_lookup_peer_rcu(local, &srx);
-	if (IS_ERR(peer))
+	if (!peer)
 		goto cant_find_peer;
 
 	trans = rxrpc_find_transport(local, peer);
