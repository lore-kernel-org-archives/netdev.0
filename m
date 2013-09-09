From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 22/26] bonding: use neighbours for bond_next_slave()
Date: Mon,  9 Sep 2013 22:16:40 +0200
Message-ID: <1378757804-3159-23-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab3IIURJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:17:09 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If it's the last slave - return the first slave, otherwise - return the
next slave via netdev_lower_dev_get_next_private().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 03daadd..9329509 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -76,8 +76,6 @@
 
 #define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
 
-#define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
-
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
 #define bond_first_slave(bond) \
 	(bond_has_slaves(bond) ? \
@@ -93,8 +91,9 @@
 
 /* Since bond_first/last_slave can return NULL, these can return NULL too */
 #define bond_next_slave(bond, pos) \
-	(bond_is_last_slave(bond, pos) ? bond_first_slave(bond) : \
-					 bond_to_slave((pos)->list.next))
+	(bond_is_last_slave(bond, pos) ? \
+		bond_first_slave(bond) : \
+		netdev_lower_dev_get_next_private((bond)->dev, pos))
 
 /**
  * bond_for_each_slave - iterate over all slaves
-- 
1.8.4
