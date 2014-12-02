From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 7/8] tipc: remove unnecessary
	INIT_LIST_HEAD
Date: Tue, 2 Dec 2014 15:00:29 +0800
Message-ID: <1417503630-31352-8-git-send-email-ying.xue@windriver.com>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a list_head variable is seen as a new entry to be added to a
list head, it's unnecessary to be initialized with INIT_LIST_HEAD().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |    2 --
 net/tipc/subscr.c     |    1 -
 2 files changed, 3 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index bc3e7ed..3c2e0c3 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -131,9 +131,7 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 	publ->node = node;
 	publ->ref = port_ref;
 	publ->key = key;
-	INIT_LIST_HEAD(&publ->local_list);
 	INIT_LIST_HEAD(&publ->pport_list);
-	INIT_LIST_HEAD(&publ->nodesub_list);
 	return publ;
 }
 
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 31b5cb2..0344206 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -305,7 +305,6 @@ static int subscr_subscribe(struct tipc_subscr *s,
 		kfree(sub);
 		return -EINVAL;
 	}
-	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
 	sub->subscriber = subscriber;
 	sub->swap = swap;
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
