From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rxrpc: remove duplicate 'error' variable
Date: Tue,  6 Sep 2016 15:25:29 +0200
Message-ID: <20160906132614.2117695-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rxrpc_process_call function has debug code to print a failure code,
but instead of printing the code from the rxrpc_call structure, it
prints an uninitialized variable:

net/rxrpc/call_event.c: In function 'rxrpc_process_call':
net/rxrpc/call_event.c:879:58: error: 'error' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This removes the extraneous variable and prints the correct
code instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f5c17aaeb2ae ("rxrpc: Calls should only have one terminal state")
---
 net/rxrpc/call_event.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index de72de662044..4754c7fb6242 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -868,7 +868,6 @@ skip_msg_init:
 	/* deal with events of a final nature */
 	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
 		enum rxrpc_skb_mark mark;
-		int error;
 
 		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
 		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
@@ -876,10 +875,10 @@ skip_msg_init:
 
 		if (call->completion == RXRPC_CALL_NETWORK_ERROR) {
 			mark = RXRPC_SKB_MARK_NET_ERROR;
-			_debug("post net error %d", error);
+			_debug("post net error %d", call->error);
 		} else {
 			mark = RXRPC_SKB_MARK_LOCAL_ERROR;
-			_debug("post net local error %d", error);
+			_debug("post net local error %d", call->error);
 		}
 
 		if (rxrpc_post_message(call, mark, call->error, true) < 0)
-- 
2.9.0
