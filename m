From: Flavio Leitner <fbl@redhat.com>
Subject: [net-next] bonding: don't allow the master to become its slave
Date: Thu,  9 Aug 2012 15:30:49 -0300
Message-ID: <1344537049-11473-1-git-send-email-fbl@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981Ab2HISbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 14:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't make any sense to allow the master to become
its slave. That creates a loop of events causing a crash.

Reported-by: Leonardo Chiquitto <lchiquitto@suse.com>
Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6fae5f3..5407b44 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1505,6 +1505,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	int link_reporting;
 	int res = 0;
 
+	if (bond_dev == slave_dev) {
+		pr_err("%s: Error: cannot enslave itself.\n", bond_dev->name);
+		return -EINVAL;
+	}
+
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
 		slave_ops->ndo_do_ioctl == NULL) {
 		pr_warning("%s: Warning: no link monitoring support for %s\n",
-- 
1.7.11.2
