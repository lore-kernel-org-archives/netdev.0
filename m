From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: remove unwanted bond lock for enslave processing
Date: Mon, 10 Feb 2014 16:33:59 +0800
Message-ID: <52F88EF7.606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:8638 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbaBJIe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 03:34:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond enslave processing don't hold bond->lock anymore,
so release an unlocked rw lock will cause warning message,
remove the unwanted read_unlock(&bond->lock).

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a7db819..ccfb998 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1505,7 +1505,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	slave_dev->npinfo = bond->dev->npinfo;
 	if (slave_dev->npinfo) {
 		if (slave_enable_netpoll(new_slave)) {
-			read_unlock(&bond->lock);
 			pr_info("Error, %s: master_dev is using netpoll, "
 				 "but new slave device does not support netpoll.\n",
 				 bond_dev->name);
-- 
1.8.0
