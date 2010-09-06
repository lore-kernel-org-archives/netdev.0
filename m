From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net/caifcaif_dev.c: Use netdev_<level>
Date: Mon, 06 Sep 2010 01:08:09 -0700
Message-ID: <1283760489.23280.77.camel@Joe-Laptop>
References: <1283758271.23280.73.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1488 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965Ab0IFIIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 04:08:11 -0400
In-Reply-To: <1283758271.23280.73.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert pr_<level>("%s" ..., (struct netdev *)->name ...)
to netdev_<level>((struct netdev *), ...)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/caif/caif_dev.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 1fdfe70..0fd01dd 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -216,7 +216,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 	switch (what) {
 	case NETDEV_REGISTER:
-		pr_info("register %s\n", dev->name);
+		netdev_info(dev, "register\n");
 		caifd = caif_device_alloc(dev);
 		if (caifd == NULL)
 			break;
@@ -227,13 +227,13 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		break;
 
 	case NETDEV_UP:
-		pr_info("up %s\n", dev->name);
+		netdev_info(dev, "up\n");
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
 		caifdev = netdev_priv(dev);
 		if (atomic_read(&caifd->state) == NETDEV_UP) {
-			pr_info("%s already up\n", dev->name);
+			netdev_info(dev, "already up\n");
 			break;
 		}
 		atomic_set(&caifd->state, what);
@@ -274,7 +274,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
-		pr_info("going down %s\n", dev->name);
+		netdev_info(dev, "going down\n");
 
 		if (atomic_read(&caifd->state) == NETDEV_GOING_DOWN ||
 			atomic_read(&caifd->state) == NETDEV_DOWN)
@@ -296,10 +296,10 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
-		pr_info("down %s\n", dev->name);
+		netdev_info(dev, "down\n");
 		if (atomic_read(&caifd->in_use))
-			pr_warn("Unregistering an active CAIF device: %s\n",
-				dev->name);
+			netdev_warn(dev,
+				    "Unregistering an active CAIF device\n");
 		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
 		dev_put(dev);
 		atomic_set(&caifd->state, what);
@@ -307,7 +307,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 	case NETDEV_UNREGISTER:
 		caifd = caif_get(dev);
-		pr_info("unregister %s\n", dev->name);
+		netdev_info(dev, "unregister\n");
 		atomic_set(&caifd->state, what);
 		caif_device_destroy(dev);
 		break;


