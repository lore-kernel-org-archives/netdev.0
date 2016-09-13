From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/10] rxrpc: Add missing wakeup on Tx window
 rotation
Date: Tue, 13 Sep 2016 23:21:10 +0100
Message-ID: <147380527029.23135.18355783643218711122.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to wake up the sender when Tx window rotation due to an incoming
ACK makes space in the buffer otherwise the sender is liable to just hang
endlessly.

This problem isn't noticeable if the Tx phase transfers no more than will
fit in a single window or the Tx window rotates fast enough that it doesn't
get full.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index afeba98004b1..a707d5952164 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -59,6 +59,8 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 
 	spin_unlock(&call->lock);
 
+	wake_up(&call->waitq);
+
 	while (list) {
 		skb = list;
 		list = skb->next;
