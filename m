From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 10/27] bonding: use bond_for_each_slave() in bond_uninit()
Date: Tue, 24 Sep 2013 13:46:50 +0200
Message-ID: <1380023227-9576-11-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044Ab3IXLrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:14 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're safe agains removal there, cause we use neighbours primitives.

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
    Move the patch rigth after we start using neighbour lists for
    bond_for_each_slave().

 drivers/net/bonding/bond_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9064e24..85e99ae 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4090,12 +4090,13 @@ static void bond_setup(struct net_device *bond_dev)
 static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *tmp_slave;
+	struct list_head *iter;
+	struct slave *slave;
 
 	bond_netpoll_cleanup(bond_dev);
 
 	/* Release the bonded slaves */
-	list_for_each_entry_safe(slave, tmp_slave, &bond->slave_list, list)
+	bond_for_each_slave(bond, slave, iter)
 		__bond_release_one(bond_dev, slave->dev, true);
 	pr_info("%s: released all slaves\n", bond_dev->name);
 
-- 
1.8.4
