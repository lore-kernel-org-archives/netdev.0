From: David Howells <dhowells@redhat.com>
Subject: [PATCH 01/13] rxrpc: Fix a case where a call event bit is being
 used as a flag bit
Date: Fri, 04 Mar 2016 16:37:12 +0000
Message-ID: <20160304163712.31057.98261.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a case where RXRPC_CALL_RELEASE (an event) is being used to specify a
flag bit.  RXRPC_CALL_RELEASED should be used instead.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-accept.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 6d79310fcaae..65ea81399f6a 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -185,7 +185,7 @@ invalid_service:
 	read_unlock_bh(&local->services_lock);
 
 	read_lock_bh(&call->state_lock);
-	if (!test_bit(RXRPC_CALL_RELEASE, &call->flags) &&
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events)) {
 		rxrpc_get_call(call);
 		rxrpc_queue_call(call);
