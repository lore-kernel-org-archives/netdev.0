From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/4] bonding: netpoll: remove unwanted slave_dev_support_netpoll()
Date: Fri, 21 Feb 2014 16:08:52 +0800
Message-ID: <1392970135-11904-2-git-send-email-dingtianhong@huawei.com>
References: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32159 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbaBUIJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:09:22 -0500
In-Reply-To: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __netpoll_setup() will check the slave's flag and ndo_poll_controller just
like the slave_dev_support_netpoll() does, and slave_dev_support_netpoll() was
not used by any place, so remove it.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 71edf03..affe0c4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -942,14 +942,6 @@ static inline void slave_disable_netpoll(struct slave *slave)
 	slave->np = NULL;
 	__netpoll_free_async(np);
 }
-static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
-{
-	if (slave_dev->priv_flags & IFF_DISABLE_NETPOLL)
-		return false;
-	if (!slave_dev->netdev_ops->ndo_poll_controller)
-		return false;
-	return true;
-}
 
 static void bond_poll_controller(struct net_device *bond_dev)
 {
-- 
1.8.0
