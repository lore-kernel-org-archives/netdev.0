From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next] bonding: use kobject_put instead of _del after kobject_add
Date: Tue, 29 Jul 2014 13:27:43 +0200
Message-ID: <1406633263-2115-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbaG2LcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 07:32:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the name of the kobject isn't getting freed and other stuff from
kobject_cleanup() isn't getting called. kobject_put() will call
kobject_del() on its own in kobject_cleanup().

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_sysfs_slave.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index 198677f..5cd532c 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -125,7 +125,7 @@ int bond_sysfs_slave_add(struct slave *slave)
 	for (a = slave_attrs; *a; ++a) {
 		err = sysfs_create_file(&slave->kobj, &((*a)->attr));
 		if (err) {
-			kobject_del(&slave->kobj);
+			kobject_put(&slave->kobj);
 			return err;
 		}
 	}
@@ -140,5 +140,5 @@ void bond_sysfs_slave_del(struct slave *slave)
 	for (a = slave_attrs; *a; ++a)
 		sysfs_remove_file(&slave->kobj, &((*a)->attr));
 
-	kobject_del(&slave->kobj);
+	kobject_put(&slave->kobj);
 }
-- 
1.8.4
