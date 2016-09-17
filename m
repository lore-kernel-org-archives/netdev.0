From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 14/14] rxrpc: Fix the basic transmit DATA packet
 content size at 1412 bytes
Date: Sun, 18 Sep 2016 00:19:21 +0100
Message-ID: <147415436152.17897.3271866591335873648.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the basic transmit DATA packet content size at 1412 bytes so that they
can be arbitrarily assembled into jumbo packets.

In the future, I'm thinking of moving to keeping a jumbo packet header at
the beginning of each packet in the Tx queue and creating the packet header
on the spot when kernel_sendmsg() is invoked.  That way, jumbo packets can
be assembled on the spur of the moment for (re-)transmission.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index cba236575073..8bfddf4e338c 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -214,7 +214,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 					goto maybe_error;
 			}
 
-			max = call->conn->params.peer->maxdata;
+			max = RXRPC_JUMBO_DATALEN;
 			max -= call->conn->security_size;
 			max &= ~(call->conn->size_align - 1UL);
 
