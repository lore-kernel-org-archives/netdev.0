From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bonding: fix error return code in bond_enslave()
Date: Fri, 23 Aug 2013 10:45:07 +0800
Message-ID: <CAPgLHd96k-qncCXzzVogwtmMdaYUDsMShdX52YSLAdbTiN1uEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:37723 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab3HWCpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 22:45:09 -0400
Received: by mail-bk0-f49.google.com with SMTP id r7so27384bkg.36
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 19:45:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code in the add bond vlan ids error
handling case instead of 0, as done elsewhere in this function.

Introduced by commit 1ff412ad7714f6952f76ffd77f0a7f2f563288a1.
(bonding: change the bond's vlan syncing functions with the standard ones)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4264a76..7407e65 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1603,7 +1603,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		dev_mc_add(slave_dev, lacpdu_multicast);
 	}
 
-	if (vlan_vids_add_by_dev(slave_dev, bond_dev)) {
+	res = vlan_vids_add_by_dev(slave_dev, bond_dev);
+	if (res) {
 		pr_err("%s: Error: Couldn't add bond vlan ids to %s\n",
 		       bond_dev->name, slave_dev->name);
 		goto err_close;
