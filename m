From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2.6.34-rc2] rxrpc: Check allocation failure.
Date: Mon, 22 Mar 2010 14:44:31 +0900
Message-ID: <201003221444.JID21821.FQJOSLFMOFtHOV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:62522 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234Ab0CVFod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 01:44:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_skb() can return NULL.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/rxrpc/ar-accept.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-2.6.34-rc2.orig/net/rxrpc/ar-accept.c
+++ linux-2.6.34-rc2/net/rxrpc/ar-accept.c
@@ -88,6 +88,11 @@ static int rxrpc_accept_incoming_call(st
 
 	/* get a notification message to send to the server app */
 	notification = alloc_skb(0, GFP_NOFS);
+	if (!notification) {
+		_debug("no memory");
+		ret = -ENOMEM;
+		goto error;
+	}
 	rxrpc_new_skb(notification);
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
