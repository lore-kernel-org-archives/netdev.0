From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next v2] bridge: Fix setting a flag in br_fill_ifvlaninfo_range().
Date: Wed, 22 Jul 2015 07:57:02 +0300
Message-ID: <1437541022-14250-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20526 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbbGVE5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 00:57:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes setting of vinfo.flags in the br_fill_ifvlaninfo_range() method. The
assignment of vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN has no effect and is
unneeded, as vinfo.flags value is overriden by the  immediately following 
vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END assignement.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/bridge/br_netlink.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 364bdc9..793d247 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -164,8 +164,6 @@ static int br_fill_ifvlaninfo_range(struct sk_buff *skb, u16 vid_start,
 			    sizeof(vinfo), &vinfo))
 			goto nla_put_failure;
 
-		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
-
 		vinfo.vid = vid_end;
 		vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END;
 		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
-- 
1.9.3
