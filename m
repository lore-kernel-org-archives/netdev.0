From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 3/6] bonding: replace read_lock to rcu_read_lock
 for bond_3ad_get_active_agg_info()
Date: Wed, 25 Sep 2013 17:52:22 +0800
Message-ID: <5242B256.7080300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27145 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071Ab3IYJx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 05:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the bond slave list will protected by rcu, so the read lock should replace by
rcu read lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c134f43..b678502 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2408,9 +2408,9 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 {
 	int ret;
 
-	read_lock(&bond->lock);
+	rcu_read_lock();
 	ret = __bond_3ad_get_active_agg_info(bond, ad_info);
-	read_unlock(&bond->lock);
+	rcu_read_unlock();
 
 	return ret;
 }
-- 
1.8.2.1
