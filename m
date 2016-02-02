From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 10/10] tipc: use alloc_ordered_workqueue() instead of WQ_UNBOUND w/ max_active = 1
Date: Tue, 2 Feb 2016 10:52:17 +0100
Message-ID: <1454406737-5806-11-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:52172 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbcBBJxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 04:53:18 -0500
In-Reply-To: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, tipc_rcv and tipc_send workqueues in server are allocated
with parameters WQ_UNBOUND & max_active = 1.
This parameters passed to this function makes it equivalent to
alloc_ordered_workqueue(). The later form is more explicit and
can inherit future ordered_workqueue changes.

In this commit we replace alloc_workqueue() with more readable
alloc_ordered_workqueue().

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/server.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 922e04a43396..2446bfbaa309 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -571,13 +571,13 @@ static void tipc_work_stop(struct tipc_server *s)
 
 static int tipc_work_start(struct tipc_server *s)
 {
-	s->rcv_wq = alloc_workqueue("tipc_rcv", WQ_UNBOUND, 1);
+	s->rcv_wq = alloc_ordered_workqueue("tipc_rcv", 0);
 	if (!s->rcv_wq) {
 		pr_err("can't start tipc receive workqueue\n");
 		return -ENOMEM;
 	}
 
-	s->send_wq = alloc_workqueue("tipc_send", WQ_UNBOUND, 1);
+	s->send_wq = alloc_ordered_workqueue("tipc_send", 0);
 	if (!s->send_wq) {
 		pr_err("can't start tipc send workqueue\n");
 		destroy_workqueue(s->rcv_wq);
-- 
2.1.4
