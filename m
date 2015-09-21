From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 27/38] usbnet: remove invalid check
Date: Mon, 21 Sep 2015 15:33:59 +0200
Message-ID: <1442842450-29769-28-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	"David S. Miller" <davem@davemloft.net>,
	"Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->len is always non-negative.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/usb/lan78xx.c  | 5 -----
 drivers/net/usb/smsc75xx.c | 5 -----
 drivers/net/usb/smsc95xx.c | 5 -----
 3 files changed, 15 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index a39518f..e0556dc 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2522,11 +2522,6 @@ static int lan78xx_rx(struct lan78xx_net *dev, struct sk_buff *skb)
 			skb_pull(skb, align_count);
 	}
 
-	if (unlikely(skb->len < 0)) {
-		netdev_warn(dev->net, "invalid rx length<0 %d", skb->len);
-		return 0;
-	}
-
 	return 1;
 }
 
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index d9e7892..30033db 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -2185,11 +2185,6 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			skb_pull(skb, align_count);
 	}
 
-	if (unlikely(skb->len < 0)) {
-		netdev_warn(dev->net, "invalid rx length<0 %d\n", skb->len);
-		return 0;
-	}
-
 	return 1;
 }
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 26423ad..66b3ab9 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1815,11 +1815,6 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			skb_pull(skb, align_count);
 	}
 
-	if (unlikely(skb->len < 0)) {
-		netdev_warn(dev->net, "invalid rx length<0 %d\n", skb->len);
-		return 0;
-	}
-
 	return 1;
 }
 
-- 
1.9.1
