From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/4] bonding: do not save non-existent device to
 bond primary in sysfs
Date: Thu, 9 Jan 2014 19:20:54 +0800
Message-ID: <52CE8616.2010902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:46656 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaAILVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 06:21:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not save non-existent device to bond primary in sysfs.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..9b4518f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -501,6 +501,12 @@ int bond_option_primary_set(struct bonding *bond, const char *primary)
 		goto out;
 	}
 
+	if (!__dev_get_by_name(dev_net(bond->dev), primary)) {
+		pr_err("%s: unable to set non-existent device %s to primary.\n",
+		       bond->dev->name, primary);
+		goto out;
+	}
+
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
 			pr_info("%s: Setting %s as primary slave.\n",
-- 
1.8.0
