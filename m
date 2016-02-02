From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 01/10] tipc: remove incorrect
	check for subscription timeout value
Date: Tue, 2 Feb 2016 10:52:08 +0100
Message-ID: <1454406737-5806-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now, during subscription creation we set sub->timeout by
converting the timeout request value in milliseconds to jiffies.
This is followed by setting the timeout value in the timer if
sub->timeout != TIPC_WAIT_FOREVER.

For a subscription create request with a timeout value of
TIPC_WAIT_FOREVER, msecs_to_jiffies(TIPC_WAIT_FOREVER)
returns MAX_JIFFY_OFFSET (0xfffffffe). This is not equal to
TIPC_WAIT_FOREVER (0xffffffff).

In this commit, we remove this check.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 350cca33ee0a..991ac81b3920 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -270,8 +270,7 @@ static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
 	memcpy(&sub->evt.s, s, sizeof(*s));
 	atomic_inc(&tn->subscription_count);
 	setup_timer(&sub->timer, tipc_subscrp_timeout, (unsigned long)sub);
-	if (sub->timeout != TIPC_WAIT_FOREVER)
-		sub->timeout += jiffies;
+	sub->timeout += jiffies;
 	if (!mod_timer(&sub->timer, sub->timeout))
 		tipc_subscrb_get(subscriber);
 	*sub_p = sub;
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
