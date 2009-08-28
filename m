From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: use compare_ether_addr
Date: Fri, 28 Aug 2009 14:57:50 -0700
Message-ID: <1251496672-14498-3-git-send-email-fubar@us.ibm.com>
References: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-2-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53389 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbZH1V5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 17:57:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SLqD29009281
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:52:13 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SLvsFY226502
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:54 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SLvrVY011628
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:54 -0600
In-Reply-To: <1251496672-14498-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Bonding can use compare_ether_addr() in bond_release.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1aeb36c..ed00ba9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1796,7 +1796,6 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
-	int mac_addr_differ;
 
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
@@ -1820,9 +1819,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	if (!bond->params.fail_over_mac) {
-		mac_addr_differ = memcmp(bond_dev->dev_addr, slave->perm_hwaddr,
-					 ETH_ALEN);
-		if (!mac_addr_differ && (bond->slave_cnt > 1))
+		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr)
+		    && bond->slave_cnt > 1)
 			pr_warning(DRV_NAME
 			       ": %s: Warning: the permanent HWaddr of %s - "
 			       "%pM - is still in use by %s. "
-- 
1.6.0.2

