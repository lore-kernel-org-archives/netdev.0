From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] bonding: change error message to debug message in __bond_release_one()
Date: Tue, 23 Dec 2014 09:24:36 +0800
Message-ID: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33487 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbaLWBXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 20:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __bond_release_one(), when the interface is not a slave or not a slave of
"this" master, it log error message.

The message actually should be a debug message matching what bond_enslave()
does.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 184c434..0dceba1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1648,7 +1648,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    !netdev_has_upper_dev(slave_dev, bond_dev)) {
-		netdev_err(bond_dev, "cannot release %s\n",
+		netdev_dbg(bond_dev, "cannot release %s\n",
 			   slave_dev->name);
 		return -EINVAL;
 	}
-- 
1.8.3.1
