From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 2/3] bonding: ust micro BOND_NO_USE_ARP to simplify
 the mode check
Date: Sat, 21 Dec 2013 14:40:17 +0800
Message-ID: <52B537D1.1060604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19936 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3LUGrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 01:47:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond 3ad and TLB/ALB has the same check path, so combine them.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 368f7e4..695f8a4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4071,8 +4071,8 @@ static int bond_check_params(struct bond_params *params)
 		num_peer_notif = 1;
 	}
 
-	/* reset values for 802.3ad */
-	if (bond_mode == BOND_MODE_8023AD) {
+	/* reset values for 802.3ad/TLB/ALB */
+	if (BOND_NO_USES_ARP(bond_mode)) {
 		if (!miimon) {
 			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
 			pr_warning("Forcing miimon to 100msec\n");
@@ -4107,16 +4107,6 @@ static int bond_check_params(struct bond_params *params)
 		packets_per_slave = 1;
 	}
 
-	/* reset values for TLB/ALB */
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
-		if (!miimon) {
-			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure and link speed which are essential for TLB/ALB load balancing\n");
-			pr_warning("Forcing miimon to 100msec\n");
-			miimon = BOND_DEFAULT_MIIMON;
-		}
-	}
-
 	if (bond_mode == BOND_MODE_ALB) {
 		pr_notice("In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (%d msec) is incompatible with the forwarding delay time of the switch\n",
 			  updelay);
-- 
1.8.0
