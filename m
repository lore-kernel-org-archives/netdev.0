From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/8] bridge: netlink: export port's root id
Date: Tue,  6 Oct 2015 14:11:55 +0200
Message-ID: <1444133522-16907-2-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37271 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbJFMMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:23 -0400
Received: by wicfx3 with SMTP id fx3so155687325wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:22 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BRPORT_ROOT_ID to allow getting the designated root id via
netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c5b15bfeabe2..c45c1d7894e7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -292,6 +292,7 @@ enum {
 	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
 	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
 	IFLA_BRPORT_PROXYARP_WIFI, /* proxy ARP for Wi-Fi */
+	IFLA_BRPORT_ROOT_ID,	/* designated root */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 330abf4b033a..cad4050310ee 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -127,6 +127,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
+		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_ROOT_ID */
 		+ 0;
 }
 
@@ -160,7 +161,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP_WIFI,
-		       !!(p->flags & BR_PROXYARP_WIFI)))
+		       !!(p->flags & BR_PROXYARP_WIFI)) ||
+	    nla_put(skb, IFLA_BRPORT_ROOT_ID, sizeof(struct ifla_bridge_id),
+		    &p->designated_root))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.4.3
