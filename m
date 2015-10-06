From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/8] bridge: netlink: export port's id and number
Date: Tue,  6 Oct 2015 14:11:58 +0200
Message-ID: <1444133522-16907-5-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33501 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbbJFMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:27 -0400
Received: by wiclk2 with SMTP id lk2so163786767wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:26 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BRPORT_(ID|NO) to allow getting port's port_id and port_no
respectively via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 2 ++
 net/bridge/br_netlink.c      | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 837caf940135..6857563eb27c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -296,6 +296,8 @@ enum {
 	IFLA_BRPORT_BRIDGE_ID,	/* designated bridge */
 	IFLA_BRPORT_DESIGNATED_PORT,
 	IFLA_BRPORT_DESIGNATED_COST,
+	IFLA_BRPORT_ID,
+	IFLA_BRPORT_NO,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 678d22747044..e51332792c3c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -131,6 +131,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_BRIDGE_ID */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_PORT */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_COST */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_ID */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_NO */
 		+ 0;
 }
 
@@ -170,7 +172,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put(skb, IFLA_BRPORT_BRIDGE_ID, sizeof(struct ifla_bridge_id),
 		    &p->designated_bridge) ||
 	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_PORT, p->designated_port) ||
-	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_COST, p->designated_cost))
+	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_COST, p->designated_cost) ||
+	    nla_put_u16(skb, IFLA_BRPORT_ID, p->port_id) ||
+	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.4.3
