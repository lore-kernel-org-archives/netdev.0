From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/9] rxrpc: Fix uninitialised variable warning
Date: Sun, 04 Sep 2016 22:02:38 +0100
Message-ID: <147302295815.28597.5580374607342956253.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following uninitialised variable warning:

../net/rxrpc/call_event.c: In function 'rxrpc_process_call':
../net/rxrpc/call_event.c:879:58: warning: 'error' may be used uninitialized in this function [-Wmaybe-uninitialized]
    _debug("post net error %d", error);
                                                          ^

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    5 ++---
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
