From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net 1/2] bridge: netlink: account for the IFLA_BRPORT_PROXYARP attribute size and policy
Date: Tue,  4 Aug 2015 19:06:32 +0200
Message-ID: <1438707993-14561-2-git-send-email-razor@blackwall.org>
References: <1438707993-14561-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, kyeyoonp@codeaurora.org,
	jouni@codeaurora.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36793 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbbHDRGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 13:06:52 -0400
Received: by wicgj17 with SMTP id gj17so159443688wic.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 10:06:51 -0700 (PDT)
In-Reply-To: <1438707993-14561-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The attribute size wasn't accounted for in the get_slave_size() callback
(br_port_get_slave_size) when it was introduced, so fix it now. Also add
a policy entry for it in br_port_policy.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")
---
 net/bridge/br_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3da5525eb8a2..5390536d500c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -112,6 +112,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
+		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
 		+ 0;
 }
 
@@ -506,6 +507,7 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_FAST_LEAVE]= { .type = NLA_U8 },
 	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_UNICAST_FLOOD] = { .type = NLA_U8 },
+	[IFLA_BRPORT_PROXYARP]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
-- 
2.4.3
