From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: set primary_reselect in LB and AB mode
Date: Fri, 15 Nov 2013 18:02:24 +0800
Message-ID: <5285F130.5060705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:23727 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049Ab3KOKFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 05:05:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The primary_reselect only reselection for the primary slave,
but the primary slave only support for ALB, TLB and AB mode,
so we sould set the primary_reselect for these mode.

to fix this: Add a check for ALB, TLB and AB mode in
bonding_store_primary_reselect, avoid to select active slave
again in other modes.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..cac2291 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1141,6 +1141,13 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
+	if (!USES_PRIMARY(bond->params.mode)) {
+		pr_info("%s: Unable to set primary reselect; %s is in mode %d\n",
+			bond->dev->name, bond->dev->name, bond->params.mode);
+		ret = -EINVAL;
+		goto out;
+	}
+
 	new_value = bond_parse_parm(buf, pri_reselect_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
-- 
1.7.12
