From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next v2 1/1] bridge: return error code when deleting Vlan
Date: Thu, 12 Oct 2017 09:51:54 -0400
Message-ID: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
Cc: stephen@networkplumber.org, dsahern@gmail.com,
        netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:53768 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdJLNwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 09:52:06 -0400
Received: by mail-io0-f193.google.com with SMTP id 189so5536699iow.10
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 06:52:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
 Return err immediately if nbp_vlan_delete() fails (pointed by David Ahern)

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 net/bridge/br_netlink.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f0e8268..1efdd48 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -527,11 +527,13 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 
 	case RTM_DELLINK:
 		if (p) {
-			nbp_vlan_delete(p, vinfo->vid);
+			err = nbp_vlan_delete(p, vinfo->vid);
+			if (err)
+				break;
 			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-				br_vlan_delete(p->br, vinfo->vid);
+				err = br_vlan_delete(p->br, vinfo->vid);
 		} else {
-			br_vlan_delete(br, vinfo->vid);
+			err = br_vlan_delete(br, vinfo->vid);
 		}
 		break;
 	}
-- 
1.9.1
