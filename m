From: andrew hendry <andrew.hendry@gmail.com>
Subject: [RESEND PATCH 3/3] X25: Fix oops and refcnt problems from x25_dev_get
Date: Tue, 15 Dec 2009 09:03:07 +1100
Message-ID: <d45a3acc0912141403p150fae90m73a4f8e92030c73a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:35609 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758556AbZLNWDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 17:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calls to x25_dev_get check for dev = NULL which was not set.
It allowed x25 to set routes and ioctls on down interfaces.
This caused oopses and refcnt problems on device_unregister.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

--- a/net/x25/x25_route.c	2009-11-25 09:30:52.003038597 +1100
+++ b/net/x25/x25_route.c	2009-11-25 09:33:37.627093701 +1100
@@ -136,8 +136,10 @@ struct net_device *x25_dev_get(char *dev
 #if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
 					&& dev->type != ARPHRD_ETHER
 #endif
-					)))
+					))) {
 		dev_put(dev);
+		dev = NULL;
+	}

 	return dev;
 }
