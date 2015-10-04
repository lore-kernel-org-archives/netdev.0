From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 06/20] bridge: netlink: export topology_change and topology_change_detected
Date: Sun,  4 Oct 2015 14:23:33 +0200
Message-ID: <1443961427-15085-7-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33068 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbJDMYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:17 -0400
Received: by wiclk2 with SMTP id lk2so85746213wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:15 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_TOPOLOGY_CHANGE and IFLA_BR_TOPOLOGY_CHANGE_DETECTED and
export them via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 2 ++
 net/bridge/br_netlink.c      | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 7d7236d143fb..b00286ca1bfe 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -237,6 +237,8 @@ enum {
 	IFLA_BR_BRIDGE_ID,
 	IFLA_BR_ROOT_PORT,
 	IFLA_BR_ROOT_PATH_COST,
+	IFLA_BR_TOPOLOGY_CHANGE,
+	IFLA_BR_TOPOLOGY_CHANGE_DETECTED,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index cd0488b689d4..8bcaa5171f35 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -858,6 +858,8 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_BRIDGE_ID */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_ROOT_PORT */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_ROOT_PATH_COST */
+	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE */
+	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE_DETECTED */
 	       0;
 }
 
@@ -892,7 +894,10 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id) ||
 	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id) ||
 	    nla_put_u16(skb, IFLA_BR_ROOT_PORT, br->root_port) ||
-	    nla_put_u32(skb, IFLA_BR_ROOT_PATH_COST, br->root_path_cost))
+	    nla_put_u32(skb, IFLA_BR_ROOT_PATH_COST, br->root_path_cost) ||
+	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE, br->topology_change) ||
+	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE_DETECTED,
+		       br->topology_change_detected))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
