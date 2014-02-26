From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] bonding: disallow enslaving a bond to itself
Date: Wed, 26 Feb 2014 18:20:13 +0100
Message-ID: <20140226172013.GA18145@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48752 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbaBZRUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 12:20:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enslaving a bond to itself leads to an endless loop and hangs the kernel.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1c6104d..8f028ac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1193,6 +1193,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		return -EBUSY;
 	}
 
+	if (bond_dev == slave_dev) {
+		pr_err("%s: cannot enslave bond to itself.\n", bond_dev->name);
+		return -EPERM;
+	}
+
 	/* vlan challenged mutual exclusion */
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
