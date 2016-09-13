From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/10] rxrpc: Make sure we initialise the peer hash
 key
Date: Tue, 13 Sep 2016 23:21:03 +0100
Message-ID: <147380526330.23135.11297375286469560472.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peer records created for incoming connections weren't getting their hash
key set.  This meant that incoming calls wouldn't see more than one DATA
packet - which is not a problem for AFS CM calls with small request data
blobs.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_object.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 2efe29a4c232..3e6cd174b53d 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -203,6 +203,7 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
  */
 static void rxrpc_init_peer(struct rxrpc_peer *peer, unsigned long hash_key)
 {
+	peer->hash_key = hash_key;
 	rxrpc_assess_MTU_size(peer);
 	peer->mtu = peer->if_mtu;
 
@@ -238,7 +239,6 @@ static struct rxrpc_peer *rxrpc_create_peer(struct rxrpc_local *local,
 
 	peer = rxrpc_alloc_peer(local, gfp);
 	if (peer) {
-		peer->hash_key = hash_key;
 		memcpy(&peer->srx, srx, sizeof(*srx));
 		rxrpc_init_peer(peer, hash_key);
 	}
