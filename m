From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net] bonding: use return instead of goto
Date: Wed,  3 Feb 2016 06:15:22 +0000
Message-ID: <1454480122-32501-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: j.vosburgh@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8338 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755897AbcBCGOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 01:14:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace 'goto' with 'return' to remove unnecessary check at label:
err_undo_flags.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bcc7b19..abe014f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1379,8 +1379,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (slave_dev->flags & IFF_UP) {
 		netdev_err(bond_dev, "%s is up - this may be due to an out of date ifenslave\n",
 			   slave_dev->name);
-		res = -EPERM;
-		goto err_undo_flags;
+		return -EPERM;
 	}
 
 	/* set bonding device ether type by slave - bonding netdevices are
@@ -1400,8 +1399,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			res = notifier_to_errno(res);
 			if (res) {
 				netdev_err(bond_dev, "refused to change device type\n");
-				res = -EBUSY;
-				goto err_undo_flags;
+				return -EBUSY;
 			}
 
 			/* Flush unicast and multicast addresses */
@@ -1421,8 +1419,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	} else if (bond_dev->type != slave_dev->type) {
 		netdev_err(bond_dev, "%s ether type (%d) is different from other slaves (%d), can not enslave it\n",
 			   slave_dev->name, slave_dev->type, bond_dev->type);
-		res = -EINVAL;
-		goto err_undo_flags;
+		return -EINVAL;
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
-- 
1.8.3.1
