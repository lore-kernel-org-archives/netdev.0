From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 20/21] bonding: use bond_for_each_slave() in bond_uninit()
Date: Mon,  2 Sep 2013 23:39:24 +0200
Message-ID: <1378157965-17537-21-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab3IBVjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:40 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're safe agains removal there, cause we use neighbours primitives.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 59814c9..ce1b0fb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4099,12 +4099,13 @@ static void bond_setup(struct net_device *bond_dev)
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
