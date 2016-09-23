From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 05/15] rxrpc: Use before_eq() and friends to
 compare serial numbers
Date: Fri, 23 Sep 2016 16:15:52 +0100
Message-ID: <147464375197.5090.5370130943475664508.stgit@warthog.procyon.org.uk>
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

before_eq() and friends should be used to compare serial numbers (when not
checking for (non)equality) rather than casting to int, subtracting and
checking the result.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index cbb5d53f09d7..06027b6d9c19 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -578,7 +578,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 
 	/* Discard any out-of-order or duplicate ACKs. */
-	if ((int)sp->hdr.serial - (int)call->acks_latest <= 0) {
+	if (before_eq(sp->hdr.serial, call->acks_latest)) {
 		_debug("discard ACK %d <= %d",
 		       sp->hdr.serial, call->acks_latest);
 		return;
