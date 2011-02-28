From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_RXRPC: Handle receiving ACKALL packets
Date: Mon, 28 Feb 2011 13:27:43 +0000
Message-ID: <20110228132743.30463.33897.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The OpenAFS server is now sending ACKALL packets, so we need to handle them.
Otherwise we report a protocol error and abort.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-input.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index a4fc974..996d3ef 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -423,6 +423,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 			goto protocol_error;
 		}
 
+	case RXRPC_PACKET_TYPE_ACKALL:
 	case RXRPC_PACKET_TYPE_ACK:
 		/* ACK processing is done in process context */
 		read_lock_bh(&call->state_lock);
