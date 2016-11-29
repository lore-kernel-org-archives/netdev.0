From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v3 net-next 1/3] openvswitch: Add a missing break statement.
Date: Tue, 29 Nov 2016 15:30:51 -0800
Message-ID: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, jbenc@redhat.com, pshelar@ovn.org, e@erig.me
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:57091 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754543AbcK2XbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:31:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a break statement to prevent fall-through from
OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
actions setting ethernet addresses fail to validate with log messages
complaining about invalid tunnel attributes.

Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
Acked-by: Jiri Benc <jbenc@redhat.com>
---
v3: No change.

 net/openvswitch/flow_netlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d19044f..c87d359 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2195,6 +2195,7 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_ETHERNET:
 		if (mac_proto != MAC_PROTO_ETHERNET)
 			return -EINVAL;
+		break;
 
 	case OVS_KEY_ATTR_TUNNEL:
 		if (masked)
-- 
2.1.4
