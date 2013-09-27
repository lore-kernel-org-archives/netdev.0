From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 9/9] bonding: remove bond_next_slave()
Date: Fri, 27 Sep 2013 16:12:05 +0200
Message-ID: <1380291125-5671-10-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab3I0ONH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:13:07 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no users left, so it's safe to remove.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5b71601..713b6af 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -89,9 +89,6 @@
 #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
 #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
 
-/* Since bond_first/last_slave can return NULL, these can return NULL too */
-#define bond_next_slave(bond, pos) __bond_next_slave(bond, pos)
-
 /**
  * bond_for_each_slave - iterate over all slaves
  * @bond:	the bond holding this list
@@ -244,34 +241,6 @@ struct bonding {
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
 /**
- * __bond_next_slave - get the next slave after the one provided
- * @bond - bonding struct
- * @slave - the slave provided
- *
- * Returns the next slave after the slave provided, first slave if the
- * slave provided is the last slave and NULL if slave is not found
- */
-static inline struct slave *__bond_next_slave(struct bonding *bond,
-					      struct slave *slave)
-{
-	struct slave *slave_iter;
-	struct list_head *iter;
-	bool found = false;
-
-	netdev_for_each_lower_private(bond->dev, slave_iter, iter) {
-		if (found)
-			return slave_iter;
-		if (slave_iter == slave)
-			found = true;
-	}
-
-	if (found)
-		return bond_first_slave(bond);
-
-	return NULL;
-}
-
-/**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
  * Caller must hold bond lock for read
-- 
1.8.4
