From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 3/5] usb: usbnet: use newly introduced hex_to_bin()
Date: Fri, 23 Jul 2010 16:18:08 +0300
Message-ID: <dfeaa560c7a129bd667521be983794a05a12a12e.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: linux-usb@vger.kernel.org
---
 drivers/net/usb/usbnet.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 7eab407..f5e1639 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -44,6 +44,7 @@
 #include <linux/usb.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/kernel.h>
 
 #define DRIVER_VERSION		"22-Aug-2005"
 
@@ -158,16 +159,6 @@ int usbnet_get_endpoints(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_get_endpoints);
 
-static u8 nibble(unsigned char c)
-{
-	if (likely(isdigit(c)))
-		return c - '0';
-	c = toupper(c);
-	if (likely(isxdigit(c)))
-		return 10 + c - 'A';
-	return 0;
-}
-
 int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
 {
 	int 		tmp, i;
@@ -183,7 +174,7 @@ int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
 	}
 	for (i = tmp = 0; i < 6; i++, tmp += 2)
 		dev->net->dev_addr [i] =
-			(nibble(buf [tmp]) << 4) + nibble(buf [tmp + 1]);
+			(hex_to_bin(buf[tmp]) << 4) + hex_to_bin(buf[tmp + 1]);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_get_ethernet_addr);
-- 
1.7.1.1
