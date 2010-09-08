From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] ipheth: remove incorrect devtype to WWAN
Date: Wed, 08 Sep 2010 12:50:47 -0500
Message-ID: <1283968247.2839.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Diego Giagio <diego-KR0zwsgql1HQT0dZR+AlfA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The 'wwan' devtype is meant for devices that require preconfiguration
and *every* time setup before the ethernet interface can be used, like
cellular modems which require a series of setup commands on serial ports
or other mechanisms before the ethernet interface will handle packets.

As ipheth only requires one-per-hotplug pairing setup with no
preconfiguration (like APN, phone #, etc) and the network interface is
usable at any time after that initial setup, remove the incorrect
devtype wwan.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 08e7b6a..3388569 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -424,10 +424,6 @@ static const struct net_device_ops ipheth_netdev_ops = {
 	.ndo_get_stats = &ipheth_stats,
 };
 
-static struct device_type ipheth_type = {
-	.name	= "wwan",
-};
