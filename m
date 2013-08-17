From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 31/49] USBNET: rtl8150: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:24:56 +0800
Message-ID: <1376756714-25479-32-git-send-email-ming.lei@canonical.com>
References: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1376756714-25479-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/rtl8150.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6cbdac6..199e0fb 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -372,6 +372,7 @@ static void read_bulk_callback(struct urb *urb)
 	u16 rx_stat;
 	int status = urb->status;
 	int result;
+	unsigned long flags;
 
 	dev = urb->context;
 	if (!dev)
@@ -413,9 +414,9 @@ static void read_bulk_callback(struct urb *urb)
 	netdev->stats.rx_packets++;
 	netdev->stats.rx_bytes += pkt_len;
 
-	spin_lock(&dev->rx_pool_lock);
+	spin_lock_irqsave(&dev->rx_pool_lock, flags);
 	skb = pull_skb(dev);
-	spin_unlock(&dev->rx_pool_lock);
+	spin_unlock_irqrestore(&dev->rx_pool_lock, flags);
 	if (!skb)
 		goto resched;
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
