From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/8] bridge: netlink: export port's designated cost and port
Date: Tue,  6 Oct 2015 14:11:57 +0200
Message-ID: <1444133522-16907-4-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34149 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbJFMM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:26 -0400
Received: by wicfx3 with SMTP id fx3so163072652wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:25 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BRPORT_DESIGNATED_(COST|PORT) to allow getting the port's
designated cost and port respectively via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 2 ++
 net/bridge/br_netlink.c      | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e891c32c9993..837caf940135 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -294,6 +294,8 @@ enum {
 	IFLA_BRPORT_PROXYARP_WIFI, /* proxy ARP for Wi-Fi */
 	IFLA_BRPORT_ROOT_ID,	/* designated root */
 	IFLA_BRPORT_BRIDGE_ID,	/* designated bridge */
+	IFLA_BRPORT_DESIGNATED_PORT,
+	IFLA_BRPORT_DESIGNATED_COST,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c3e0b73d660d..678d22747044 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -129,6 +129,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_ROOT_ID */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_BRIDGE_ID */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_PORT */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_COST */
 		+ 0;
 }
 
@@ -166,7 +168,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put(skb, IFLA_BRPORT_ROOT_ID, sizeof(struct ifla_bridge_id),
 		    &p->designated_root) ||
 	    nla_put(skb, IFLA_BRPORT_BRIDGE_ID, sizeof(struct ifla_bridge_id),
-		    &p->designated_bridge))
+		    &p->designated_bridge) ||
+	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_PORT, p->designated_port) ||
+	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_COST, p->designated_cost))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.4.3
