From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] bridge: reset bridge mtu after deleting an interface
Date: Fri, 13 Mar 2015 07:08:22 -0700
Message-ID: <20150313140822.GA30448@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44466 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbbCMOIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:08:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On adding an interface br_add_if() sets the MTU to the min of
all the interfaces. Do the same thing on removing an interface too
in br_del_if.

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
---
 net/bridge/br_if.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index b087d27..1849d96 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -563,6 +563,8 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	 */
 	del_nbp(p);
 
+	dev_set_mtu(br->dev, br_min_mtu(br));
+
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
 	spin_unlock_bh(&br->lock);
-- 
1.8.2.1
