From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next] bridge: Add ability to enable TSO
Date: Fri,  9 Jan 2015 14:16:40 +0900
Message-ID: <1420780600-11313-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

Currently a bridge device turns off TSO feature if no bridge ports
support it. We can always enable it, since packets can be segmented on
ports by software as well as on the bridge device.
This will reduce the number of packets processed in the bridge.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
v2: Use an existing helper function.

 net/bridge/br_if.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ed307db..81e49fb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -424,6 +424,7 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
 		features = netdev_increment_features(features,
 						     p->dev->features, mask);
 	}
+	features = netdev_add_tso_features(features, mask);
 
 	return features;
 }
-- 
1.8.1.2
