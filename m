From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 4/5] tipc: add a function to
	get the bearer name
Date: Fri, 22 Jul 2016 08:42:47 +0200
Message-ID: <1469169768-9214-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Introduce a new function to get the bearer name from
its id. This is used in subsequent commit.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c | 21 +++++++++++++++++++++
 net/tipc/bearer.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e87731c8998c..6b28f4e27c55 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -171,6 +171,27 @@ struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name)
 	return NULL;
 }
 
+/*     tipc_bearer_get_name - get the bearer name from its id.
+ *     @net: network namespace
+ *     @name: a pointer to the buffer where the name will be stored.
+ *     @bearer_id: the id to get the name from.
+ */
+int tipc_bearer_get_name(struct net *net, char *name, u32 bearer_id)
+{
+	struct tipc_net *tn = tipc_net(net);
+	struct tipc_bearer *b;
+
+	if (bearer_id >= MAX_BEARERS)
+		return -EINVAL;
+
+	b = rtnl_dereference(tn->bearer_list[bearer_id]);
+	if (!b)
+		return -EINVAL;
+
+	strcpy(name, b->name);
+	return 0;
+}
+
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 0d337c7b6fad..ddaf51856414 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -197,6 +197,7 @@ int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
 void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest);
 struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name);
+int tipc_bearer_get_name(struct net *net, char *name, u32 bearer_id);
 struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports.http://sdm.link/zohodev2dev
