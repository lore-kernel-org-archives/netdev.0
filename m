From: Krzysztof Piotr Oledzki <ole@ans.pl>
Subject: [net-next-2.6 PATCH 1/3] bonding: print information about speed
 and duplex seen by the driver
Date: Thu, 30 Sep 2010 18:18:59 +0200
Message-ID: <4ca4b873.iZ0Dea7Y1OFcVmf8%ole@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:52183 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737Ab0I3QTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 12:19:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d4fb10933bb88f2bf410b0abe42f151c13e3df85 Mon Sep 17 00:00:00 2001
From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 17:05:19 +0200
Subject: bonding: print information about speed and duplex seen by the driver

before:
 bonding: bond0: link status definitely up for interface eth5
 bonding: bond0: link status definitely up for interface eth0

after:
 bonding: bond0: link status definitely up for interface eth5, 100 Mbps full duplex.
 bonding: bond0: link status definitely up for interface eth0, 100 Mbps full duplex.


Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

---
 drivers/net/bonding/bond_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fb70c3e..721abc4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2368,8 +2368,9 @@ static void bond_miimon_commit(struct bonding *bond)
 				slave->state = BOND_STATE_BACKUP;
 			}
 
-			pr_info("%s: link status definitely up for interface %s.\n",
-				bond->dev->name, slave->dev->name);
+			pr_info("%s: link status definitely up for interface %s, %d Mbps %s duplex.\n",
+				bond->dev->name, slave->dev->name,
+				slave->speed, slave->duplex ? "full" : "half");
 
 			/* notify ad that the link status has changed */
 			if (bond->params.mode == BOND_MODE_8023AD)
-- 
1.7.1

