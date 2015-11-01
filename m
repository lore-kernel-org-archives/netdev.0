From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] bridge: vlan: Use rcu_dereference instead of rtnl_dereference
Date: Sun, 1 Nov 2015 18:31:45 +0200
Message-ID: <1446395505-24841-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<nikolay@cumulusnetworks.com>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0094.outbound.protection.outlook.com ([157.55.234.94]:18722
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752015AbbKAQdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 11:33:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_should_learn() is protected by RCU and not by RTNL, so use correct
flavor of nbp_vlan_group().

Fixes: 907b1e6e83ed ("bridge: vlan: use proper rcu for the vlgrp
member")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f0d0cc..99a083e 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -482,7 +482,7 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 	if (!br->vlan_enabled)
 		return true;
 
-	vg = nbp_vlan_group(p);
+	vg = nbp_vlan_group_rcu(p);
 	if (!vg || !vg->num_vlans)
 		return false;
 
-- 
2.4.10
