From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 5/8] bridge: netlink: export port's topology_change_ack and config_pending
Date: Tue,  6 Oct 2015 14:11:59 +0200
Message-ID: <1444133522-16907-6-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34896 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbJFMM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:29 -0400
Received: by wicge5 with SMTP id ge5so163825003wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:28 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BRPORT_TOPOLOGY_CHANGE_ACK and IFLA_BRPORT_CONFIG_PENDING to
allow getting port's topology_change_ack and config_pending respectively
via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 2 ++
 net/bridge/br_netlink.c      | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6857563eb27c..1d6aeb1bbe95 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -298,6 +298,8 @@ enum {
 	IFLA_BRPORT_DESIGNATED_COST,
 	IFLA_BRPORT_ID,
 	IFLA_BRPORT_NO,
+	IFLA_BRPORT_TOPOLOGY_CHANGE_ACK,
+	IFLA_BRPORT_CONFIG_PENDING,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e51332792c3c..433d632ad7d0 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -133,6 +133,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_COST */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_ID */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_NO */
+		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_TOPOLOGY_CHANGE_ACK */
+		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_CONFIG_PENDING */
 		+ 0;
 }
 
@@ -174,7 +176,10 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_PORT, p->designated_port) ||
 	    nla_put_u16(skb, IFLA_BRPORT_DESIGNATED_COST, p->designated_cost) ||
 	    nla_put_u16(skb, IFLA_BRPORT_ID, p->port_id) ||
-	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no))
+	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no) ||
+	    nla_put_u8(skb, IFLA_BRPORT_TOPOLOGY_CHANGE_ACK,
+		       p->topology_change_ack) ||
+	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.4.3
