From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH -v1 2/3] usbnet: decrease suspend count if returning -EBUSY for runtime suspend
Date: Wed, 20 Jun 2012 15:15:52 +0800
Message-ID: <1340176553-32225-3-git-send-email-ming.lei@canonical.com>
References: <1340176553-32225-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340176553-32225-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch decreases dev->suspend_count in the -EBUSY failure path
of usbnet_suspend. Without the change, the later runtime suspend
will do nothing except for increasing dev->suspend_count.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f06cf9b..9bfa775 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1508,6 +1508,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		spin_lock_irq(&dev->txq.lock);
 		/* don't autosuspend while transmitting */
 		if (dev->txq.qlen && PMSG_IS_AUTO(message)) {
+			dev->suspend_count--;
 			spin_unlock_irq(&dev->txq.lock);
 			return -EBUSY;
 		} else {
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
