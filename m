From: alex.bluesman.smirnov@gmail.com
Subject: [PATCH] rtnetlink: rtnl_link_register always returns zero
Date: Wed, 14 Dec 2011 00:31:21 +0400
Message-ID: <1323808281-9967-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55121 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab1LMUbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 15:31:44 -0500
Received: by eekc4 with SMTP id c4so72931eek.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 12:31:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alexander@Lenovo.(none)>

Both functions 'rtnl_link_register' and '__rtnl_link_register' always
return zero. So handling return status has no sense in several drivers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/net/bonding/bond_main.c |    6 +-----
 drivers/net/can/dev.c           |    8 +-------
 drivers/net/tun.c               |    8 ++------
 3 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 25a44d9..f79bb97 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4921,9 +4921,7 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	res = rtnl_link_register(&bond_link_ops);
-	if (res)
-		goto err_link;
+	rtnl_link_register(&bond_link_ops);
 
 	bond_create_debugfs();
 
@@ -4939,10 +4937,8 @@ out:
 	return res;
 err:
 	rtnl_link_unregister(&bond_link_ops);
-err_link:
 	unregister_pernet_subsys(&bond_net_ops);
 	goto out;
-
 }
 
 static void __exit bonding_exit(void)
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 120f1ab..e5b5daf 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -756,13 +756,7 @@ EXPORT_SYMBOL_GPL(unregister_candev);
 
 static __init int can_dev_init(void)
 {
-	int err;
-
-	err = rtnl_link_register(&can_link_ops);
-	if (!err)
-		printk(KERN_INFO MOD_DESC "\n");
-
-	return err;
+	return rtnl_link_register(&can_link_ops);
 }
 module_init(can_dev_init);
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 93c5d72..bb034b1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1632,16 +1632,12 @@ static const struct ethtool_ops tun_ethtool_ops = {
 
 static int __init tun_init(void)
 {
-	int ret = 0;
+	int ret;
 
 	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	pr_info("%s\n", DRV_COPYRIGHT);
 
-	ret = rtnl_link_register(&tun_link_ops);
-	if (ret) {
-		pr_err("Can't register link_ops\n");
-		goto err_linkops;
-	}
+	rtnl_link_register(&tun_link_ops);
 
 	ret = misc_register(&tun_miscdev);
 	if (ret) {
-- 
1.7.0.4
