From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/4] rxrpc: Don't specify protocol to when creating
 transport socket [ver #2]
Date: Thu, 15 Sep 2016 00:06:13 +0100
Message-ID: <147389437380.2083.9440619621324654626.stgit@warthog.procyon.org.uk>
References: <147389436004.2083.13454744739435764689.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47306 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764371AbcINXGP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 19:06:15 -0400
In-Reply-To: <147389436004.2083.13454744739435764689.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass 0 as the protocol argument when creating the transport socket rather
than IPPROTO_UDP.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/local_object.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 782b9adf67cb..8720be2a6250 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -103,8 +103,8 @@ static int rxrpc_open_socket(struct rxrpc_local *local)
 	_enter("%p{%d}", local, local->srx.transport_type);
 
 	/* create a socket to represent the local endpoint */
-	ret = sock_create_kern(&init_net, PF_INET, local->srx.transport_type,
-			       IPPROTO_UDP, &local->socket);
+	ret = sock_create_kern(&init_net, local->srx.transport.family,
+			       local->srx.transport_type, 0, &local->socket);
 	if (ret < 0) {
 		_leave(" = %d [socket]", ret);
 		return ret;
