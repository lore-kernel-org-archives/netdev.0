From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net] bonding: don't permit to use ARP monitoring in 802.3ad mode
Date: Tue, 12 Nov 2013 15:37:40 +0100
Message-ID: <1384267060-10851-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010Ab3KLOhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 09:37:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the ARP monitoring is not supported with 802.3ad, and it's
prohibited to use it via the module params.

However we still can set it afterwards via sysfs, cause we only check for
*LB modes there.

To fix this - add a check for 802.3ad mode in bonding_store_arp_interval.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c29b836..e386d6b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -587,8 +587,9 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		goto out;
 	}
 	if (bond->params.mode == BOND_MODE_ALB ||
-	    bond->params.mode == BOND_MODE_TLB) {
-		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
+	    bond->params.mode == BOND_MODE_TLB ||
+	    bond->params.mode == BOND_MODE_8023AD) {
+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
 			bond->dev->name, bond->dev->name);
 		ret = -EINVAL;
 		goto out;
-- 
1.8.4
