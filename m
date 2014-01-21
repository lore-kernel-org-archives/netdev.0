From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 5/5] bonding: remove the redundant judgements for
 bond_set_mac_address()
Date: Tue, 21 Jan 2014 17:44:23 +0800
Message-ID: <52DE4177.8050402@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:59188 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbaAUJoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev_set_mac_address() will check the dev->netdev_ops->ndo_set_mac_address,
so no need to check it in bond_set_mac_address().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a318a78..638e1d5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3500,15 +3500,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
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
