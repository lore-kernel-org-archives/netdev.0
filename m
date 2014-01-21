From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/5] bonding: set fail_over_mac to none if new mode
 is not active-backup
Date: Tue, 21 Jan 2014 17:44:11 +0800
Message-ID: <52DE416B.4040607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52375 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaAUJoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fail_over_mac only affects active backup mode, if it is set to active
or follow, the bonding could not set all slaves to the same MAC address
for other modes, just like RR, XOR, 802.3ad or BROADCAST, so when changing
bond to new mode and the new mode is not active-backup, we should check
the fail_over_mac and set it to 0.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 0996ab4..74d12ba 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -50,6 +50,12 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 			bond->dev->name, bond->params.miimon);
 	}
 
+	if (mode != BOND_MODE_ACTIVEBACKUP && bond->params.fail_over_mac) {
+		pr_info("%s: fail_over_mac only affects active-backup mode, so set it to 0\n",
+			bond->dev->name);
+		bond->params.fail_over_mac = BOND_FOM_NONE;
+	}
+
 	/* don't cache arp_validate between modes */
 	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
 	bond->params.mode = mode;
-- 
1.8.0
