From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/8] rxrpc: Use call->peer rather than going to the
 connection
Date: Tue, 30 Aug 2016 16:42:25 +0100
Message-ID: <147257174565.6391.8938407790933440698.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use call->peer rather than call->conn->params.peer as call->conn may become
NULL.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 02fe4a4b60d9..de72de662044 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -551,7 +551,7 @@ static void rxrpc_extract_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 
 	mtu = min(ntohl(ackinfo.rxMTU), ntohl(ackinfo.maxMTU));
 
-	peer = call->conn->params.peer;
+	peer = call->peer;
 	if (mtu < peer->maxdata) {
 		spin_lock_bh(&peer->lock);
 		peer->maxdata = mtu;
@@ -843,8 +843,8 @@ void rxrpc_process_call(struct work_struct *work)
 
 	/* there's a good chance we're going to have to send a message, so set
 	 * one up in advance */
-	msg.msg_name	= &call->conn->params.peer->srx.transport;
-	msg.msg_namelen	= call->conn->params.peer->srx.transport_len;
+	msg.msg_name	= &call->peer->srx.transport;
+	msg.msg_namelen	= call->peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -1151,8 +1151,8 @@ skip_msg_init:
 send_ACK_with_skew:
 	ack.maxSkew = htons(call->ackr_skew);
 send_ACK:
-	mtu = call->conn->params.peer->if_mtu;
-	mtu -= call->conn->params.peer->hdrsize;
+	mtu = call->peer->if_mtu;
+	mtu -= call->peer->hdrsize;
 	ackinfo.maxMTU	= htonl(mtu);
 	ackinfo.rwind	= htonl(rxrpc_rx_window_size);
 
