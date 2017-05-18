From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] net1080: Remove unused function nc_dump_ttl()
Date: Thu, 18 May 2017 10:57:19 -0700
Message-ID: <20170518175719.103143-1-mka@chromium.org>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function is not used, removing it fixes the following warning when
building with clang:

drivers/net/usb/net1080.c:271:20: error: unused function
    'nc_dump_ttl' [-Werror,-Wunused-function]

Also remove the definition of TTL_THIS, which is only used in
nc_dump_ttl()

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 drivers/net/usb/net1080.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 4cbdb1307f3e..3202c19df83d 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -264,17 +264,9 @@ static inline void nc_dump_status(struct usbnet *dev, u16 status)
  * TTL register
  */
 
-#define	TTL_THIS(ttl)	(0x00ff & ttl)
 #define	TTL_OTHER(ttl)	(0x00ff & (ttl >> 8))
 #define MK_TTL(this,other)	((u16)(((other)<<8)|(0x00ff&(this))))
 
-static inline void nc_dump_ttl(struct usbnet *dev, u16 ttl)
-{
-	netif_dbg(dev, link, dev->net, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
-		  dev->udev->bus->bus_name, dev->udev->devpath,
-		  ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
-}
-
 /*-------------------------------------------------------------------------*/
 
 static int net1080_reset(struct usbnet *dev)
@@ -308,7 +300,6 @@ static int net1080_reset(struct usbnet *dev)
 		goto done;
 	}
 	ttl = vp;
-	// nc_dump_ttl(dev, ttl);
 
 	nc_register_write(dev, REG_TTL,
 			MK_TTL(NC_READ_TTL_MS, TTL_OTHER(ttl)) );
-- 
2.13.0.303.g4ebf302169-goog
