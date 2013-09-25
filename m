From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 06/27] bonding: modify bond_get_slave_by_dev() to use neighbours
Date: Wed, 25 Sep 2013 09:20:11 +0200
Message-ID: <1380093632-1842-7-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6483 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836Ab3IYHUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:20:40 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should be used under rtnl/bonding lock, so use the non-RCU version.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5:
    Removed casting of NULL pointer.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Move the patch right after we've populated ->private with bonding.

 drivers/net/bonding/bonding.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 03cf3fd..90f4847 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -276,13 +276,7 @@ struct bonding {
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
+	return netdev_lower_dev_get_private(bond->dev, slave_dev);
 }
 
 static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
-- 
1.8.4
