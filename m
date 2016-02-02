From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH] bonding: add slave device name for debug
Date: Tue,  2 Feb 2016 08:32:55 +0000
Message-ID: <1454401975-25984-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: j.vosburgh@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2869 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbcBBIcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 03:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_dbg() will add bond device name, it will be helpful if we print
slave device name.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b5605..fb4c52f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -618,8 +618,8 @@ static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 static void bond_set_dev_addr(struct net_device *bond_dev,
 			      struct net_device *slave_dev)
 {
-	netdev_dbg(bond_dev, "bond_dev=%p slave_dev=%p slave_dev->addr_len=%d\n",
-		   bond_dev, slave_dev, slave_dev->addr_len);
+	netdev_dbg(bond_dev, "bond_dev=%p slave_dev=%p slave_dev->name=%s slave_dev->addr_len=%d\n",
+		   bond_dev, slave_dev, slave_dev->name, slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
 	bond_dev->addr_assign_type = NET_ADDR_STOLEN;
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
-- 
1.8.3.1
