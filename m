From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 07/12] bonding: convert bond_debugfs.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:04 +0200
Message-ID: <1405445769-15394-8-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756096AbaGORks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:48 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One occurance left intact as it's unrelated to net_device.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_debugfs.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 658e761..280971b 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -69,8 +69,7 @@ void bond_debug_register(struct bonding *bond)
 		debugfs_create_dir(bond->dev->name, bonding_debug_root);
 
 	if (!bond->debug_dir) {
-		pr_warn("%s: Warning: failed to register to debugfs\n",
-			bond->dev->name);
+		netdev_warn(bond->dev, "failed to register to debugfs\n");
 		return;
 	}
 
@@ -98,8 +97,7 @@ void bond_debug_reregister(struct bonding *bond)
 	if (d) {
 		bond->debug_dir = d;
 	} else {
-		pr_warn("%s: Warning: failed to reregister, so just unregister old one\n",
-			bond->dev->name);
+		netdev_warn(bond->dev, "failed to reregister, so just unregister old one\n");
 		bond_debug_unregister(bond);
 	}
 }
-- 
1.8.4
