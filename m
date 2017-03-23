From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: [PATCH net-next 1/2] net: bridge: allow SW learn to take
	over HW fdb entries
Date: Thu, 23 Mar 2017 12:27:12 +0200
Message-ID: <1490264833-28867-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: jiri@resnulli.us, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	idosch@mellanox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Allow to take over an entry which was previously learned via HW when it
shows up from a SW port. This is analogous to how HW takes over SW learned
entries already.

Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 4f598dc2d916..e4c8adf517ea 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -594,6 +594,9 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				fdb->updated = now;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
+			/* Take over HW learned entry */
+			if (unlikely(fdb->added_by_external_learn))
+				fdb->added_by_external_learn = 0;
 			if (unlikely(fdb_modified))
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
-- 
2.1.4
