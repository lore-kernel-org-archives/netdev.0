From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/14] rxrpc: Check the return value of
 rxrpc_locate_data()
Date: Sun, 18 Sep 2016 00:18:05 +0100
Message-ID: <147415428565.17897.2636260361893562351.stgit@warthog.procyon.org.uk>
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

Check the return value of rxrpc_locate_data() in rxrpc_recvmsg_data().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 0d085f5cf1bf..1edf2cf62cc5 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -300,10 +300,13 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		if (msg)
 			sock_recv_timestamp(msg, sock->sk, skb);
 
-		if (rx_pkt_offset == 0)
+		if (rx_pkt_offset == 0) {
 			ret = rxrpc_locate_data(call, skb,
 						&call->rxtx_annotations[ix],
 						&rx_pkt_offset, &rx_pkt_len);
+			if (ret < 0)
+				goto out;
+		}
 		_debug("recvmsg %x DATA #%u { %d, %d }",
 		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
 
