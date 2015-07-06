From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: mdb: start delete timer for temp
	static entries
Date: Mon,  6 Jul 2015 05:53:35 -0700
Message-ID: <1436187215-4973-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: amwang@redhat.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
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

Start the delete timer when adding temp static entries so they can expire.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: ccb1c31a7a87 ("bridge: add flags to distinguish permanent mdb entires")
---
 net/bridge/br_mdb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index e29ad70b3000..3bfc675cf0d1 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -323,6 +323,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
 	struct net_bridge_mdb_htable *mdb;
+	unsigned long now = jiffies;
 	int err;
 
 	mdb = mlock_dereference(br->mdb, br);
@@ -347,6 +348,8 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	if (unlikely(!p))
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
+	if (state == MDB_TEMPORARY)
+		mod_timer(&p->timer, now + br->multicast_membership_interval);
 
 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 	return 0;
-- 
1.9.3
