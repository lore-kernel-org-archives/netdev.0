From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] bridge: netlink: account for IFLA_BRPORT_{B,M}CAST_FLOOD size and policy
Date: Fri,  5 May 2017 16:36:53 +0200
Message-ID: <20170505143653.8486-1-tklauser@distanz.ch>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Mike Manning <mmanning@brocade.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:33586 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751899AbdEEOhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 10:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The attribute sizes for IFLA_BRPORT_MCAST_FLOOD and
IFLA_BRPORT_BCAST_FLOOD weren't accounted for in br_port_info_size()
when they were added. Do so now and also add the corresponding policy
entries:

Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Mike Manning <mmanning@brocade.com>
Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
Fixes: 99f906e9ad7b ("bridge: add per-port broadcast flood flag")
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/bridge/br_netlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a572db710d4e..c5ce7745b230 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -133,6 +133,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_MCAST_TO_UCAST */
 		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
+		+ nla_total_size(1)	/* IFLA_BRPORT_MCAST_FLOOD */
+		+ nla_total_size(1)	/* IFLA_BRPORT_BCAST_FLOOD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
 		+ nla_total_size(1)	/* IFLA_BRPORT_VLAN_TUNNEL */
@@ -633,6 +635,8 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_PROXYARP_WIFI] = { .type = NLA_U8 },
 	[IFLA_BRPORT_MULTICAST_ROUTER] = { .type = NLA_U8 },
 	[IFLA_BRPORT_MCAST_TO_UCAST] = { .type = NLA_U8 },
+	[IFLA_BRPORT_MCAST_FLOOD] = { .type = NLA_U8 },
+	[IFLA_BRPORT_BCAST_FLOOD] = { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
-- 
2.12.2
