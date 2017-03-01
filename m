From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH v2] net: bridge: allow IPv6 when multicast flood is disabled
Date: Wed, 1 Mar 2017 09:55:28 +0000
Message-ID: <1488362128-15217-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58742 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751378AbdCAK0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 05:26:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with multicast flooding turned off, IPv6 ND should still work so
that IPv6 connectivity is provided. Allow this by continuing to flood
multicast traffic originated by us.

Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/bridge/br_forward.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6bfac29..902af6b 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -186,8 +186,9 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
 			continue;
+		/* Do not flood if mc off, except for traffic we originate */
 		if (pkt_type == BR_PKT_MULTICAST &&
-		    !(p->flags & BR_MCAST_FLOOD))
+		    !(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
 			continue;
 
 		/* Do not flood to ports that enable proxy ARP */
-- 
2.1.4
