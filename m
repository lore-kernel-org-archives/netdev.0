From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/2] xen: use less generic names in netfront driver.
Date: Thu, 19 Aug 2010 10:27:49 +0100
Message-ID: <1282210070-7745-1-git-send-email-ian.campbell@citrix.com>
References: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49482 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0HSJ1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 05:27:54 -0400
In-Reply-To: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All Xen frontend drivers have a couple of identically named functions which
makes figuring out which device went wrong from a stacktrace harder than it
needs to be. Rename them to something specificto the device type.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 drivers/net/xen-netfront.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index b50fedc..788a9bc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1395,7 +1395,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 }
 
 /* Common code used when first setting up, and when resuming. */
-static int talk_to_backend(struct xenbus_device *dev,
+static int talk_to_netback(struct xenbus_device *dev,
 			   struct netfront_info *info)
 {
 	const char *message;
@@ -1545,7 +1545,7 @@ static int xennet_connect(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	err = talk_to_backend(np->xbdev, np);
+	err = talk_to_netback(np->xbdev, np);
 	if (err)
 		return err;
 
@@ -1599,7 +1599,7 @@ static int xennet_connect(struct net_device *dev)
 /**
  * Callback received when the backend's state changes.
  */
-static void backend_changed(struct xenbus_device *dev,
+static void netback_changed(struct xenbus_device *dev,
 			    enum xenbus_state backend_state)
 {
 	struct netfront_info *np = dev_get_drvdata(&dev->dev);
@@ -1801,7 +1801,7 @@ static struct xenbus_driver netfront_driver = {
 	.probe = netfront_probe,
 	.remove = __devexit_p(xennet_remove),
 	.resume = netfront_resume,
-	.otherend_changed = backend_changed,
+	.otherend_changed = netback_changed,
 };
 
 static int __init netif_init(void)
-- 
1.5.6.5

