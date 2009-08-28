From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST net-next-2.6 2/4] bonding: use compare_ether_addr
Date: Fri, 28 Aug 2009 15:05:13 -0700
Message-ID: <1251497115-16234-3-git-send-email-fubar@us.ibm.com>
References: <1251497115-16234-1-git-send-email-fubar@us.ibm.com>
 <1251497115-16234-2-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49890 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbZH1WFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 18:05:21 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SM3Ic0003005
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:03:18 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SM5ISt178876
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:05:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SM5IMh005561
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:05:18 -0600
In-Reply-To: <1251497115-16234-2-git-send-email-fubar@us.ibm.com>
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

