From: Tom Herbert <therbert@google.com>
Subject: [PATCH] rps: fixed missed rps_unlock
Date: Mon, 5 Apr 2010 14:30:58 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:10393 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab0DEVbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix spin_unlock_irq which needs to be rps_unlock.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 2a9b7dd..74f77ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3120,7 +3120,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			spin_unlock_irq(&queue->input_pkt_queue.lock);
+			rps_unlock(queue);
 			break;
 		}
 		rps_unlock(queue);
