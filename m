From: David Howells <dhowells@redhat.com>
Subject: [PATCH 12/13] rxrpc: Clear the unused part of a sockaddr_rxrpc for
 memcmp() use
Date: Fri, 04 Mar 2016 16:38:28 +0000
Message-ID: <20160304163828.31057.55603.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear the unused part of a sockaddr_rxrpc structs so that memcmp() can be
used to compare them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index b46f7742d336..a76501757b59 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -81,6 +81,8 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 				  struct sockaddr_rxrpc *srx,
 				  int len)
 {
+	unsigned tail;
+
 	if (len < sizeof(struct sockaddr_rxrpc))
 		return -EINVAL;
 
@@ -103,9 +105,7 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 		_debug("INET: %x @ %pI4",
 		       ntohs(srx->transport.sin.sin_port),
 		       &srx->transport.sin.sin_addr);
-		if (srx->transport_len > 8)
-			memset((void *)&srx->transport + 8, 0,
-			       srx->transport_len - 8);
+		tail = offsetof(struct sockaddr_rxrpc, transport.sin.__pad);
 		break;
 
 	case AF_INET6:
@@ -113,6 +113,8 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 		return -EAFNOSUPPORT;
 	}
 
+	if (tail < len)
+		memset((void *)srx + tail, 0, len - tail);
 	return 0;
 }
 
