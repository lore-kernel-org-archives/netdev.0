From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] bond: output message before setting slave to inactive
Date: Tue, 29 Mar 2016 06:32:57 +0000
Message-ID: <1459233177-6394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9826 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbcC2GVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 02:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves output message before setting slave to inactive, this will
print the correct status of slave device.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99..97fad05 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1830,6 +1830,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 		return -EINVAL;
 	}
 
+	netdev_info(bond_dev, "Releasing %s interface %s\n",
+		    bond_is_active_slave(slave) ? "active" : "backup",
+		    slave_dev->name);
+
 	bond_set_slave_inactive_flags(slave, BOND_SLAVE_NOTIFY_NOW);
 
 	bond_sysfs_slave_del(slave);
@@ -1849,10 +1853,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (bond_mode_uses_xmit_hash(bond))
 		bond_update_slave_arr(bond, slave);
 
-	netdev_info(bond_dev, "Releasing %s interface %s\n",
-		    bond_is_active_slave(slave) ? "active" : "backup",
-		    slave_dev->name);
-
 	oldcurrent = rcu_access_pointer(bond->curr_active_slave);
 
 	RCU_INIT_POINTER(bond->current_arp_slave, NULL);
-- 
1.8.3.1
