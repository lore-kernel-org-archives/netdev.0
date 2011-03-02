From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] eql: Convert printks to pr_<level> and netdev_<level>
Date: Wed,  2 Mar 2011 09:18:12 -0800
Message-ID: <90c4322fefc5e2d4778862abd051e6eb12c0284b.1299086044.git.joe@perches.com>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4043 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756176Ab1CBRSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 12:18:14 -0500
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id 020E12436C
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 09:18:05 -0800 (PST)
In-Reply-To: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pr_fmt

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/eql.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 0cb1cf9..ffda358 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -111,6 +111,8 @@
  * Sorry, I had to rewrite most of this for 2.5.x -DaveM
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -204,8 +206,8 @@ static int eql_open(struct net_device *dev)
 	equalizer_t *eql = netdev_priv(dev);
 
 	/* XXX We should force this off automatically for the user. */
-	printk(KERN_INFO "%s: remember to turn off Van-Jacobson compression on "
-	       "your slave devices.\n", dev->name);
+	netdev_info(dev,
+		    "remember to turn off Van-Jacobson compression on your slave devices\n");
 
 	BUG_ON(!list_empty(&eql->queue.all_slaves));
 
@@ -591,7 +593,7 @@ static int __init eql_init_module(void)
 {
 	int err;
 
-	printk(version);
+	pr_info(version);
 
 	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", eql_setup);
 	if (!dev_eql)
-- 
1.7.4.2.g597a6.dirty

