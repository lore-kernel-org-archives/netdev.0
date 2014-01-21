From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/5] bonding: The fail_over_mac should be set only
 in ACTIVE_BACKUP mode
Date: Tue, 21 Jan 2014 17:44:01 +0800
Message-ID: <52DE4161.3050801@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52101 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaAUJoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According the bonding.txt, the option fail_over_mac only affect for
AB mode, but in currect code, the parameter could be set to active
or follow in every mode, this will cause bonding could not set all
slaves of an RR or XOR mode to the same MAC address at enslavement
time, so reset fail_over_mac to 0 if the mode is not ACTIVE_BACKUP.

Fix the wrong variables for pr_err().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3220b48..ecff04e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4307,12 +4307,14 @@ static int bond_check_params(struct bond_params *params)
 						      fail_over_mac_tbl);
 		if (fail_over_mac_value == -1) {
 			pr_err("Error: invalid fail_over_mac \"%s\"\n",
-			       arp_validate == NULL ? "NULL" : arp_validate);
+			       fail_over_mac == NULL ? "NULL" : fail_over_mac);
 			return -EINVAL;
 		}
 
-		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
-			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
+		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
+			pr_warning("Warning: fail_over_mac only affects active-backup mode, set it to 0.\n");
+			fail_over_mac_value = BOND_FOM_NONE;
+		}
 	} else {
 		fail_over_mac_value = BOND_FOM_NONE;
 	}
-- 
1.8.0
