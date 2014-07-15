From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 08/12] bonding: convert bond_netlink.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:05 +0200
Message-ID: <1405445769-15394-9-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757403AbaGORkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:47 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_netlink.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 5ab3c18..d4e2932 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -181,8 +181,7 @@ static int bond_changelink(struct net_device *bond_dev,
 		int arp_interval = nla_get_u32(data[IFLA_BOND_ARP_INTERVAL]);
 
 		if (arp_interval && miimon) {
-			pr_err("%s: ARP monitoring cannot be used with MII monitoring\n",
-			       bond->dev->name);
+			netdev_err(bond->dev, "ARP monitoring cannot be used with MII monitoring\n");
 			return -EINVAL;
 		}
 
@@ -207,8 +206,7 @@ static int bond_changelink(struct net_device *bond_dev,
 			i++;
 		}
 		if (i == 0 && bond->params.arp_interval)
-			pr_warn("%s: Removing last arp target with arp_interval on\n",
-				bond->dev->name);
+			netdev_warn(bond->dev, "Removing last arp target with arp_interval on\n");
 		if (err)
 			return err;
 	}
@@ -216,8 +214,7 @@ static int bond_changelink(struct net_device *bond_dev,
 		int arp_validate = nla_get_u32(data[IFLA_BOND_ARP_VALIDATE]);
 
 		if (arp_validate && miimon) {
-			pr_err("%s: ARP validating cannot be used with MII monitoring\n",
-			       bond->dev->name);
+			netdev_err(bond->dev, "ARP validating cannot be used with MII monitoring\n");
 			return -EINVAL;
 		}
 
-- 
1.8.4
