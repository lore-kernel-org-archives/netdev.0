From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] bond: check if slave count is 0 in case when deciding to take slave's mac
Date: Tue, 26 Feb 2013 09:26:15 +0100
Message-ID: <1361867175-4033-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	gregory.v.rose@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:47901 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab3BZI0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 03:26:21 -0500
Received: by mail-wg0-f43.google.com with SMTP id e12so3205867wge.10
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 00:26:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in bond_enslave(), check slave_cnt before actually using slave address.

introduced by:
commit 409cc1f8a41 (bond: have random dev address by default instead of zeroes)

Reported-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11d01d6..7bd068a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1629,7 +1629,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (bond->dev_addr_from_first)
+	if (bond->slave_cnt == 0 && bond->dev_addr_from_first)
 		bond_set_dev_addr(bond->dev, slave_dev);
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
-- 
1.8.1.2
