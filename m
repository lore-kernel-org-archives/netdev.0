From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 08/12] bonding: use last_arp_rx in slave_last_rx()
Date: Fri, 17 Jan 2014 17:58:56 +0100
Message-ID: <1389977940-17084-9-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbaAQREX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:23 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that last_arp_rx really has the last time we've received any (validated or
not) ARP, we can use it in slave_last_rx() instead of slave->dev->last_rx.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1fbbf04..d0964c0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -355,14 +355,10 @@ static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
 static inline unsigned long slave_last_rx(struct bonding *bond,
 					struct slave *slave)
 {
-	if (slave_do_arp_validate(bond, slave)) {
-		if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
-			return slave_oldest_target_arp_rx(bond, slave);
-		else
-			return slave->last_arp_rx;
-	}
-
-	return slave->dev->last_rx;
+	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
+		return slave_oldest_target_arp_rx(bond, slave);
+
+	return slave->last_arp_rx;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.8.4
