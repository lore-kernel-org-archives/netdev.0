From: akpm@linux-foundation.org
Subject: [patch 05/11] bonding: Replace kmalloc() + memset() pairs with the appropriate kzalloc() calls
Date: Mon, 05 Feb 2007 16:31:04 -0800
Message-ID: <200702060032.l160W7hH004630@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	lkmaillist@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41459 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933159AbXBFAcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Joe Jin" <lkmaillist@gmail.com>

Replace kmalloc() + memset() pairs with the appropriate kzalloc() calls in
the bonding driver.

Signed-off-by: Joe Jin <lkmaillist@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_alb.c  |    4 +---
 drivers/net/bonding/bond_main.c |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff -puN drivers/net/bonding/bond_alb.c~bonding-replace-kmalloc-memset-pairs-with-the-appropriate-kzalloc-calls drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c~bonding-replace-kmalloc-memset-pairs-with-the-appropriate-kzalloc-calls
+++ a/drivers/net/bonding/bond_alb.c
@@ -184,7 +184,7 @@ static int tlb_initialize(struct bonding
 
 	spin_lock_init(&(bond_info->tx_hashtbl_lock));
 
-	new_hashtbl = kmalloc(size, GFP_KERNEL);
+	new_hashtbl = kzalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Error: Failed to allocate TLB hash table\n",
@@ -195,8 +195,6 @@ static int tlb_initialize(struct bonding
 
 	bond_info->tx_hashtbl = new_hashtbl;
 
-	memset(bond_info->tx_hashtbl, 0, size);
-
 	for (i = 0; i < TLB_HASH_TABLE_SIZE; i++) {
 		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 1);
 	}
diff -puN drivers/net/bonding/bond_main.c~bonding-replace-kmalloc-memset-pairs-with-the-appropriate-kzalloc-calls drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-replace-kmalloc-memset-pairs-with-the-appropriate-kzalloc-calls
+++ a/drivers/net/bonding/bond_main.c
@@ -1343,14 +1343,12 @@ int bond_enslave(struct net_device *bond
 			"inaccurate.\n", bond_dev->name, slave_dev->name);
 	}
 
-	new_slave = kmalloc(sizeof(struct slave), GFP_KERNEL);
+	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
 		res = -ENOMEM;
 		goto err_undo_flags;
 	}
 
-	memset(new_slave, 0, sizeof(struct slave));
-
 	/* save slave's original flags before calling
 	 * netdev_set_master and dev_open
 	 */
_
