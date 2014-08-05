From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next] bridge: Update outdated comment on
	promiscuous mode
Date: Tue,  5 Aug 2014 15:57:15 +0900
Message-ID: <1407221835-15529-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
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

Now bridge ports can be non-promiscuous, vlan_vid_add() is no longer an
unnecessary operation.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_vlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 2b2774f..febb0f8 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -55,10 +55,8 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 	if (p) {
 		/* Add VLAN to the device filter if it is supported.
-		 * Stricly speaking, this is not necessary now, since
-		 * devices are made promiscuous by the bridge, but if
-		 * that ever changes this code will allow tagged
-		 * traffic to enter the bridge.
+		 * This ensures tagged traffic enters the bridge when
+		 * promiscuous mode is disabled by br_manage_promisc().
 		 */
 		err = vlan_vid_add(dev, br->vlan_proto, vid);
 		if (err)
-- 
1.8.1.2
