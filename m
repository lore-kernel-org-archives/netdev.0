From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/4] bonding: don't ensalve loopback device
Date: Fri, 21 Feb 2014 16:08:55 +0800
Message-ID: <1392970135-11904-5-git-send-email-dingtianhong@huawei.com>
References: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36140 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbaBUIJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:09:39 -0500
In-Reply-To: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I could not see any effect that enslave a loopback device, so don't
enslave such device for bonding.

Use pr_err to instead of pr_debug when return error.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4fa8ea7..b75c815 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1176,9 +1176,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			bond_dev->name, slave_dev->name);
 	}
 
+	if (slave_dev->flags & IFF_LOOPBACK) {
+		pr_err("Error: cannot enslave loopback device\n");
+		return -EINVAL;
+	}
+
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
-		pr_debug("Error: Device was already enslaved\n");
+		pr_err("Error: Device was already enslaved\n");
 		return -EBUSY;
 	}
 
-- 
1.8.0
