From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 54/62] atmel: Use static const
Date: Sat, 20 Nov 2010 18:38:55 -0800
Message-ID: <d9d7c32e0b5e38388ba25facf1350caa4abe8f3b.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  42578	    720	   8528	  51826	   ca72	drivers/net/wireless/atmel.o.old
  42578	    720	   8528	  51826	   ca72	drivers/net/wireless/atmel.o.new

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/atmel.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index c8f7090..46e382e 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1161,7 +1161,7 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 	struct atmel_private *priv = netdev_priv(dev);
 	u8 isr;
 	int i = -1;
-	static u8 irq_order[] = {
+	static const u8 irq_order[] = {
 		ISR_OUT_OF_RANGE,
 		ISR_RxCOMPLETE,
 		ISR_TxCOMPLETE,
@@ -3771,7 +3771,9 @@ static int probe_atmel_card(struct net_device *dev)
 
 	if (rc) {
 		if (dev->dev_addr[0] == 0xFF) {
-			u8 default_mac[] = {0x00, 0x04, 0x25, 0x00, 0x00, 0x00};
+			static const u8 default_mac[] = {
+				0x00, 0x04, 0x25, 0x00, 0x00, 0x00
+			};
 			printk(KERN_ALERT "%s: *** Invalid MAC address. UPGRADE Firmware ****\n", dev->name);
 			memcpy(dev->dev_addr, default_mac, 6);
 		}
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
