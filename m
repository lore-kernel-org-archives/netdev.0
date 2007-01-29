From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: fix potential leak in usb_init
Date: Mon, 29 Jan 2007 00:59:51 +0000 (GMT)
Message-ID: <20070129005951.1F81C7B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:2380 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932941AbXA2A7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:59:45 -0500
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Austruy <maxime@tralhalla.org>

usb_init should call destroy_workqueue when usb_register fails.

Signed-off-by: Maxime Austruy <maxime@tralhalla.org>
Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1026,6 +1026,7 @@ static int __init usb_init(void)
 
 	r = usb_register(&driver);
 	if (r) {
+		destroy_workqueue(zd_workqueue);
 		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
 		       driver.name, r);
 		return r;
