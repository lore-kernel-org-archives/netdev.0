From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 2/4] bonding: replace %x with %pI4 for IPv4 addresses
Date: Wed, 15 May 2013 14:32:40 +0200
Message-ID: <1368621162-6807-3-git-send-email-nikolay@redhat.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab3EOMkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 08:40:49 -0400
In-Reply-To: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There're few pr_debug() places that can provide the IPv4 address in
dotted decimal format instead which is more helpful.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d0aade0..1a0cc13 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2555,8 +2555,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
-		 slave_dev->name, dest_ip, src_ip, vlan_id);
+	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 vid %d\n", arp_op,
+		 slave_dev->name, &dest_ip, &src_ip, vlan_id);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
@@ -2588,7 +2588,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		__be32 addr;
 		if (!targets[i])
 			break;
-		pr_debug("basa: target %x\n", targets[i]);
+		pr_debug("basa: target %pI4\n", &targets[i]);
 		if (!bond_vlan_used(bond)) {
 			pr_debug("basa: empty vlan: arp_send\n");
 			addr = bond_confirm_addr(bond->dev, targets[i], 0);
-- 
1.8.1.4
