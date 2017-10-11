From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 1/1] bridge: return error code when deleting Vlan
Date: Wed, 11 Oct 2017 17:29:45 -0400
Message-ID: <1507757385-32256-1-git-send-email-mrv@mojatatu.com>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46504 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752411AbdJKV3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:29:54 -0400
Received: by mail-io0-f196.google.com with SMTP id 101so3327086ioj.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:29:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 net/bridge/br_netlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f0e8268..a1e1ca8 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -527,11 +527,11 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 
 	case RTM_DELLINK:
 		if (p) {
-			nbp_vlan_delete(p, vinfo->vid);
+			err = nbp_vlan_delete(p, vinfo->vid);
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
