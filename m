From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 10/17] AFS: afs_send_empty_reply() doesn't require an iovec array
Date: Sat, 11 Apr 2015 22:18:21 +0100
Message-ID: <1428787108-13650-10-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37875 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

afs_send_empty_reply() doesn't require an iovec array with which to initialise
the msghdr, but can pass NULL instead.

Suggested-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
---
 fs/afs/rxrpc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index dbc732e..3a57a1b 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -770,15 +770,12 @@ static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
 void afs_send_empty_reply(struct afs_call *call)
 {
 	struct msghdr msg;
-	struct kvec iov[1];
 
 	_enter("");
 
-	iov[0].iov_base		= NULL;
-	iov[0].iov_len		= 0;
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, iov, 0, 0);	/* WTF? */
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, NULL, 0, 0);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= 0;
-- 
2.1.4
