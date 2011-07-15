From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next-2.6] slcan: remove obsolete code in slcan initialisation
Date: Fri, 15 Jul 2011 09:49:19 +0200
Message-ID: <4E1FF0FF.2020808@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Matvejchikov Ilya <matvejchikov@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:62198 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198Ab1GOHtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 03:49:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes obsolete code in the initialisation/creation of
slcan devices.

It follows the suggested cleanups from Ilya Matvejchikov in
drivers/net/slip.c that where recently applied to net-next-2.6:

- slip: remove dead code within the slip initialization
- slip: remove redundant check slip_devs for NULL

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 1b49df6..aa8ad73 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -473,12 +473,10 @@ static void slc_sync(void)
 static struct slcan *slc_alloc(dev_t line)
 {
 	int i;
+	char name[IFNAMSIZ];
 	struct net_device *dev = NULL;
 	struct slcan       *sl;

-	if (slcan_devs == NULL)
-		return NULL;	/* Master array missing ! */
-
 	for (i = 0; i < maxdev; i++) {
 		dev = slcan_devs[i];
 		if (dev == NULL)
@@ -490,25 +488,12 @@ static struct slcan *slc_alloc(dev_t line)
 	if (i >= maxdev)
 		return NULL;

-	if (dev) {
-		sl = netdev_priv(dev);
-		if (test_bit(SLF_INUSE, &sl->flags)) {
-			unregister_netdevice(dev);
-			dev = NULL;
-			slcan_devs[i] = NULL;
-		}
-	}
-
-	if (!dev) {
-		char name[IFNAMSIZ];
-		sprintf(name, "slcan%d", i);
-
-		dev = alloc_netdev(sizeof(*sl), name, slc_setup);
-		if (!dev)
-			return NULL;
-		dev->base_addr  = i;
-	}
+	sprintf(name, "slcan%d", i);
+	dev = alloc_netdev(sizeof(*sl), name, slc_setup);
+	if (!dev)
+		return NULL;

+	dev->base_addr  = i;
 	sl = netdev_priv(dev);

 	/* Initialize channel control data */

