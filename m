From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/5] bonding: replace read_lock to rcu_read_lock for bond_3ad_get_active_agg_info()
Date: Wed, 28 Aug 2013 12:20:56 +0800
Message-ID: <521D7AA8.7070607@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:5144 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab3H1EVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 00:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list will protected by rcu, so it is no need to use read lock,
which should replace by rcu read lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 52d76a4..70727ec 100644
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
