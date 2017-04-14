From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: bridge: notify on hw fdb takeover
Date: Fri, 14 Apr 2017 13:49:34 +0300
Message-ID: <1492166974-20578-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: idosch@mellanox.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

Recently we added support for SW fdbs to take over HW ones, but that
results in changing a user-visible fdb flag thus we need to send a
notification, also it's consistent with how HW takes over SW entries.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5a40a87c4f4f..de7988b0349e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -595,8 +595,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
 			/* Take over HW learned entry */
-			if (unlikely(fdb->added_by_external_learn))
+			if (unlikely(fdb->added_by_external_learn)) {
 				fdb->added_by_external_learn = 0;
+				fdb_modified = true;
+			}
 			if (unlikely(fdb_modified))
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
-- 
2.1.4
