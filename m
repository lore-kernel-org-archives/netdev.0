From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 1/1] tipc: fix stale links
	after re-enabling bearer
Date: Thu, 21 Apr 2016 15:51:13 +0200
Message-ID: <1461246673-6127-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
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

Commit 42b18f605fea ("tipc: refactor function tipc_link_timeout()"),
introduced a bug which prevents sending of probe messages during
link synchronization phase. This leads to hanging links, if the
bearer is disabled/enabled after links are up.

In this commit, we send the probe messages correctly.
Fixes: 42b18f605fea ("tipc: refactor function tipc_link_timeout()")

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/link.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2e28a7d7e802..7059c94f33c5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -721,8 +721,7 @@ int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 		mtyp = STATE_MSG;
 		state = bc_acked != bc_snt;
 		probe = l->silent_intv_cnt;
-		if (probe)
-			l->silent_intv_cnt++;
+		l->silent_intv_cnt++;
 		break;
 	case LINK_RESET:
 		setup = l->rst_cnt++ <= 4;
-- 
2.1.4


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
