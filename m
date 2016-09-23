From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 03/15] rxrpc: Make sure sendmsg() is woken on call
 completion
Date: Fri, 23 Sep 2016 16:15:38 +0100
Message-ID: <147464373831.5090.12790080187704224411.stgit@warthog.procyon.org.uk>
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

Make sure that sendmsg() gets woken up if the call it is waiting for
completes abnormally.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index b13754a6dd7a..808ab750dc6b 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -758,6 +758,7 @@ static inline bool __rxrpc_set_call_completion(struct rxrpc_call *call,
 		call->error = error;
 		call->completion = compl,
 		call->state = RXRPC_CALL_COMPLETE;
+		wake_up(&call->waitq);
 		return true;
 	}
 	return false;
