From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 5/7] bonding: remove unwanted return value for bond_dev_queue_xmit()
Date: Tue, 31 Dec 2013 17:47:31 +0800
Message-ID: <52C292B3.7080702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:22605 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab3LaJrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 04:47:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value for bond_dev_queue_xmit() will not be used anymore,
so remove the return value.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 4 +---
 drivers/net/bonding/bonding.h   | 2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f14e235..e4d5018 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -299,7 +299,7 @@ const char *bond_mode_name(int mode)
  * @skb: hw accel VLAN tagged skb to transmit
  * @slave_dev: slave that is supposed to xmit this skbuff
  */
-int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
+void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 			struct net_device *slave_dev)
 {
 	skb->dev = slave_dev;
@@ -312,8 +312,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
 	else
 		dev_queue_xmit(skb);
-
-	return 0;
 }
 
 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5886f07..0f3e270 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -416,7 +416,7 @@ static inline bool slave_can_tx(struct slave *slave)
 struct bond_net;
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
-int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
-- 
1.8.0
