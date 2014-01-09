From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Thu, 9 Jan 2014 19:20:36 +0800
Message-ID: <52CE8604.3010804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27310 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaAILVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 06:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the primary_slave's name changed, but the bond->prams.primay was
still using the old name, it is conflict with the meaning of the
primary, so update the primary when the slave change its name.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..de646e2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2860,9 +2860,19 @@ static int bond_slave_netdev_event(unsigned long event,
 		 */
 		break;
 	case NETDEV_CHANGENAME:
-		/*
-		 * TODO: handle changing the primary's name
+		/* if the primary's name changed,
+		 * save the new name for primary.
 		 */
+		if (USES_PRIMARY(bond->params.mode) &&
+		    bond->params.primary[0]) {
+			if (bond->primary_slave &&
+			    strcmp(bond->params.primary,
+				   bond->primary_slave->dev->name)) {
+				strncpy(bond->params.primary,
+					bond->primary_slave->dev->name,
+					IFNAMSIZ);
+			}
+		}
 		break;
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
-- 
1.8.0
