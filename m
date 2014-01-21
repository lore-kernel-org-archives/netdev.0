From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/5] bonding: set fail_over_mac to active only in
 active-backup mode at enslavement
Date: Tue, 21 Jan 2014 17:44:17 +0800
Message-ID: <52DE4171.2060707@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52426 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbaAUJon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fail_over_mac only affect active-backup mode, if the first slave
does not support setting the MAC address, we should set fail_over_mac
to active only in active-backup mode, otherwise the bonding could not set
all slaves to the master's address for other modes.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ecff04e..a318a78 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1336,7 +1336,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		if (!bond_has_slaves(bond)) {
 			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
 				   bond_dev->name);
-			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
 			       bond_dev->name);
-- 
1.8.0
