From: nikolay@redhat.com
Subject: [PATCH net-next] bonding: allow xmit hash policy change while bond dev is up
Date: Fri, 24 May 2013 12:59:47 +0200
Message-ID: <1369393187-23163-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406Ab3EXLDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 07:03:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

Since the xmit_hash_policy pointer is always valid and not dependent on
anything, we can change it while the bond device is up and running. The
only downside would be the out of order packets but that is a small price
to pay.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ea7a388..362a04b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -379,20 +379,12 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Interface is up. Unable to update xmit policy.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid xmit hash policy value %.*s.\n",
 		       bond->dev->name,
 		       (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
-		goto out;
 	} else {
 		bond->params.xmit_policy = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
@@ -400,7 +392,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 			bond->dev->name,
 			xmit_hashtype_tbl[new_value].modename, new_value);
 	}
-out:
+
 	return ret;
 }
 static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
-- 
1.8.1.4
