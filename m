From: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] net1080: Mark nc_dump_ttl() as __maybe_unused
Date: Wed, 17 May 2017 15:17:08 -0700
Message-ID: <20170517221708.183212-1-mka@chromium.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function is not used, but it looks useful for debugging. Adding the
attribute fixes the following clang warning:

drivers/net/usb/net1080.c:271:20: error: unused function
    'nc_dump_ttl' [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/net1080.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 4cbdb1307f3e..7ade2119f462 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -268,7 +268,7 @@ static inline void nc_dump_status(struct usbnet *dev, u16 status)
 #define	TTL_OTHER(ttl)	(0x00ff & (ttl >> 8))
 #define MK_TTL(this,other)	((u16)(((other)<<8)|(0x00ff&(this))))
 
-static inline void nc_dump_ttl(struct usbnet *dev, u16 ttl)
+static inline void __maybe_unused nc_dump_ttl(struct usbnet *dev, u16 ttl)
 {
 	netif_dbg(dev, link, dev->net, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
 		  dev->udev->bus->bus_name, dev->udev->devpath,
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
