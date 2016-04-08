From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 1/6] bridge: simplify the flush_store by
	calling store_bridge_parm
Date: Sat,  9 Apr 2016 00:03:28 +0800
Message-ID: <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
Cc: nikolay@cumulusnetworks.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
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

There are some repetitive codes in flush_store, we can remove
them by calling store_bridge_parm, also, it would send rtnl notification
after we add it in store_bridge_parm in the following patches.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 6b80914..c48f6b0 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -336,17 +336,17 @@ static ssize_t group_addr_store(struct device *d,
 
 static DEVICE_ATTR_RW(group_addr);
 
+static int set_flush(struct net_bridge *br, unsigned long val)
+{
+	br_fdb_flush(br);
+	return 0;
+}
+
 static ssize_t flush_store(struct device *d,
 			   struct device_attribute *attr,
 			   const char *buf, size_t len)
 {
-	struct net_bridge *br = to_bridge(d);
-
-	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
-		return -EPERM;
-
-	br_fdb_flush(br);
-	return len;
+	return store_bridge_parm(d, buf, len, set_flush);
 }
 static DEVICE_ATTR_WO(flush);
 
-- 
2.1.0
