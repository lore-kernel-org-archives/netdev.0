From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bonding: remove no longer relevant vlan warnings
Date: Wed,  2 Jul 2014 11:55:38 +0200
Message-ID: <1404294938-9968-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, teg@jklm.no, jay.vosburgh@canonical.com,
	mkubecek@suse.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:38455 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaGBJzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 05:55:45 -0400
Received: by mail-we0-f176.google.com with SMTP id u56so11021668wes.7
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 02:55:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These warnings are no longer relevant. Even when last slave is
removed, there is a valid address assigned to bond (random).
The correct functionality of vlans is ensured by maintaining unicast
list in vlan_sync_address().

Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ffefb70..09dc3ef 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1754,13 +1754,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (!bond_has_slaves(bond)) {
 		bond_set_carrier(bond);
 		eth_hw_addr_random(bond_dev);
-
-		if (vlan_uses_dev(bond_dev)) {
-			pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
-				bond_dev->name, bond_dev->name);
-			pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
-				bond_dev->name);
-		}
 	}
 
 	unblock_netpoll_tx();
-- 
1.9.0
