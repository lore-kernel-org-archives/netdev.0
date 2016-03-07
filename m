From: David Howells <dhowells@redhat.com>
Subject: [PATCH 11/11] rxrpc: Rename rxrpc_UDP_error_report() to
 rxrpc_error_report()
Date: Mon, 07 Mar 2016 14:39:16 +0000
Message-ID: <20160307143916.18567.23093.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbcCGOjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:39:18 -0500
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename rxrpc_UDP_error_report() to rxrpc_error_report() as it might get
called for something other than UDP.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |    2 +-
 net/rxrpc/local-object.c |    2 +-
 net/rxrpc/peer-event.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 0cfd7c10d824..95c52ed2419f 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -681,7 +681,7 @@ static inline void rxrpc_put_local(struct rxrpc_local *local)
 /*
  * peer-event.c
  */
-void rxrpc_UDP_error_report(struct sock *);
+void rxrpc_error_report(struct sock *);
 void rxrpc_UDP_error_handler(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/local-object.c b/net/rxrpc/local-object.c
index cc6354675026..742e964cb8ce 100644
--- a/net/rxrpc/local-object.c
+++ b/net/rxrpc/local-object.c
@@ -189,7 +189,7 @@ static int rxrpc_open_socket(struct rxrpc_local *local)
 	sock = local->socket->sk;
 	sock->sk_user_data	= local;
 	sock->sk_data_ready	= rxrpc_data_ready;
-	sock->sk_error_report	= rxrpc_UDP_error_report;
+	sock->sk_error_report	= rxrpc_error_report;
 	_leave(" = 0");
 	return 0;
 
diff --git a/net/rxrpc/peer-event.c b/net/rxrpc/peer-event.c
index 05eb2366ff22..7da42d43e9c8 100644
--- a/net/rxrpc/peer-event.c
+++ b/net/rxrpc/peer-event.c
@@ -74,7 +74,7 @@ static struct rxrpc_peer *rxrpc_find_icmp_peer_rcu(struct rxrpc_local *local,
 /*
  * handle an error received on the local endpoint
  */
-void rxrpc_UDP_error_report(struct sock *sk)
+void rxrpc_error_report(struct sock *sk)
 {
 	struct sock_exterr_skb *serr;
 	struct rxrpc_transport *trans;
