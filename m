From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] bond: set mac address only if necessary
Date: Tue, 29 Mar 2016 15:14:17 +0000
Message-ID: <1459264457-19000-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8836 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757275AbcC2PCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 11:02:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bond device gets it's mac address from the first slave device, it's not
necessary to set slave device's mac address to bond if equal.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 97fad05..6569219 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1473,8 +1473,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
 
-	if (!bond->params.fail_over_mac ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	if ((!bond->params.fail_over_mac ||
+	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) &&
+	    !ether_addr_equal_64bits(bond_dev->dev_addr, slave_dev->dev_addr)) {
 		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
-- 
1.8.3.1
