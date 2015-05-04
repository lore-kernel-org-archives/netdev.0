From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/5] tipc: introduce
	tipc_subscrb_create routine
Date: Mon, 4 May 2015 10:36:45 +0800
Message-ID: <1430707008-11141-3-git-send-email-ying.xue@windriver.com>
References: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Introducing a new function makes the purpose of tipc_subscrb_connect_cb
callback routine more clear.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericson.com>
---
 net/tipc/subscr.c |   30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index caec0b2..d0dbde4 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -154,6 +154,22 @@ static void tipc_subscrp_delete(struct tipc_subscription *sub)
 	atomic_dec(&tn->subscription_count);
 }
 
+static struct tipc_subscriber *tipc_subscrb_create(int conid)
+{
+	struct tipc_subscriber *subscriber;
+
+	subscriber = kzalloc(sizeof(*subscriber), GFP_ATOMIC);
+	if (!subscriber) {
+		pr_warn("Subscriber rejected, no memory\n");
+		return NULL;
+	}
+	INIT_LIST_HEAD(&subscriber->subscrp_list);
+	subscriber->conid = conid;
+	spin_lock_init(&subscriber->lock);
+
+	return subscriber;
+}
+
 static void tipc_subscrb_delete(struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub;
@@ -301,19 +317,7 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 /* Handle one request to establish a new subscriber */
 static void *tipc_subscrb_connect_cb(int conid)
 {
-	struct tipc_subscriber *subscriber;
-
-	/* Create subscriber object */
-	subscriber = kzalloc(sizeof(struct tipc_subscriber), GFP_ATOMIC);
-	if (subscriber == NULL) {
-		pr_warn("Subscriber rejected, no memory\n");
-		return NULL;
-	}
-	INIT_LIST_HEAD(&subscriber->subscrp_list);
-	subscriber->conid = conid;
-	spin_lock_init(&subscriber->lock);
-
-	return (void *)subscriber;
+	return (void *)tipc_subscrb_create(conid);
 }
 
 int tipc_topsrv_start(struct net *net)
-- 
1.7.9.5


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
