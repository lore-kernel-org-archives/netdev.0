From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH] tun/tap: Add the missed return value check of register_netdevice_notifier
Date: Thu, 20 Jul 2017 02:41:34 -0700
Message-ID: <1500543694-23465-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33950 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934105AbdGTJlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 05:41:55 -0400
Received: by mail-pg0-f68.google.com with SMTP id v190so2328282pgv.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 02:41:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is some codes of tun/tap module which did not check the return
value of register_netdevice_notifier. Add the check now.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 drivers/net/tun.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3d4c245..32ad873 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2598,8 +2598,16 @@ static int __init tun_init(void)
 		goto err_misc;
 	}
 
-	register_netdevice_notifier(&tun_notifier_block);
+	ret = register_netdevice_notifier(&tun_notifier_block);
+	if (ret) {
+		pr_err("Can't register netdevice notifier\n");
+		goto err_notifier;
+	}
+
 	return  0;
+
+err_notifier:
+	misc_deregister(&tun_miscdev);
 err_misc:
 	rtnl_link_unregister(&tun_link_ops);
 err_linkops:
-- 
1.8.3.1
