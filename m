From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: [PATCH net-next] net: bridge: export also pvid flag in the
	xstats flags
Date: Thu, 25 Aug 2016 14:27:51 +0200
Message-ID: <1472128071-17235-1-git-send-email-nikolay@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
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

When I added support to export the vlan entry flags via xstats I forgot to
add support for the pvid since it is manually matched, so check if the
entry matches the vlan_group's pvid and set the flag appropriately.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 872d4c0deb59..190a5bc00f4a 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1313,6 +1313,9 @@ static int br_fill_linkxstats(struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	if (vg) {
+		u16 pvid;
+
+		pvid = br_get_pvid(vg);
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			struct bridge_vlan_xstats vxi;
 			struct br_vlan_stats stats;
@@ -1322,6 +1325,8 @@ static int br_fill_linkxstats(struct sk_buff *skb,
 			memset(&vxi, 0, sizeof(vxi));
 			vxi.vid = v->vid;
 			vxi.flags = v->flags;
+			if (v->vid == pvid)
+				vxi.flags |= BRIDGE_VLAN_INFO_PVID;
 			br_vlan_get_stats(v, &stats);
 			vxi.rx_bytes = stats.rx_bytes;
 			vxi.rx_packets = stats.rx_packets;
-- 
2.1.4
