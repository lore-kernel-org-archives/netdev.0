From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 04/20] bridge: netlink: export root port
Date: Sun,  4 Oct 2015 14:23:31 +0200
Message-ID: <1443961427-15085-5-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
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

Add IFLA_BR_ROOT_PORT and export it via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 748495438a8b..172268a5767d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -235,6 +235,7 @@ enum {
 	IFLA_BR_GROUP_FWD_MASK,
 	IFLA_BR_ROOT_ID,
 	IFLA_BR_BRIDGE_ID,
+	IFLA_BR_ROOT_PORT,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a63f944a7f12..652db1ca0acc 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -856,6 +856,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_BRIDGE_ID */
+	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_ROOT_PORT */
 	       0;
 }
 
@@ -888,7 +889,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask) ||
 	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id) ||
-	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id))
+	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id) ||
+	    nla_put_u16(skb, IFLA_BR_ROOT_PORT, br->root_port))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
