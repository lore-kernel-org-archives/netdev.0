From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 06/27] bonding: modify bond_get_slave_by_dev() to use neighbours
Date: Tue, 24 Sep 2013 13:46:46 +0200
Message-ID: <1380023227-9576-7-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab3IXLrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:06 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should be used under rtnl/bonding lock, so use the non-RCU version.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Move the patch right after we've populated ->private with bonding.

 drivers/net/bonding/bonding.h | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 03cf3fd..597a4ec 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -276,13 +276,8 @@ struct bonding {
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
