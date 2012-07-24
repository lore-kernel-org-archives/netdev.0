From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] wanmain: comparing array with NULL
Date: Tue, 24 Jul 2012 19:16:25 +0100
Message-ID: <20120724181622.27921.80598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:46329 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239Ab2GXR7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 13:59:23 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q6OIWdbh006963
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 19:32:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

gcc really should warn about these !

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/wanrouter/wanmain.c |   51 +++++++++++++++++++++--------------------------
 1 file changed, 23 insertions(+), 28 deletions(-)

diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 788a12c..23d6569 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -602,36 +602,31 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 		 * successfully, add it to the interface list.
 		 */
 
-		if (dev->name == NULL) {
-			err = -EINVAL;
-		} else {
-
-			#ifdef WANDEBUG
-			printk(KERN_INFO "%s: registering interface %s...\n",
+#ifdef WANDEBUG
+		printk(KERN_INFO "%s: registering interface %s...\n",
 				wanrouter_modname, dev->name);
-			#endif
-
-			err = register_netdev(dev);
-			if (!err) {
-				struct net_device *slave = NULL;
-				unsigned long smp_flags=0;
-
-				lock_adapter_irq(&wandev->lock, &smp_flags);
-
-				if (wandev->dev == NULL) {
-					wandev->dev = dev;
-				} else {
-					for (slave=wandev->dev;
-					     DEV_TO_SLAVE(slave);
-					     slave = DEV_TO_SLAVE(slave))
-						DEV_TO_SLAVE(slave) = dev;
-				}
-				++wandev->ndev;
-
-				unlock_adapter_irq(&wandev->lock, &smp_flags);
-				err = 0;	/* done !!! */
-				goto out;
+#endif
+
+		err = register_netdev(dev);
+		if (!err) {
+			struct net_device *slave = NULL;
+			unsigned long smp_flags=0;
+
+			lock_adapter_irq(&wandev->lock, &smp_flags);
+
+			if (wandev->dev == NULL) {
+				wandev->dev = dev;
+			} else {
+				for (slave=wandev->dev;
+				     DEV_TO_SLAVE(slave);
+				     slave = DEV_TO_SLAVE(slave))
+					DEV_TO_SLAVE(slave) = dev;
 			}
+			++wandev->ndev;
+
+			unlock_adapter_irq(&wandev->lock, &smp_flags);
+			err = 0;	/* done !!! */
+			goto out;
 		}
 		if (wandev->del_if)
 			wandev->del_if(wandev, dev);
