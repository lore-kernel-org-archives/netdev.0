From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 23/27] bonding: remove slave lists
Date: Wed, 25 Sep 2013 09:20:28 +0200
Message-ID: <1380093632-1842-24-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251Ab3IYHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:09 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And all the initialization.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    RFC -> v2:
    New patch.

 drivers/net/bonding/bond_main.c | 4 ----
 drivers/net/bonding/bonding.h   | 2 --
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6aa345a..d494045 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -972,7 +972,6 @@ void bond_select_active_slave(struct bonding *bond)
  */
 static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 {
-	list_add_tail_rcu(&new_slave->list, &bond->slave_list);
 	bond->slave_cnt++;
 }
 
@@ -988,7 +987,6 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
  */
 static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 {
-	list_del_rcu(&slave->list);
 	bond->slave_cnt--;
 }
 
@@ -1374,7 +1372,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		res = -ENOMEM;
 		goto err_undo_flags;
 	}
-	INIT_LIST_HEAD(&new_slave->list);
 	/*
 	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
 	 * is set via sysfs or module option if desired.
@@ -4022,7 +4019,6 @@ static void bond_setup(struct net_device *bond_dev)
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
-	INIT_LIST_HEAD(&bond->slave_list);
 	bond->params = bonding_defaults;
 
 	/* Initialize pointers */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f070557..e5c32a6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -165,7 +165,6 @@ struct bond_parm_tbl {
 
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
-	struct list_head list;
 	struct bonding *bond; /* our master */
 	int    delay;
 	unsigned long jiffies;
@@ -205,7 +204,6 @@ struct slave {
  */
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
-	struct   list_head slave_list;
 	struct   slave *curr_active_slave;
 	struct   slave *current_arp_slave;
 	struct   slave *primary_slave;
-- 
1.8.4
