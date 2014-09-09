From: David Howells <dhowells@redhat.com>
Subject: [PATCH] RxRPC: Fix missing __user annotation
Date: Tue, 09 Sep 2014 15:19:44 +0100
Message-ID: <20140909141944.18112.74852.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a missing __user annotation in a cast of a user space pointer (found by
checker).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index b45d080e64a7..1b24191167f1 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -1143,7 +1143,7 @@ static long rxrpc_read(const struct key *key,
 		if (copy_to_user(xdr, (s), _l) != 0)			\
 			goto fault;					\
 		if (_l & 3 &&						\
-		    copy_to_user((u8 *)xdr + _l, &zero, 4 - (_l & 3)) != 0) \
+		    copy_to_user((u8 __user *)xdr + _l, &zero, 4 - (_l & 3)) != 0) \
 			goto fault;					\
 		xdr += (_l + 3) >> 2;					\
 	} while(0)
