From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 2/6] bonding: remove the no effect lock for bond_3ad_lacpdu_recv()
Date: Wed, 25 Sep 2013 17:52:19 +0800
Message-ID: <5242B253.2070002@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:27139 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab3IYJx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 05:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no pointer needed read lock protection, remove the unnecessary lock
and improve performance for the 3ad recv path.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7a3860f..c134f43 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2494,9 +2494,7 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 	if (!lacpdu)
 		return ret;
 
-	read_lock(&bond->lock);
 	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
-	read_unlock(&bond->lock);
 	return ret;
 }
 
-- 
1.8.2.1
