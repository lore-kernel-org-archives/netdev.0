From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 03/13] rxrpc: Fix oops on incoming call to serviceless
 endpoint
Date: Thu, 06 Oct 2016 11:04:17 +0100
Message-ID: <147574825741.30350.420157129957865179.stgit@warthog.procyon.org.uk>
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

If an call comes in to a local endpoint that isn't listening for any
incoming calls at the moment, an oops will happen.  We need to check that
the local endpoint's service pointer isn't NULL before we dereference it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_accept.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 3cac231d8405..22cd8a18c481 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -337,7 +337,7 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 
 	/* Get the socket providing the service */
 	rx = rcu_dereference(local->service);
-	if (service_id == rx->srx.srx_service)
+	if (rx && service_id == rx->srx.srx_service)
 		goto found_service;
 
 	trace_rxrpc_abort("INV", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
