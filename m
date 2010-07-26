From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] drop_monitor: use genl_register_family_with_ops()
Date: Mon, 26 Jul 2010 17:20:17 +0800
Message-ID: <1280136017-17526-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/drop_monitor.c |   19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 646ef3b..bdb0e96 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -357,21 +357,12 @@ static int __init init_net_drop_monitor(void)
 		return -ENOSPC;
 	}
 
-	if (genl_register_family(&net_drop_monitor_family) < 0) {
+	rc = genl_register_family_with_ops(&net_drop_monitor_family,
+					   dropmon_ops,
+					   ARRAY_SIZE(dropmon_ops));
+	if (rc) {
 		printk(KERN_ERR "Could not create drop monitor netlink family\n");
-		return -EFAULT;
-	}
-
-	rc = -EFAULT;
-
-	for (i = 0; i < ARRAY_SIZE(dropmon_ops); i++) {
-		ret = genl_register_ops(&net_drop_monitor_family,
-					&dropmon_ops[i]);
-		if (ret) {
-			printk(KERN_CRIT "Failed to register operation %d\n",
-				dropmon_ops[i].cmd);
-			goto out_unreg;
-		}
+		return rc;
 	}
 
 	rc = register_netdevice_notifier(&dropmon_net_notifier);
