From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] bonding: remove the redundant judgements for bond_set_mac_address()
Date: Wed, 12 Feb 2014 14:58:49 +0800
Message-ID: <1392188330-17208-2-git-send-email-dingtianhong@huawei.com>
References: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58107 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaBLG7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 01:59:18 -0500
In-Reply-To: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev_set_mac_address() will check the dev->netdev_ops->ndo_set_mac_address,
so no need to check it in bond_set_mac_address().

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 71ba18e..58aa531 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3461,15 +3461,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	 */
 
 	bond_for_each_slave(bond, slave, iter) {
-		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
 		pr_debug("slave %p %s\n", slave, slave->dev->name);
-
-		if (slave_ops->ndo_set_mac_address == NULL) {
-			res = -EOPNOTSUPP;
-			pr_debug("EOPNOTSUPP %s\n", slave->dev->name);
-			goto unwind;
-		}
-
 		res = dev_set_mac_address(slave->dev, addr);
 		if (res) {
 			/* TODO: consider downing the slave
-- 
1.8.0
