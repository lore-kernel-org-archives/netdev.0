From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC WIP 2/5] net: bridge: Skip receive handler on brX interface
Date: Sat, 26 Aug 2017 22:56:07 +0200
Message-ID: <1503780970-10312-3-git-send-email-andrew@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45149 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHZU6b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Aug 2017 16:58:31 -0400
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The brX interface will soon become a member of the bridge. As such, it
will get a receiver handler assigned. However, we don't want to handle
packets received on this soft interfaces. So detect the condition and
say all the packets pass.
---
 net/bridge/br_input.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7637f58c1226..38c2a41968f2 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -267,6 +267,10 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_CONSUMED;
 
 	p = br_port_get_rcu(skb->dev);
+
+	if (p->dev == p->br->dev)
+		return RX_HANDLER_PASS;
+
 	if (p->flags & BR_VLAN_TUNNEL) {
 		if (br_handle_ingress_vlan_tunnel(skb, p,
 						  nbp_vlan_group_rcu(p)))
-- 
2.14.1
