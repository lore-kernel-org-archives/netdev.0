From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] rxrpc: The RXRPC_ACCEPT control message should not have
 an address
Date: Tue, 12 Apr 2016 16:05:48 +0100
Message-ID: <20160412150548.20637.14972.stgit@warthog.procyon.org.uk>
References: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sendmsg() is called with the RXRPC_ACCEPT control message, sendmsg()
shouldn't also be given an address in msg_name.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index b87fda075b45..044de9bf34a4 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -199,7 +199,8 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		return ret;
 
 	if (cmd == RXRPC_CMD_ACCEPT) {
-		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING)
+		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING ||
+		    msg->msg_name)
 			return -EINVAL;
 		call = rxrpc_accept_call(rx, user_call_ID);
 		if (IS_ERR(call))
