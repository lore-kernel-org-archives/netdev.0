From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 10/12] bonding: remove useless updating of slave->dev->last_rx
Date: Tue, 18 Feb 2014 07:48:45 +0100
Message-ID: <1392706127-28390-11-git-send-email-vfalico@redhat.com>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbaBRGxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 01:53:20 -0500
In-Reply-To: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all the logic is handled via last_arp_rx, we don't need to use
last_rx.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 3 ---
 include/linux/netdevice.h       | 8 +-------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e7aab9a..14e023d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1115,9 +1115,6 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	slave = bond_slave_get_rcu(skb->dev);
 	bond = slave->bond;
 
-	if (bond->params.arp_interval)
-		slave->dev->last_rx = jiffies;
-
 	recv_probe = ACCESS_ONCE(bond->recv_probe);
 	if (recv_probe) {
 		ret = recv_probe(skb, bond, slave);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 430c51a..891432a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1312,13 +1312,7 @@ struct net_device {
 /*
  * Cache lines mostly used on receive path (including eth_type_trans())
  */
-	unsigned long		last_rx;	/* Time of last Rx
-						 * This should not be set in
-						 * drivers, unless really needed,
-						 * because network stack (bonding)
-						 * use it if/when necessary, to
-						 * avoid dirtying this cache line.
-						 */
+	unsigned long		last_rx;	/* Time of last Rx */
 
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
-- 
1.8.4
