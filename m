From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 07/11] tipc: use
	skb_queue_walk_safe marco to simplify link_prepare_wakeup routine
Date: Wed, 26 Nov 2014 11:41:51 +0800
Message-ID: <1416973315-6047-8-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 8eb885e..ddee498 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -367,15 +367,15 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
  */
 static void link_prepare_wakeup(struct tipc_link *link)
 {
-	struct sk_buff_head *wq = &link->waiting_sks;
-	struct sk_buff *buf;
 	uint pend_qsz = link->out_queue_size;
+	struct sk_buff *skb, *tmp;
 
-	for (buf = skb_peek(wq); buf; buf = skb_peek(wq)) {
-		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(buf)->chain_imp])
+	skb_queue_walk_safe(&link->waiting_sks, skb, tmp) {
+		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(skb)->chain_imp])
 			break;
-		pend_qsz += TIPC_SKB_CB(buf)->chain_sz;
-		__skb_queue_tail(&link->owner->waiting_sks, __skb_dequeue(wq));
+		pend_qsz += TIPC_SKB_CB(skb)->chain_sz;
+		__skb_unlink(skb, &link->waiting_sks);
+		__skb_queue_tail(&link->owner->waiting_sks, skb);
 	}
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
