From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 2/3] bonding: simplify the slave_do_arp_validate_only()
Date: Wed, 7 May 2014 22:02:38 +0800
Message-ID: <1399471359-5120-3-git-send-email-dingtianhong@huawei.com>
References: <1399471359-5120-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17913 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaEGODT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 10:03:19 -0400
In-Reply-To: <1399471359-5120-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The argument slave is not used for slave_do_arp_validate_only(), so no need
to keep it, make the function more simple.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 drivers/net/bonding/bonding.h   | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69aff72..ff73c14 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2291,8 +2291,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
 
 	if (!slave_do_arp_validate(bond, slave)) {
-		if ((slave_do_arp_validate_only(bond, slave) && is_arp) ||
-		    !slave_do_arp_validate_only(bond, slave))
+		if ((slave_do_arp_validate_only(bond) && is_arp) ||
+		    !slave_do_arp_validate_only(bond))
 			slave->last_rx = jiffies;
 		return RX_HANDLER_ANOTHER;
 	} else if (!is_arp) {
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9f23bf3..5d1e1a8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -395,8 +395,7 @@ static inline int slave_do_arp_validate(struct bonding *bond,
 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
 }
 
-static inline int slave_do_arp_validate_only(struct bonding *bond,
-					     struct slave *slave)
+static inline int slave_do_arp_validate_only(struct bonding *bond)
 {
 	return bond->params.arp_validate & BOND_ARP_FILTER;
 }
-- 
1.8.0
