From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NET-2.6.24] Remove double dev->flags checking when calling
 dev_close()
Date: Tue, 09 Oct 2007 14:50:54 +0400
Message-ID: <470B5D0E.9090202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58469 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbXJIKxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 06:53:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The unregister_netdevice() and dev_change_net_namespace() 
both check for dev->flags to be IFF_UP before calling the 
dev_close(), but the dev_close() checks for IFF_UP itself, 
so remove those unneeded checks.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index e7e728a..1e169a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3893,8 +3893,7 @@ void unregister_netdevice(struct net_dev
 	BUG_ON(dev->reg_state != NETREG_REGISTERED);
 
 	/* If device is running, close it first. */
-	if (dev->flags & IFF_UP)
-		dev_close(dev);
+	dev_close(dev);
 
 	/* And unlink it from device chain. */
 	unlist_netdevice(dev);
@@ -4018,8 +4017,7 @@ int dev_change_net_namespace(struct net_
 	 */
 
 	/* If device is running close it first. */
-	if (dev->flags & IFF_UP)
-		dev_close(dev);
+	dev_close(dev);
 
 	/* And unlink it from device chain */
 	err = -ENODEV;

