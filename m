From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: combine pr_debugs in bond_set_dev_addr into one
Date: Sat, 29 Jun 2013 13:16:59 +0200
Message-ID: <1372504619-30123-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab3F2LU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 07:20:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combine the multiple pr_debugs in bond_set_dev_addr into one pr_debug.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ec44580b..742c193 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -843,9 +843,8 @@ static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 static void bond_set_dev_addr(struct net_device *bond_dev,
 			      struct net_device *slave_dev)
 {
-	pr_debug("bond_dev=%p\n", bond_dev);
-	pr_debug("slave_dev=%p\n", slave_dev);
-	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
+	pr_debug("bond_dev=%p slave_dev=%p slave_dev->addr_len=%d\n",
+		 bond_dev, slave_dev, slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
 	bond_dev->addr_assign_type = NET_ADDR_STOLEN;
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
-- 
1.8.1.4
