From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/1] tipc: fix variable dereference
	before NULL check
Date: Wed, 10 Aug 2016 14:07:34 +0200
Message-ID: <1470830854-4072-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
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

In commit cf6f7e1d5109 ("tipc: dump monitor attributes"),
I dereferenced a pointer before checking if its valid.
This is reported by static check Smatch as:
net/tipc/monitor.c:733 tipc_nl_add_monitor_peer()
     warn: variable dereferenced before check 'mon' (see line 731)

In this commit, we check for a valid monitor before proceeding
with any other operation.

Fixes: cf6f7e1d5109 ("tipc: dump monitor attributes")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/monitor.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index b62caa1c770c..ed97a5876ebe 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -728,12 +728,13 @@ int tipc_nl_add_monitor_peer(struct net *net, struct tipc_nl_msg *msg,
 			     u32 bearer_id, u32 *prev_node)
 {
 	struct tipc_monitor *mon = tipc_monitor(net, bearer_id);
-	struct tipc_peer *peer = mon->self;
+	struct tipc_peer *peer;
 
 	if (!mon)
 		return -EINVAL;
 
 	read_lock_bh(&mon->lock);
+	peer = mon->self;
 	do {
 		if (*prev_node) {
 			if (peer->addr == *prev_node)
-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. http://sdm.link/zohodev2dev
