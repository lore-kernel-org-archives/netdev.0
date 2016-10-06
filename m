From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 10/13] rxrpc: Return negative error code to kernel
 service
Date: Thu, 06 Oct 2016 11:05:06 +0100
Message-ID: <147574830618.30350.11859903360731638231.stgit@warthog.procyon.org.uk>
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

In rxrpc_kernel_recv_data(), when we return the error number incurred by a
failed call, we must negate it before returning it as it's stored as
positive (that's what we have to pass back to userspace).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 3fa7771c2a9d..db5b02a47518 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -652,7 +652,7 @@ excess_data:
 	goto out;
 call_complete:
 	*_abort = call->abort_code;
-	ret = call->error;
+	ret = -call->error;
 	if (call->completion == RXRPC_CALL_SUCCEEDED) {
 		ret = 1;
 		if (size > 0)
