From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 22/27] bonding: use neighbours for bond_next_slave()
Date: Wed, 25 Sep 2013 09:20:27 +0200
Message-ID: <1380093632-1842-23-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab3IYHVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:08 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new function __bond_next_slave().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    Use the bonding-specific function, instead of the general netdev, which
    was removed.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Change to standard logic - if it's the last slave - return the first one,
    otherwise - return the next via netdev_lower_dev_get_next_private().
    Also, bond_prev_slave() was dropped - so we don't need it.

 drivers/net/bonding/bonding.h | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4a3fbe3..f070557 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -76,8 +76,6 @@
 
 #define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
 
-#define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
-
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
 #define bond_first_slave(bond) \
 	(bond_has_slaves(bond) ? \
@@ -92,9 +90,7 @@
 #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
 
 /* Since bond_first/last_slave can return NULL, these can return NULL too */
-#define bond_next_slave(bond, pos) \
-	(bond_is_last_slave(bond, pos) ? bond_first_slave(bond) : \
-					 bond_to_slave((pos)->list.next))
+#define bond_next_slave(bond, pos) __bond_next_slave(bond, pos)
 
 /**
  * bond_for_each_slave - iterate over all slaves
-- 
1.8.4
