From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/4] bonding: remove no longer needed lock for bond_xxx_info_query()
Date: Fri, 21 Feb 2014 16:08:54 +0800
Message-ID: <1392970135-11904-4-git-send-email-dingtianhong@huawei.com>
References: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:55228 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbaBUIJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:09:28 -0500
In-Reply-To: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_xxx_info_query() was already in RTNL, so no need to use
bond lock to protect the bond slave list, so remove it.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index affe0c4..4fa8ea7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1816,9 +1816,7 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
 
-	read_lock(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
-	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -1830,7 +1828,6 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 	int i = 0, res = -ENODEV;
 	struct slave *slave;
 
-	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
 		if (i++ == (int)info->slave_id) {
 			res = 0;
@@ -1841,7 +1838,6 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 			break;
 		}
 	}
-	read_unlock(&bond->lock);
 
 	return res;
 }
-- 
1.8.0
