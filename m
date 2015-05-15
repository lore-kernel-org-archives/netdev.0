From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] bridge: Fix setting a flag in br_fill_ifvlaninfo_range().
Date: Fri, 15 May 2015 17:27:27 +0300
Message-ID: <1431700047-22560-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	ronen.arad@intel.com, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19592 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933827AbbEOLhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 07:37:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes setting of vinfo.flags in the br_fill_ifvlaninfo_range(). The  
assignment of vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN has no effect without 
this patch, as vinfo.flags value is overriden by the 
vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END assignement,  which follows 
it immedialtely.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/bridge/br_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6b67ed3..fec65bb 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -167,7 +167,7 @@ static int br_fill_ifvlaninfo_range(struct sk_buff *skb, u16 vid_start,
 		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
 
 		vinfo.vid = vid_end;
-		vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END;
+		vinfo.flags &= flags | BRIDGE_VLAN_INFO_RANGE_END;
 		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
 			    sizeof(vinfo), &vinfo))
 			goto nla_put_failure;
-- 
1.9.3
