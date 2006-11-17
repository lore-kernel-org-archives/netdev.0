From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netdev: don't allow register_netdev with blank name
Date: Fri, 17 Nov 2006 13:41:58 -0800
Message-ID: <20061117134158.3d3f1508@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:33744 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1755943AbWKQVmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 16:42:47 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This bit of old backwards compatibility cruft can be removed in 2.6.20.
If there is still an device that calls register_netdev()
with a zero or blank name, it will get -EINVAL from register_netdevice().

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.19-rc6.orig/net/core/dev.c	2006-11-17 13:35:04.000000000 -0800
+++ linux-2.6.19-rc6/net/core/dev.c	2006-11-17 13:37:46.000000000 -0800
@@ -3035,15 +3035,6 @@
 			goto out;
 	}
 	
-	/*
-	 * Back compatibility hook. Kill this one in 2.5
-	 */
-	if (dev->name[0] == 0 || dev->name[0] == ' ') {
-		err = dev_alloc_name(dev, "eth%d");
-		if (err < 0)
-			goto out;
-	}
-
 	err = register_netdevice(dev);
 out:
 	rtnl_unlock();
