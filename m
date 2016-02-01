From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 10/10] tipc: use
	alloc_ordered_workqueue() instead of WQ_UNBOUND w/ max_active = 1
Date: Mon, 1 Feb 2016 10:44:43 +0100
Message-ID: <1454319883-16031-11-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
