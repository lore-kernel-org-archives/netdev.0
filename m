From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] keep track of network interface renaming
Date: Tue, 15 Aug 2006 18:56:35 +0200
Message-ID: <20060815165635.GA31291@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from natklopstock.rzone.de ([81.169.145.174]:40856 "EHLO
	natklopstock.rzone.de") by vger.kernel.org with ESMTP
	id S1752118AbWHOQ4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 12:56:42 -0400
Received: from ibook.aepfle.de (p5493D3E2.dip.t-dialin.net [84.147.211.226])
	by post.webmailer.de (8.13.6/8.13.6) with ESMTP id k7FGucbQ029956
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 18:56:39 +0200 (MEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Keep track about which network interface names were renamed after the
network device driver printed its banner. Previous kernel names will
be reused when new interfaces get registerd.
Recent udev scripts implement a stable kernel device name for network
interfaces.
This printk avoids confusion about what network hardware maps to what
kernel interface in later driver or network stack messages.

Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 net/core/dev.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6.18-rc4/net/core/dev.c
===================================================================
--- linux-2.6.18-rc4.orig/net/core/dev.c
+++ linux-2.6.18-rc4/net/core/dev.c
@@ -738,8 +738,11 @@ int dev_change_name(struct net_device *d
 	}
 	else if (__dev_get_by_name(newname))
 		return -EEXIST;
-	else
+	else {
+		if (strcmp(newname, dev->name))
+			printk(KERN_INFO "%s renamed to %s\n", dev->name, newname);
 		strlcpy(dev->name, newname, IFNAMSIZ);
+	}
 
 	err = class_device_rename(&dev->class_dev, dev->name);
 	if (!err) {
