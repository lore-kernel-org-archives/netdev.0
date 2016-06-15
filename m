From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/8] rxrpc: Rename rxrpc_UDP_error_report() to
 rxrpc_error_report()
Date: Wed, 15 Jun 2016 17:41:52 +0100
Message-ID: <146600891282.18270.14200908940334823816.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename rxrpc_UDP_error_report() to rxrpc_error_report() as it might get
called for something other than UDP.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |    4 ++--
 net/rxrpc/local_object.c |    2 +-
 net/rxrpc/peer_event.c   |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7dba6677b9d5..1e5c15632f49 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -606,9 +606,9 @@ int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
 int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
- * peer_error.c
+ * peer_event.c
  */
-void rxrpc_UDP_error_report(struct sock *);
+void rxrpc_error_report(struct sock *);
 void rxrpc_UDP_error_handler(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 111f250b045f..28f9efb3118f 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -120,7 +120,7 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 	sock = local->socket->sk;
 	sock->sk_user_data	= local;
 	sock->sk_data_ready	= rxrpc_data_ready;
-	sock->sk_error_report	= rxrpc_UDP_error_report;
+	sock->sk_error_report	= rxrpc_error_report;
 	_leave(" = 0");
 	return 0;
 
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 24f5ec0fcd20..2c2df3a5d1b9 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -74,7 +74,7 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 /*
  * handle an error received on the local endpoint
  */
-void rxrpc_UDP_error_report(struct sock *sk)
+void rxrpc_error_report(struct sock *sk)
 {
 	struct sock_exterr_skb *serr;
 	struct rxrpc_transport *trans;
