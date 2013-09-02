From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 19/21] bonding: use neighbours for bond_next/prev_slave()
Date: Mon,  2 Sep 2013 23:39:23 +0200
Message-ID: <1378157965-17537-20-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932280Ab3IBVjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:39 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_lower_dev_get_next_private(), it will return NULL in case the
list is empty, so no need to verify.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6731281..b8047f3 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -76,8 +76,6 @@
 
 #define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
 
-#define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
-
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
 #define bond_first_slave(bond) \
 	(bond_has_slaves(bond) ? \
@@ -93,12 +91,10 @@
 
 /* Since bond_first/last_slave can return NULL, these can return NULL too */
 #define bond_next_slave(bond, pos) \
-	(bond_is_last_slave(bond, pos) ? bond_first_slave(bond) : \
-					 bond_to_slave((pos)->list.next))
+	netdev_lower_dev_get_next_private((bond)->dev, pos, false)
 
 #define bond_prev_slave(bond, pos) \
-	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
-					  bond_to_slave((pos)->list.prev))
+	netdev_lower_dev_get_next_private((bond)->dev, pos, true)
 
 /**
  * bond_for_each_slave_from - iterate the slaves list from a starting point
-- 
1.8.4
