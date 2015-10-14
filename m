From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next 4/4] bridge: Remove br_get_link_af_size
Date: Tue, 13 Oct 2015 22:58:34 -0700
Message-ID: <1444802314-28830-5-git-send-email-ronen.arad@intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbbJNF7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:59:32 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unset get_link_af_size in br_af_ops. br_get_link_af_size() becomes
unused and thus removed.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 net/bridge/br_netlink.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d900881..204222d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1214,29 +1214,9 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
-static size_t br_get_link_af_size(const struct net_device *dev)
-{
-	struct net_bridge_port *p;
-	struct net_bridge *br;
-	int num_vlans = 0;
-
-	if (br_port_exists(dev)) {
-		p = br_port_get_rtnl(dev);
-		num_vlans = br_get_num_vlan_infos(nbp_vlan_group(p),
-						  RTEXT_FILTER_BRVLAN);
-	} else if (dev->priv_flags & IFF_EBRIDGE) {
-		br = netdev_priv(dev);
-		num_vlans = br_get_num_vlan_infos(br_vlan_group(br),
-						  RTEXT_FILTER_BRVLAN);
-	}
-
-	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
-}
 
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family				= AF_BRIDGE,
-	.get_link_af_size		= br_get_link_af_size,
 	.get_link_af_size_filtered	= br_get_link_af_size_filtered,
 };
 
-- 
2.1.0
