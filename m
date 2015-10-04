From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 05/20] bridge: netlink: export root path cost
Date: Sun,  4 Oct 2015 14:23:32 +0200
Message-ID: <1443961427-15085-6-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34261 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbJDMYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:15 -0400
Received: by wicfx3 with SMTP id fx3so85294239wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:14 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_ROOT_PATH_COST and export it via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 172268a5767d..7d7236d143fb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -236,6 +236,7 @@ enum {
 	IFLA_BR_ROOT_ID,
 	IFLA_BR_BRIDGE_ID,
 	IFLA_BR_ROOT_PORT,
+	IFLA_BR_ROOT_PATH_COST,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 652db1ca0acc..cd0488b689d4 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -857,6 +857,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_BRIDGE_ID */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_ROOT_PORT */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_ROOT_PATH_COST */
 	       0;
 }
 
@@ -890,7 +891,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask) ||
 	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id) ||
 	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id) ||
-	    nla_put_u16(skb, IFLA_BR_ROOT_PORT, br->root_port))
+	    nla_put_u16(skb, IFLA_BR_ROOT_PORT, br->root_port) ||
+	    nla_put_u32(skb, IFLA_BR_ROOT_PATH_COST, br->root_path_cost))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
