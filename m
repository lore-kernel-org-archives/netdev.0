From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 11/13] afs: Check for fatal error when in waiting for
 ack state
Date: Thu, 06 Oct 2016 11:05:13 +0100
Message-ID: <147574831313.30350.4464082411010062270.stgit@warthog.procyon.org.uk>
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

When it's in the waiting-for-ACK state, the AFS filesystem needs to check
the result of rxrpc_kernel_recv_data() any time it is notified to see if it
is indicating a fatal error.  If this is the case, it needs to mark the
call completed otherwise the call just sits there and never goes away.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 59bdaa7527b6..477928b25940 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -418,7 +418,7 @@ static void afs_deliver_to_call(struct afs_call *call)
 						     &call->abort_code);
 			if (ret == -EINPROGRESS || ret == -EAGAIN)
 				return;
-			if (ret == 1) {
+			if (ret == 1 || ret < 0) {
 				call->state = AFS_CALL_COMPLETE;
 				goto done;
 			}
