From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 10/21] bonding: modify bond_get_slave_by_dev() to use neighbours
Date: Mon,  2 Sep 2013 23:39:14 +0200
Message-ID: <1378157965-17537-11-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758979Ab3IBVlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:41:25 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should be used under rtnl/bonding lock, so use the non-RCU version.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 37055cd..7cb60f9 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -295,13 +295,8 @@ static inline bool bond_vlan_used(struct bonding *bond)
 static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
 						  struct net_device *slave_dev)
 {
-	struct slave *slave = NULL;
-
-	bond_for_each_slave(bond, slave)
-		if (slave->dev == slave_dev)
-			return slave;
-
-	return NULL;
+	return (struct slave *)netdev_lower_dev_get_private(bond->dev,
+							    slave_dev);
 }
 
 static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
-- 
1.8.4
