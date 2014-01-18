From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 1/2] bonding: clean the primary slave if there
 is no slave matching new primary
Date: Sat, 18 Jan 2014 16:28:52 +0800
Message-ID: <52DA3B44.1000605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:49560 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbaARI3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 03:29:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the new primay is not matching any slave in the bond, the bond should
record it to params, clean the primary slave and select a new active slave.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..0ee0bfe 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -512,6 +512,12 @@ int bond_option_primary_set(struct bonding *bond, const char *primary)
 		}
 	}
 
+	if (bond->primary_slave) {
+		pr_info("%s: Setting primary slave to None.\n",
+			bond->dev->name);
+		bond->primary_slave = NULL;
+		bond_select_active_slave(bond);
+	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
-- 
1.8.0
