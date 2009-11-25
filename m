From: andrew hendry <andrew.hendry@gmail.com>
Subject: [PATCH 3/3] X25: Fix oops and refcnt problems from x25_dev_get
Date: Wed, 25 Nov 2009 12:16:05 +1100
Message-ID: <d45a3acc0911241716i7bf218c4y71c75d9841695dfe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-x25@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934133AbZKYBQB@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
+					))){
 		dev_put(dev);
+		dev = NULL;
+	}

 	return dev;
 }
