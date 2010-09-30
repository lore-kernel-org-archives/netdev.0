From: Krzysztof Piotr Oledzki <ole@ans.pl>
Subject: [net-next-2.6 PATCH 3/3] bonding: reread information about speed
 and duplex when interface goes up
Date: Thu, 30 Sep 2010 18:19:10 +0200
Message-ID: <4ca4b87e.NzbQ35P2qRrA2iuz%ole@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:52191 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737Ab0I3QTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 12:19:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 43285224a785e90c7d4cff2be0766ca8df6ddfb9 Mon Sep 17 00:00:00 2001
From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 17:09:02 +0200
Subject: bonding: reread information about speed and duplex when interface goes up

When an interface was enslaved when it was down, bonding thinks
it has speed -1 even after it goes up. This leads into selecting
a wrong active interface in active/backup mode on mixed 10G/1G or
1G/100M environment.

before:
 bonding: bond0: link status definitely up for interface eth5, 100 Mbps full duplex.
 bonding: bond0: link status definitely up for interface eth0, 100 Mbps full duplex.

after:
 bonding: bond0: link status definitely up for interface eth5, 10000 Mbps full duplex.
 bonding: bond0: link status definitely up for interface eth0, 1000 Mbps full duplex.

Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

---
 drivers/net/bonding/bond_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 721abc4..e409c14 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2368,6 +2368,8 @@ static void bond_miimon_commit(struct bonding *bond)
 				slave->state = BOND_STATE_BACKUP;
 			}
 
+			bond_update_speed_duplex(slave);
+
 			pr_info("%s: link status definitely up for interface %s, %d Mbps %s duplex.\n",
 				bond->dev->name, slave->dev->name,
 				slave->speed, slave->duplex ? "full" : "half");
-- 
1.7.1

