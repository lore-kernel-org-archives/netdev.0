From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 4/6] bonding: rename slave_last_rx() to slave_last_arp_rx()
Date: Thu, 16 Jan 2014 03:05:14 +0100
Message-ID: <1389837916-5377-5-git-send-email-vfalico@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbaAPCJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 21:09:39 -0500
In-Reply-To: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make the code more readable.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 drivers/net/bonding/bonding.h   | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1e0f21a..399e691 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2347,7 +2347,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	if (bond_is_active_slave(slave))
 		bond_validate_arp(bond, slave, sip, tip);
 	else if (bond->curr_active_slave &&
-		 time_after(slave_last_rx(bond, bond->curr_active_slave),
+		 time_after(slave_last_arp_rx(bond, bond->curr_active_slave),
 			    bond->curr_active_slave->jiffies))
 		bond_validate_arp(bond, slave, tip, sip);
 
@@ -2504,7 +2504,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
-		last_rx = slave_last_rx(bond, slave);
+		last_rx = slave_last_arp_rx(bond, slave);
 
 		if (slave->link != BOND_LINK_UP) {
 			if (bond_time_in_interval(bond, last_rx, 1)) {
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1af8c1f..99126b2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -341,8 +341,8 @@ static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
 	return ret;
 }
 
-static inline unsigned long slave_last_rx(struct bonding *bond,
-					struct slave *slave)
+static inline unsigned long slave_last_arp_rx(struct bonding *bond,
+					      struct slave *slave)
 {
 	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
 		return slave_oldest_target_arp_rx(bond, slave);
-- 
1.8.4
