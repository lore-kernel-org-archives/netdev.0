From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/4] bridge: vlan: drop master_flags from
	__vlan_add
Date: Fri,  2 Oct 2015 15:05:12 +0200
Message-ID: <1443791113-12738-4-git-send-email-razor@blackwall.org>
References: <1443791113-12738-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443791113-12738-1-git-send-email-razor@blackwall.org>
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

There's only one user now and we can include the flag directly.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 8481d2567513..1f6f9f5b2c73 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -210,8 +210,6 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 	}
 
 	if (p) {
-		u16 master_flags = flags;
-
 		/* Add VLAN to the device filter if it is supported.
 		 * This ensures tagged traffic enters the bridge when
 		 * promiscuous mode is disabled by br_manage_promisc().
@@ -222,8 +220,8 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 
 		/* need to work on the master vlan too */
 		if (flags & BRIDGE_VLAN_INFO_MASTER) {
-			master_flags |= BRIDGE_VLAN_INFO_BRENTRY;
-			err = br_vlan_add(br, v->vid, master_flags);
+			err = br_vlan_add(br, v->vid, flags |
+						      BRIDGE_VLAN_INFO_BRENTRY);
 			if (err)
 				goto out_filt;
 		}
-- 
2.4.3
