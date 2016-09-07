From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] rxrpc: Fix returns of call completion helpers
Date: Wed, 07 Sep 2016 16:39:54 +0100
Message-ID: <147326278921.9308.4216347094717897569.stgit@warthog.procyon.org.uk>
References: <147326277574.9308.4656891674085539944.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326277574.9308.4656891674085539944.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rxrpc_set_call_completion() returns bool, not int, so the ret variable
should match this.

rxrpc_call_completed() and __rxrpc_call_completed() should return the value
of rxrpc_set_call_completion().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3addda4bfa6b..0353399792b6 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -608,7 +608,7 @@ static inline bool rxrpc_set_call_completion(struct rxrpc_call *call,
 					     u32 abort_code,
 					     int error)
 {
-	int ret;
+	bool ret;
 
 	write_lock_bh(&call->state_lock);
 	ret = __rxrpc_set_call_completion(call, compl, abort_code, error);
@@ -619,16 +619,19 @@ static inline bool rxrpc_set_call_completion(struct rxrpc_call *call,
 /*
  * Record that a call successfully completed.
  */
-static inline void __rxrpc_call_completed(struct rxrpc_call *call)
+static inline bool __rxrpc_call_completed(struct rxrpc_call *call)
 {
-	__rxrpc_set_call_completion(call, RXRPC_CALL_SUCCEEDED, 0, 0);
+	return __rxrpc_set_call_completion(call, RXRPC_CALL_SUCCEEDED, 0, 0);
 }
 
-static inline void rxrpc_call_completed(struct rxrpc_call *call)
+static inline bool rxrpc_call_completed(struct rxrpc_call *call)
 {
+	bool ret;
+
 	write_lock_bh(&call->state_lock);
-	__rxrpc_call_completed(call);
+	ret = __rxrpc_call_completed(call);
 	write_unlock_bh(&call->state_lock);
+	return ret;
 }
 
 /*
