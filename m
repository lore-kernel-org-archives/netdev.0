From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: mdb: allow the user to delete mdb
	entry if there's a querier
Date: Thu,  9 Jul 2015 04:12:45 -0700
Message-ID: <1436440365-909-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, davem@davemloft.net
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

From: Satish Ashok <sashok@cumulusnetworks.com>

Until now when a querier was present static entries couldn't be deleted.
Fix this and allow the user to manipulate the mdb with or without a
querier.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_mdb.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 60868c212679..c11cf2611db0 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -423,19 +423,12 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 
 	memset(&ip, 0, sizeof(ip));
 	ip.proto = entry->addr.proto;
-	if (ip.proto == htons(ETH_P_IP)) {
-		if (timer_pending(&br->ip4_other_query.timer))
-			return -EBUSY;
-
+	if (ip.proto == htons(ETH_P_IP))
 		ip.u.ip4 = entry->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-	} else {
-		if (timer_pending(&br->ip6_other_query.timer))
-			return -EBUSY;
-
+	else
 		ip.u.ip6 = entry->addr.u.ip6;
 #endif
-	}
 
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
-- 
1.9.1
