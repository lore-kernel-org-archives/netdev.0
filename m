From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/15] rxrpc: Should be using ktime_add_ms() not
 ktime_add_ns()
Date: Fri, 23 Sep 2016 16:15:45 +0100
Message-ID: <147464374515.5090.634182636044685050.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ktime_add_ms() should be used to add the resend time (in ms) rather than
ktime_add_ns().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 6e2ea8f4ae75..a2909da5d581 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -187,7 +187,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS | annotation;
 	}
 
-	resend_at = ktime_sub(ktime_add_ns(oldest, rxrpc_resend_timeout), now);
+	resend_at = ktime_sub(ktime_add_ms(oldest, rxrpc_resend_timeout), now);
 	call->resend_at = jiffies + nsecs_to_jiffies(ktime_to_ns(resend_at));
 
 	/* Now go through the Tx window and perform the retransmissions.  We
