From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 08/12] bonding: use last_arp_rx in slave_last_rx()
Date: Tue, 18 Feb 2014 07:48:43 +0100
Message-ID: <1392706127-28390-9-git-send-email-vfalico@redhat.com>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbaBRGxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 01:53:16 -0500
In-Reply-To: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that last_arp_rx really has the last time we've received any (validated or
not) ARP, we can use it in slave_last_rx() instead of slave->dev->last_rx.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ab2e651..ae20c5a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -379,14 +379,10 @@ static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
 static inline unsigned long slave_last_rx(struct bonding *bond,
 					struct slave *slave)
 {
-	if (slave_do_arp_validate(bond, slave)) {
-		if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
-			return slave_oldest_target_arp_rx(bond, slave);
-		else
-			return slave->last_arp_rx;
-	}
+	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
+		return slave_oldest_target_arp_rx(bond, slave);
 
-	return slave->dev->last_rx;
+	return slave->last_arp_rx;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.8.4
