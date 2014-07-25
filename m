From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] isdn/bas_gigaset: fix a leak on failure path in gigaset_probe()
Date: Sat, 26 Jul 2014 02:34:31 +0400
Message-ID: <1406327671-28271-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a lack of usb_put_dev(udev) on failure path in gigaset_probe().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/isdn/gigaset/bas-gigaset.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index c44950d3eb7b..b7ae0a0dd5b6 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2400,6 +2400,7 @@ allocerr:
 error:
 	freeurbs(cs);
 	usb_set_intfdata(interface, NULL);
+	usb_put_dev(udev);
 	gigaset_freecs(cs);
 	return rc;
 }
-- 
1.9.1
