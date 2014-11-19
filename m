From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Wed, 19 Nov 2014 13:18:12 +0800
Message-ID: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com
To: wwgwork@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24627 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaKSFQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 00:16:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When last slave of a bonding master is removed, the bonding then does not work.
When packet_snd is called against with a master net_device, it accesses
header_ops. In case the header_ops is not valid any longer(say ipoib module
unloaded), it will then access an invalid memory address.
This patch try to fix this issue by clearing header_ops when last slave
detached.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c9ac06c..52a7e4b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1730,6 +1730,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	bond->slave_cnt--;
 
 	if (!bond_has_slaves(bond)) {
+		bond->dev->header_ops = NULL;
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
 		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
 	}
-- 
1.8.3.1
