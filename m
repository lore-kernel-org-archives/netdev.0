From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] bonding: slight optimization for bond_xmit_roundrobin()
Date: Fri, 19 Sep 2014 21:04:57 +0800
Message-ID: <541C29F9.6020001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:35170 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513AbaISNFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 09:05:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the slave is the curr_active_slave, no need to check
whether the slave is active or not, it is always active.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b43b2df..0324603 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3624,7 +3624,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 */
 	if (iph->protocol == IPPROTO_IGMP && skb->protocol == htons(ETH_P_IP)) {
 		slave = rcu_dereference(bond->curr_active_slave);
-		if (slave && bond_slave_can_tx(slave))
+		if (slave)
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 		else
 			bond_xmit_slave_id(bond, skb, 0);
-- 
1.7.12
