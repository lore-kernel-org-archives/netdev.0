From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Reset device in the probe call
Date: Mon, 29 Jan 2007 00:59:28 +0000 (GMT)
Message-ID: <20070129005928.5635B7B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:25773 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933005AbXA2A70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:59:26 -0500
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

This resets the device in the probe call. It does work with
2.6.19.2 including the softmac patches. It might fix the
reboot/reset problems a lot of people reported.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -922,6 +922,8 @@ static int probe(struct usb_interface *i
 		goto error;
 	}
 
+	usb_reset_device(interface_to_usbdev(intf));
+
 	netdev = zd_netdev_alloc(intf);
 	if (netdev == NULL) {
 		r = -ENOMEM;
