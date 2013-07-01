From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] xen-netback: xenbus.c: use more current logging styles
Date: Tue, 2 Jul 2013 00:08:54 +0100
Message-ID: <1372720134-9765-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <joe@perches.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43613 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100Ab3GAXIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 19:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert one printk to pr_<level>.

Add a missing newline in several places to avoid message interleaving,
coalesce formats, reflow modified lines to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/xenbus.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 04bd860..1fe48fe3 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -130,7 +130,7 @@ static int netback_probe(struct xenbus_device *dev,
 			    "feature-split-event-channels",
 			    "%u", separate_tx_rx_irq);
 	if (err)
-		pr_debug("Error writing feature-split-event-channels");
+		pr_debug("Error writing feature-split-event-channels\n");
 
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
@@ -145,7 +145,7 @@ abort_transaction:
 	xenbus_transaction_end(xbt, 1);
 	xenbus_dev_fatal(dev, err, "%s", message);
 fail:
-	pr_debug("failed");
+	pr_debug("failed\n");
 	netback_remove(dev);
 	return err;
 }
@@ -228,15 +228,14 @@ static void frontend_changed(struct xenbus_device *dev,
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
 
-	pr_debug("frontend state %s", xenbus_strstate(frontend_state));
+	pr_debug("frontend state %s\n", xenbus_strstate(frontend_state));
 
 	be->frontend_state = frontend_state;
 
 	switch (frontend_state) {
 	case XenbusStateInitialising:
 		if (dev->state == XenbusStateClosed) {
-			printk(KERN_INFO "%s: %s: prepare for reconnect\n",
-			       __func__, dev->nodename);
+			pr_info("%s: prepare for reconnect\n", dev->nodename);
 			xenbus_switch_state(dev, XenbusStateInitWait);
 		}
 		break;
-- 
1.7.10.4
