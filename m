From: "allan" <allan@asix.com.tw>
Subject: [PATCH v2] drivers/net/usb/asix: fixed asix_get_wol reported wrong wol status issue
Date: Fri, 23 Dec 2011 14:38:51 +0800
Message-ID: <005001ccc13d$8c9850e0$a5c8f2a0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"'Freddy Xin'" <freddy@asix.com.tw>,
	"'Grant Grundler'" <grundler@chromium.org>,
	"'Eugene'" <elubarsky@gmail.com>,
	"=?utf-8?Q?'ASIX_Louis_=5B=E8=98=87=E5=A8=81=E9=99=B8=5D'?="
	<louis@asix.com.tw>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: zh-tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed the asix_get_wol() routine reported wrong wol status issue. 

Signed-off-by: Allan Chou <allan@asix.com.tw>
Tested-by: Eugene <elubarsky@gmail.com>; Allan Chou <allan@asix.com.tw>
---
This fix had been verified on x86 Linux kernel 3.0.0-12-generic system with AX88772A/AX88772/Belkin AX88178 USB dongles, and the wol function works fine (can be waked up by receiving the magic packets).

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
--- a/drivers/net/usb/asix.c	2011-12-15 14:01:49.000000000 +0800
+++ b/drivers/net/usb/asix.c	2011-12-22 18:20:39.000000000 +0800
@@ -36,7 +36,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
 
-#define DRIVER_VERSION "08-Nov-2011"
+#define DRIVER_VERSION "22-Dec-2011"
 #define DRIVER_NAME "asix"
 
 /* ASIX AX8817X based USB 2.0 Ethernet Devices */
@@ -689,6 +689,10 @@ asix_get_wol(struct net_device *net, str
 	}
 	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
 	wolinfo->wolopts = 0;
+	if (opt & AX_MONITOR_LINK)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (opt & AX_MONITOR_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
 }
 
 static int
