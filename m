From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/1] tipc: fix nullptr crash during
	subscription cancel
Date: Thu, 3 Mar 2016 17:54:54 +0100
Message-ID: <1457024094-29530-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

commit 4d5cfcba2f6e ('tipc: fix connection abort during subscription
cancel'), removes the check for a valid subscription before calling
tipc_nametbl_subscribe().

This will lead to a nullptr exception when we process a
subscription cancel request. For a cancel request, a null
subscription is passed to tipc_nametbl_subscribe() resulting
in exception.

In this commit, we call tipc_nametbl_subscribe() only for
a valid subscription.

Fixes: 4d5cfcba2f6e ('tipc: fix connection abort during subscription cancel')
Reported-by: Anders Widell <anders.widell@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/subscr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 69ee2eeef968..f9ff73a8d815 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -296,7 +296,8 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 	if (tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscrb, &sub))
 		return tipc_conn_terminate(tn->topsrv, subscrb->conid);
 
-	tipc_nametbl_subscribe(sub);
+	if (sub)
+		tipc_nametbl_subscribe(sub);
 }
 
 /* Handle one request to establish a new subscriber */
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
