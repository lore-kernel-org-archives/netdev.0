From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 09/13] rxrpc: Add missing notification
Date: Thu, 06 Oct 2016 11:04:59 +0100
Message-ID: <147574829934.30350.1421261975581156853.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call's background processor work item needs to notify the socket when
it completes a call so that recvmsg() or the AFS fs can deal with it.
Without this, call expiry isn't handled.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index e2a987fd31ce..0f91d329e910 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -372,6 +372,7 @@ recheck_state:
 
 	if (call->state == RXRPC_CALL_COMPLETE) {
 		del_timer_sync(&call->timer);
+		rxrpc_notify_socket(call);
 		goto out_put;
 	}
 
