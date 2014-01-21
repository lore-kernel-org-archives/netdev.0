From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/5] bonding: don't set fail_over_mac if the mode
 is not active backup
Date: Tue, 21 Jan 2014 17:44:06 +0800
Message-ID: <52DE4166.9030208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58813 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbaAUJoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:44:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fail_over_mac could be set by sysfs in every mode now, it will
cause bonding not to set all slaves to the same MAC address, but in
rr, xor, broadcast, lacp mode ,the slaves should have the same MAC
address with the master, so don't set the fail_over_mac by sysfs
if the mode is not active-backup.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..0996ab4 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -550,6 +550,12 @@ int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
 
 int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
 {
+	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+		pr_err("%s: fail_over_mac only affects active-backup mode\n",
+		       bond->dev->name);
+		return -EINVAL;
+	}
+
 	if (bond_parm_tbl_lookup(fail_over_mac, fail_over_mac_tbl) < 0) {
 		pr_err("%s: Ignoring invalid fail_over_mac value %d.\n",
 		       bond->dev->name, fail_over_mac);
-- 
1.8.0
