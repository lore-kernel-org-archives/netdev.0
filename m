From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 1/4] bridge: Add 802.1ad tx vlan
	acceleration
Date: Tue, 10 Jun 2014 20:59:22 +0900
Message-ID: <1402401565-15423-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

Bridge device doesn't need to embed S-tag into skb->data.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d77e2f0..82a410a 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -361,8 +361,9 @@ void br_dev_setup(struct net_device *dev)
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL |
-			NETIF_F_HW_VLAN_CTAG_TX;
-	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX;
+			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
+	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_STAG_TX;
 	dev->vlan_features = COMMON_FEATURES;
 
 	br->dev = dev;
-- 
1.8.1.2
