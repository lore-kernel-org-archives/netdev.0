From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/24] rxrpc: Fix some sparse errors
Date: Tue, 05 Jul 2016 14:12:25 +0100
Message-ID: <146772434540.21657.8892317874241593843.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following sparse errors:

../net/rxrpc/conn_object.c:77:17: warning: incorrect type in assignment (different base types)
../net/rxrpc/conn_object.c:77:17:    expected restricted __be32 [usertype] call_id
../net/rxrpc/conn_object.c:77:17:    got unsigned int [unsigned] [usertype] call_id
../net/rxrpc/conn_object.c:84:21: warning: restricted __be32 degrades to integer
../net/rxrpc/conn_object.c:86:26: warning: restricted __be32 degrades to integer
../net/rxrpc/conn_object.c:357:15: warning: incorrect type in assignment (different base types)
../net/rxrpc/conn_object.c:357:15:    expected restricted __be32 [usertype] epoch
../net/rxrpc/conn_object.c:357:15:    got unsigned int [unsigned] [usertype] epoch
../net/rxrpc/conn_object.c:369:21: warning: restricted __be32 degrades to integer
../net/rxrpc/conn_object.c:371:26: warning: restricted __be32 degrades to integer
../net/rxrpc/conn_object.c:411:21: warning: restricted __be32 degrades to integer
../net/rxrpc/conn_object.c:413:26: warning: restricted __be32 degrades to integer

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_object.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 4bfad7cf96cb..c86a3cff7585 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -70,7 +70,7 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
 {
 	struct rxrpc_call *xcall;
 	struct rb_node *parent, **p;
-	__be32 call_id;
+	u32 call_id;
 
 	write_lock_bh(&conn->lock);
 
@@ -347,8 +347,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rb_node *p, **pp;
 	const char *new = "old";
-	__be32 epoch;
-	u32 cid;
+	u32 epoch, cid;
 
 	_enter("");
 
