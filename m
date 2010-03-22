From: David Howells <dhowells@redhat.com>
Subject: [PATCH] rxrpc: Check allocation failure.
Date: Mon, 22 Mar 2010 13:50:19 +0000
Message-ID: <20100322135019.15704.20997.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab0CVNub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 09:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

alloc_skb() can return NULL.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-accept.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 77228f2..2d744f2 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -88,6 +88,11 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 
 	/* get a notification message to send to the server app */
 	notification = alloc_skb(0, GFP_NOFS);
+	if (!notification) {
+		_debug("no memory");
+		ret = -ENOMEM;
+		goto error_nofree;
+	}
 	rxrpc_new_skb(notification);
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
@@ -189,6 +194,7 @@ invalid_service:
 	ret = -ECONNREFUSED;
 error:
 	rxrpc_free_skb(notification);
+error_nofree:
 	_leave(" = %d", ret);
 	return ret;
 }

